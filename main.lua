-- Pong Video Game created in Lua with the LÖVE framework

--[[ push is a library which allows us to draw the game at a virtual resolution
insetad of the size of the window, this is used to create a more retro looking
aesthetic
]]

-- https://github.com/Ulydev/push
push = require 'push'

-- size of the window where the game is displayed
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- speed at which the paddle will move at, this is multiplied by dt (deltaTime) in update
PADDLE_SPEED = 200

--[[ love.load function is called on game startup, it's used to setup objects, 
variables & other game requirements so the game world can be prepared properly
]]
function love.load()

	-- uses nearest-neighbor filtering when upscaling and downscaling to prevent
	-- blurry text & graphics, without this bilinear filtering would be used by default
	love.graphics.setDefaultFilter('nearest', 'nearest')

	-- seeds the random number generator so that calls to the random function are
	-- always random, uses the current time as it'll be different every call
	math.randomseed(os.time())

	-- a 'retro' styled font which can be used for any text used in the application
	retroFont = love.graphics.newFont('font.ttf', 8)

	-- larger version of the 'retro' font for drawing the score onto the screen
	scoreFont = love.graphics.newFont('font.ttf', 32)

	-- sets LÖVE's active font to the one specified in the retroFont object
	love.graphics.setFont(retroFont)

	-- initialises the virutal resolution which is rendered within the actual window
	-- regardless of its dimensions, replaces the love.window.setMode call previously used
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, { 
		fullscreen = false,
		resizable = false,
		vsync = true
	})

	-- initialises score variables which are used for keeping track of the scores
	-- of each  of the players and determining the winner, these are rendered on screen
	player1Score = 0
	player2Score = 0

	-- paddle positions are fixed to the Y axis so they can only move upwards or downwards
	player1Y = 30
	player2Y = VIRTUAL_HEIGHT - 50

	-- velocity and position of the ball when the game begins
	ballX = VIRTUAL_WIDTH / 2 - 2
	ballY = VIRTUAL_HEIGHT / 2 - 2

	-- math.random returns a randomised value between the 1st & 2nd parameter
	ballDX = math.random(2) == 1 and 100 or -100
	ballDY = math.random(-50, 50)

	-- game state variable which is used to transition to different play states
	-- (used for the start, menus, main game, leaderboards, etc.), we'll use
	-- this to determine behaviour during rendering and updating
	gameState = 'start'
end

--[[ runs with each frame and takes 'dt' as parameter which is the deltaTime 
that has elapsed since the last frame, this is already supplied by LÖVE 
]]
function love.update(dt)
	-- player 1 movement handling
	if love.keyboard.isDown('w') then
		-- add negative paddle speed (up = -Y) to the current Y multiplied by deltaTime (dt)
		-- we clamp the position of the paddle between the bounds of the screen, math.max
		-- returns the greater value of the two; 0 and player1Y ensures we dont go above it
		player1Y = math.max(0, player1Y + -PADDLE_SPEED * dt)
	elseif love.keyboard.isDown('s') then
		-- add positive paddle speed (down = Y) to the current Y multiplied by deltaTime (dt)
		-- math.min returns the lesser of the two values passed in, bottom of the edge minus
		-- the paddle height and player1Y ensures we dont go below it
		player1Y = math.min(VIRTUAL_HEIGHT - 20, player1Y + PADDLE_SPEED * dt)
	end

	-- player 2 movement handling
	if love.keyboard.isDown('up') then
		-- add negative paddle speed (up = -Y) to the current Y multiplied by deltaTime (dt)
		player2Y = math.max(0, player2Y + -PADDLE_SPEED * dt)
	elseif love.keyboard.isDown('down') then
		-- add positive paddle speed (down = Y) to the current Y multiplied by deltaTime (dt)
		player2Y = math.min(VIRTUAL_HEIGHT - 20, player2Y + PADDLE_SPEED * dt)
	end

	-- updates the ball based on its DX and DY values only if in the play state;
	-- scales the velocity of the ball by deltaTime so its movement is framerate-independent
	if gameState == 'play' then
		ballX = ballX + ballDX * dt
		ballY = ballY + ballDY * dt
	end
end

-- keyboard handling, called by LÖVE every frame and passes key pressed as parameter
function love.keypressed(key)
	-- keys can be accessed with a string name
	if key == 'escape' then
		-- LÖVE's quit event function terminates the application
		love.event.quit()
	-- if we press enter at the start of the game this will transition the game to 
	-- the play state, in this mode the ball will move in a random direction
	elseif key == 'enter' or key == 'return' then
		if gameState == 'start' then
			gameState = 'play'
		else
			gameState = 'start'

			-- the ball's position is initially in the middle of the screen
			ballX = VIRTUAL_WIDTH / 2 - 2
			ballY = VIRTUAL_HEIGHT / 2 - 2

			-- given ball's x and y velocity is a random starting value
			-- the and/or pattern used here is Lua's way of accomplishing
			-- a ternary operation seen in other languages like C
			ballDX = math.random(2) == 1 and 100 or -100
			ballDY = math.random(-50, 50) * 1.5
		end
	end
end

--[[ love.draw function called each frame after the update function, responsible
for drawing objects & more to the game screen
]]
function love.draw() 
	-- starts the rendering at the set virtual resolution
	push:apply('start')

	-- clears the screen with a specified colour, chose a purple colour here cause it looked nice
	love.graphics.clear(0.5, 0.51, 0.8, 1)

	-- displays a welcome message near the top of the screen
	love.graphics.setFont(retroFont)

	if gameState == 'start' then
		love.graphics.printf('Hello Start State!', 0, 20, VIRTUAL_WIDTH, 'center')
	else
		love.graphics.printf('Hello Play State!', 0, 20, VIRTUAL_WIDTH, 'center')
	end

	-- draws the scores on the left and right centres of the screen
	-- have to switch the currently used font before rendering
	love.graphics.setFont(scoreFont)
	love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50,
		VIRTUAL_HEIGHT / 3)
	love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
		VIRTUAL_HEIGHT / 3)

	-- setting paddle & ball colour to pink
	love.graphics.setColor(1, 0.75, 0.79)

	-- renders the left side's paddle
	love.graphics.rectangle('fill', 10, player1Y, 5, 20)

	-- renders the right side's paddle
	love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, player2Y, 5, 20)

	-- renders the ball in the center of the screen
	love.graphics.rectangle('fill', ballX, ballY, 4, 4)

	-- ends the rendering at the set virtual resolution
	push:apply('end')
end
