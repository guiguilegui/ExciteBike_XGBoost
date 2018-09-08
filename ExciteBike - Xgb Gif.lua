-------------------------------
---- Animation 3: Final AI ----
-------------------------------

-- Set Random Seed --
math.randomseed(9370707)

-- Read external functions --
require("Evaluate_xgboost")
dofile("C:\\Users\\Guillaume\\Documents\\Nes\\Excitebike\\xgbdump885")

-- Load savestate at the beginning of the race --
savestate.loadslot(1)

-- Initialize variables --
Buttons = {}
iteration = 0
Buttons['A'] = true
feats = {'ypos', 'xspeed', 'angle', 'status', 'to_run', 'lane', 'slant_timer', 'futurepos0', 'futurepos1', 'futurepos2', 'futurepos3', 'actionh', 'actionv'}
all_actionh = {-1, -1, -1, 0, 0, 0, 1, 1, 1}
all_actionv = {-1, 0, 1, -1, 0, 1, -1, 0, 1}

-- Loop until race is finished --
while memory.readbyte(0x52) == 0 do
		
	iteration = iteration + 1
	
	-- Read target variables and selected features --
	angle = memory.readbyte(0xAC)
	status = memory.readbyte(0xF2)
	to_run = memory.readbyte(0x0390)
	lane = memory.readbyte(0x70)
	ypos = memory.readbyte(0x8C) + memory.readbyte(0xB8) -- Vertical position
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
	
	-- Compute Model Results for all Buttons--	
	for i = 1, 9 do
		actionh = all_actionh[i]
		actionv = all_actionv[i]
		
		power[i] = xgb_predict() -- requires feats
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
	
	-- Take screenshot -- 
	client.screenshot("img/ExcitebikeXgb" .. string.format("%04d", iteration) ..".png") --save image
	
	-- Press buttons and wait 4 frames -- 	
	for i = 1, 4 do
		joypad.set(Buttons, 1)
		gui.pixelText(20, 20, frame, 'white', 'black')
		emu.frameadvance()
	end
	
		
end

-- Convert png images to a gif -- 
os.execute('convert -delay 6.6666 -loop 0 ./img/ExcitebikeXgb*.png ./img/ExcitebikeXgb.gif') -- 6.6666 = 100 ticks per second for ImageMagick / 60 frame per second for the NES / only ¼ of the frames with screenshot 