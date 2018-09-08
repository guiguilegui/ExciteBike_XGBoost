------------------------
---- Lua part of AI ----
------------------------

-- Set Random Seed --
math.randomseed(9370707)

-- Read external functions --
require("Evaluate_xgboost")

-- Prepare Data file for global results--
local file2 = io.open("Game Results.tsv", "w")
file2:write("game" .. "\t" .. "result" .. "\n")

-- Initialize variables --	
Buttons = {}
game = 0
totalresult = 0
Buttons['A'] = true
feats = {'ypos', 'xspeed', 'angle', 'status', 'to_run', 'lane', 'slant_timer', 'futurepos0', 'futurepos1', 'futurepos2', 'futurepos3', 'actionh', 'actionv'}
all_actionh = {-1, -1, -1, 0, 0, 0, 1, 1, 1}
all_actionv = {-1, 0, 1, -1, 0, 1, -1, 0, 1}
	
-- Do 1000 simulations --
for game = 1, 1000 do

	-- Prepare Data file for the simulation's results--
	local file = io.open("Game Decision.tsv", "w")
	file:write(
		"game" .. "\t" .. "frame" .. "\t" .. 
		"xpos" .. "\t" .. "ypos" .. "\t".. "xspeed" .. "\t" ..
		"angle" .. "\t" .. "status" .. "\t" .. "to_run" .. "\t" .. 
		"lane" .. "\t" .. "slant_timer" .. "\t" .. 
		"futurepos0" .. "\t" .. "futurepos1" .. "\t" .. "futurepos2" .. "\t" .. "futurepos3" .. "\t" ..
		"actionh" .. "\t" .. "actionv" .. "\n"
	)	
	
	-- Load savestate at the beginning of the race --
	savestate.loadslot(1)
	
	-- Read external function if created --
	if game > 1 then
		dofile("C:\\Users\\Guillaume\\Documents\\Nes\\Excitebike\\xgbdumpwow")
	end
	
	
	-- Initialize variables for the run--		
	previous_xpos1  = 0
	frame = 0
	xpos1 = 0
	xpos2 = 0
	
	-- Set chance for random action - Every fifth simulation is deterministic to assess if the algorithm improved --	
	if game % 5 == 0 then
		epsilon = 0
	else 
		epsilon = 0.6/(1 + 0.01 * game)
	end 
	
	-- Loop until race is finished --	
	while memory.readbyte(0x52) == 0 do
	
		frame = frame + 1
		
		-- Read target variables and selected features --
		xpos1 = memory.readbyte(0x50)
		
		if xpos1 < previous_xpos1 then
			xpos2 = xpos2 + 1
		end
		
		previous_xpos1 = xpos1
		xpos = xpos2 * 0xFF + xpos1
		
		angle = memory.readbyte(0xAC)
		status = memory.readbyte(0xF2)
		to_run = memory.readbyte(0x0390)
		lane = memory.readbyte(0x70)
		ypos = memory.readbyte(0x8C) + memory.readbyte(0xB8) -- Height
		xspeed = memory.readbyte(0x90) + memory.readbyte(0x94) * 256
		
		slant_timer = memory.readbyte(0x26)
		
		futurepos0 = memory.readbyte(0x03C0)
		futurepos1 = memory.readbyte(0x03C1)
		futurepos2 = memory.readbyte(0x03C2)
		futurepos3 = memory.readbyte(0x03C3)

		-- Initialize Control Pad --
		Buttons['Left'] = false
		Buttons['Right'] = false
		Buttons['Down'] = false
		Buttons['Up'] = false
		
		-- Initialize Model Results --
		power = {}
		
		if game == 1 or math.random() < epsilon then
			action = math.random(9)
		else
		
			-- Compute Model Results for all Buttons--
			for i = 1, 9 do
				actionh = all_actionh[i]
				actionv = all_actionv[i]
				
				power[i] = xgb_predict()
			end 
			
			-- Choose an action among all the ones that maximized the outcomes --
			maxpower = math.max(unpack(power))
			avail_action = {}
			iter = 0
			for i = 1, 9 do
				if power[i] == maxpower then
					iter = iter + 1
					avail_action[iter] = i
				end
			end
			action = avail_action[math.random(iter)]
		end

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
		
		-- Write this frame's context to file --
		file:write(
			game .. "\t" .. frame .. "\t" .. 
			xpos .. "\t" .. ypos .. "\t".. xspeed .. "\t" ..
			angle .. "\t" .. status .. "\t" .. to_run .. "\t" .. 
			lane .. "\t" .. slant_timer .. "\t" .. 
			futurepos0 .. "\t" .. futurepos1 .. "\t" .. futurepos2 .. "\t" .. futurepos3 .. "\t" ..
			actionh .. "\t" .. actionv .. "\n"
		)
		
		-- Press buttons and wait 4 frames -- 	
		for i = 1, 4 do
			joypad.set(Buttons, 1)
			gui.pixelText(20, 20, frame, 'white', 'black')
			emu.frameadvance()
		end
		
			
	end

	-- Write the simulation's results to global data file --
	file2:write(game .. "\t" .. frame .. "\n")
	file2:flush()
	
	-- Print results to console --
	totalresult = frame + totalresult
	print(game .. '  ' .. frame .. '  ' .. math.floor(totalresult/game*10)/10)
	
	-- Close simulation's results data file --
	file:flush()
	file:close()
	
	-- Execute XGBoost reinforcement learning --
	os.execute('Rscript --vanilla "C:/Users/Guillaume/Documents/Nes/Excitebike/XGBoost.r" ' .. game .. ' ' .. frame .. ' ' .. totalresult .. ' > error.log 2>&1') 
end

-- Close global results data file --
file2:close()