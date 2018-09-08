-----------------------------------------
---- Data for figure 3: Random Model ----
-----------------------------------------

-- Set Random Seed --
math.randomseed(9370707)

-- Prepare Data file --
local file2 = io.open("Baseline Results.tsv", "w")
file2:write("game" .. "\t" .. "result" .. "\n")

-- Initialize variables --	
Buttons = {}
Buttons['A'] = true
all_actionh = {-1, -1, -1, 0, 0, 0, 1, 1, 1}
all_actionv = {-1, 0, 1, -1, 0, 1, -1, 0, 1}

-- Do 1000 simulations --
for game = 1, 1000 do

	-- Load savestate at the beginning of the race --
	savestate.loadslot(1)
	
	-- Initialize variables for run --	
	frame = 0
	
	-- Loop until race is finished --
	while memory.readbyte(0x52) == 0 do
		frame = frame + 1
		
		-- Initialize Control Pad --			
		Buttons['Left'] = false
		Buttons['Right'] = false
		Buttons['Down'] = false
		Buttons['Up'] = false
		
		-- Choose an action randomly --
		action = math.random(9)

		-- Acivate horizontal pad button with respect to the action selected -- 		
		if all_actionh[action] == -1 then
			Buttons['Left'] = true
			actionh = -1
		elseif all_actionh[action] == 1 then
			Buttons['Right'] = true
			actionh = 1
		else
			actionh = 0
		end
		
		-- Acivate vertical pad button with respect to the action selected -- 	
		if all_actionv[action] == -1 then
			Buttons['Down'] = true
			actionv = -1
		elseif all_actionv[action] == 1 then
			Buttons['Up'] = true
			actionv = 1
		else
			actionv = 0
		end
		

		
		-- Press buttons and wait 4 frames -- 		
		for i = 1, 4 do
			joypad.set(Buttons, 1)
			emu.frameadvance()
		end
		
			
	end
	-- Write Results to data file --
	file2:write(game .. "\t" .. frame .. "\n")
	file2:flush()
	
end

-- Close data file --
file2:close()