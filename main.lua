-- Pong Video Game created in Lua with the LÖVE framework

--[[ push is a library which allows us to draw the game at a virtual resolution
insetad of the size of the window, this is used to create a more retro looking
aesthetic
]]

-- https://github.com/Ulydev/push
push = require 'push'

-- the 'Class' library that is used here will allow us to represent anything in
-- our game as code rather than keeping track of many variables and methods

-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'class'

-- the Paddle class which stores the position and dimensions of each of the
-- paddles and the logic for rendering them on screen
require 'Paddle'

-- the Ball class isn't much different from the Paddle class structure-wise but
-- mechanically they function very differently
require 'Ball'

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

	-- sets the title of the application window
	love.window.setTitle('LÖVE-PONG')

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

	-- initialises the player paddles, makes them global so they can be seen
	-- by other functions/modules
	player1 = Paddle(10, 30, 5, 20)
	player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

	-- positions the vall in the middle of the screen
	ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

	-- game state variable which is used to transition to different play states
	-- (used for the start, menus, main game, leaderboards, etc.), we'll use
	-- this to determine behaviour during rendering and updating
	gameState = 'start'
end

--[[ runs with each frame and takes 'dt' as parameter which is the deltaTime 
that has elapsed since the last frame, this is already supplied by LÖVE 
]]
function love.update(dt)

	if gameState == 'play' then
		-- detects collision of ball with the paddles, reverses dx if true and slightly
		-- increases the ball's velocity, then alters the dy based on collision position
		if ball:collides(player1) then
			ball.dx = -ball.dx * 1.03
			ball.x = player1.x + 5

			-- keep velocity going in the same direction but randomize it
			if ball.dy < 0 then
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end
		end
		
		if ball:collides(player2) then
			ball.dx = -ball.dx * 1.03
			ball.x = player2.x - 4

			-- keep velocity going in the same direction but randomize it
			if ball.dy < 0 then
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end
		end

		-- detect upper and lower screen boundary collisions and reverse if collided with
		if ball.y <= 0 then
			ball.y = 0
			ball.dy = -ball.dy
		end

		-- -4 to account for the ball's size
		if ball.y >= VIRTUAL_HEIGHT - 4 then
			ball.y = VIRTUAL_HEIGHT - 4
			ball.dy = -ball.dy
		end
	end

	-- player 1 movement handling
	if love.keyboard.isDown('w') then
		player1.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('s') then
		player1.dy = PADDLE_SPEED
	else
		player1.dy = 0
	end

	-- player 2 movement handling
	if love.keyboard.isDown('up') then
		player2.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('down') then
		player2.dy = PADDLE_SPEED
	else
		player2.dy = 0
	end

	-- updates the ball based on its DX and DY values only if in the play state;
	-- scales the velocity of the ball by deltaTime so its movement is framerate-independent
	if gameState == 'play' then
		ball:update(dt)
	end

	player1:update(dt)
	player2:update(dt)
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

			-- ball's new reset method
			ball:reset()
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

	-- render paddles by using their class's render method
	player1:render()
	player2:render()

	-- render ball using its class's render method
	ball:render()

	-- function to show the FPS of the application in LÖVE
	displayFPS()

	-- ends the rendering at the set virtual resolution
	push:apply('end')
end

-- renders the current FPS
function displayFPS()
	-- displays the FPS regardless of game state
	love.graphics.setFont(retroFont)
	love.graphics.setColor(0, 1, 0, 1)
	love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 5)
end
