--- daydream
-- pinyonpine 250831
-- a sequencer for crow inspired by awake for norns by tehn https://github.com/tehn/awake/blob/main/awake.lua
-- in1: clock
-- out1: pitch CV
-- out2: gate

-- scale / tuning
scale = {0, 2, 3, 5, 7, 9, 10} -- in this case it is dorian
root  = 0                      -- transpose in semitones

-- sequences
primary = {1,0,3,5,6,7,8,7}    -- 8-step
offset  = {5,7,0,0,0,0,0}      -- 7-step

-- timing
bpm       = 120                 -- fallback internal BPM
gate_time = 0.01
gate_volt = 5

-- state
i_primary = 1
i_offset  = 1

-- helpers
function idx_to_volts(idx)
  L   = #scale
  oct = math.floor(idx / L)
  deg = scale[(idx % L) + 1]
  semitones = deg + 12 * oct + root
  return semitones / 12
end

-- core
function init()
  output[2].action = pulse(gate_time, gate_volt)

  -- set input 1 to gate mode to detect clock pulses
  input[1].mode('change', 1) 

  clock.run(sequencer)
end

function sequencer()
  local eighth_time = (60 / bpm) / 2 -- default if no external clock
  while true do
    -- check for external clock on input 1
    if input[1].volts > 2 then
      -- wait for rising edge
      while input[1].volts > 2 do clock.sleep(0.001) end
      while input[1].volts < 2 do clock.sleep(0.001) end
    else
      clock.sleep(eighth_time)
    end

    base_idx   = primary[i_primary]
    offset_idx = offset[i_offset]

    if base_idx ~= 0 then
      scale_idx = base_idx - 1 -- 1 = root
      final_idx = scale_idx + offset_idx
      output[1].volts = idx_to_volts(final_idx)
      output[2]() -- note gate
    end

    i_primary = (i_primary % #primary) + 1
    i_offset  = (i_offset % #offset) + 1
  end
end
