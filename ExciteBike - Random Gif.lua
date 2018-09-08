-------------------------------------
---- Animation 1: Random Buttons ----
-------------------------------------

-- Set Random Seed --
math.randomseed(9370707)

-- Load savestate at the beginning of the race --
savestate.loadslot(1)

-- Initialize variables --
Buttons = {}
iteration = 0
Buttons['A'] = true
all_actionh = {-1, -1, -1, 0, 0, 0, 1, 1, 1}
all_actionv = {-1, 0, 1, -1, 0, 1, -1, 0, 1}

-- Loop until race is finished --
while memory.readbyte(0x52) == 0 do

	iteration = iteration + 1
	
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
	
	-- Take screenshot -- 
		client.screenshot("img/ExcitebikeRandom" .. string.format("%04d", iteration) ..".png") --save image
	
	-- Press buttons and wait 4 frames -- 
	for i = 1, 4 do
		gui.pixelText(20, 20, iteration, 'white', 'black')
		joypad.set(Buttons, 1)
		emu.frameadvance()
	end
	
		
end


-- Convert all pngs to a gif
os.execute('convert -delay 3.3333 -loop 0 ./img/ExcitebikeRandom*.png ./img/ExcitebikeRandom.gif') -- 3.3333 = 100 ticks per second for ImageMagick / 60 frame per second for the NES / only ¼ of the frames with screenshot / 2 times faster GIF.


