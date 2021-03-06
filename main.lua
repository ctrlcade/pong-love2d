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
	scoreFont = love.graphics.newFont('font.ttf', 24)

	-- largest retro font which is used when a player wins and the game is finished
	victoryFont = love.graphics.newFont('font.ttf', 32)

	-- sets LÖVE's active font to the one specified in the retroFont object
	love.graphics.setFont(retroFont)

	-- setup game sound effects, later we can just index into this table and call 
	-- each entry's 'play' method
	sounds = {
		['Paddle-Bounce'] = love.audio.newSource('sounds/Paddle-Bounce.wav', 'static'),
		['Wall-Bounce'] = love.audio.newSource('sounds/Wall-Bounce.wav', 'static'),
		['Score'] = love.audio.newSource('sounds/Score.wav', 'static')
	}

	-- initialises the virutal resolution which is rendered within the actual window
	-- regardless of its dimensions, replaces the love.window.setMode call previously used
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, { 
		fullscreen = false,
		resizable = true,
		vsync = true
	})

	-- initialises score variables which are used for keeping track of the scores
	-- of each  of the players and determining the winner, these are rendered on screen
	player1Score = 0
	player2Score = 0

	-- either will be 1 or 2, whoever gets scored on gets to serve next turn
	servingPlayer = math.random(1, 2)

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

-- called by LÖVE whenever the screen is resizes, here we're just passing in the width
-- and height to push so our virtual resolution can be resized as needed
function love.resize(w, h)
	push:resize(w, h)
end

--[[ runs with each frame and takes 'dt' as parameter which is the deltaTime 
that has elapsed since the last frame, this is already supplied by LÖVE 
]]
function love.update(dt)

	if gameState == 'serve' then
		-- before starting the game and setting the state to play this will
		-- initialise the ball's velocity on whoever last scored
		ball.dy = math.random(-50, 50)
		if servingPlayer == 1 then
			ball.dx = math.random(140, 200)
		else
			ball.dx = -math.random(140, 200)
		end
	elseif gameState == 'play' then
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

			sounds['Paddle-Bounce']:play()
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

			sounds['Paddle-Bounce']:play()
		end

		-- detect upper and lower screen boundary collisions and reverse if collided with
		if ball.y <= 0 then
			ball.y = 0
			ball.dy = -ball.dy
			sounds['Wall-Bounce']:play()
		end

		-- -4 to account for the ball's size
		if ball.y >= VIRTUAL_HEIGHT - 4 then
			ball.y = VIRTUAL_HEIGHT - 4
			ball.dy = -ball.dy
			sounds['Wall-Bounce']:play()
		end

		-- if the ball reaches the left or right screen boundaries then
		-- the game resets and updates the scores
		if ball.x < 0 then
			servingPlayer = 1
			player2Score = player2Score + 1
			sounds['Score']:play()

			-- if a score of 10 has been reached then the game is over, sets the
			-- state to finished so the victory message can be displayed
			if player2Score == 10 then
				winningPlayer = 2
				gameState = 'finished'
				ball:reset()
			else
				gameState = 'serve'
				-- places the static ball in the middle
				ball:reset()
			end
		end

		if ball.x > VIRTUAL_WIDTH then
			servingPlayer = 2
			player1Score = player1Score + 1
			sounds['Score']:play()

			if player1Score == 10 then
				winningPlayer = 1
				gameState = 'finished'
				ball:reset()
			else
				gameState = 'serve'
				ball:reset()
			end
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
	-- if we press enter during either the start or serve phase then it should
	-- transition to the next appropriate state
	elseif key == 'enter' or key == 'return' then
		if gameState == 'start' then
			gameState = 'serve'
		elseif gameState == 'serve' then
			gameState = 'play'
		elseif gameState == 'finished' then
			-- game can be restarted at this point, resets the player scores &
			-- whoever lost the last game gets to serve first for fairness
			gameState = 'serve'
			ball:reset()

			-- reset scores to 0
			player1Score = 0
			player2Score = 0

			-- decide serving player as the loser of the last match
			if winningPlayer == 1 then
				servingPlayer = 2
			else
				servingPlayer = 1
			end
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
		love.graphics.printf('Welcome to LOVE-PONG!', 0, 10, VIRTUAL_WIDTH, 'center')
		love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
	elseif gameState == 'serve' then
		love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
		love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
	elseif gameState == 'play' then
		-- no UI messages to be displayed during gameplay
	elseif gameState == 'finished' then
		-- UI messages to be displayed
		love.graphics.setFont(victoryFont)
		love.graphics.printf('Player ' .. tostring(winningPlayer) .. " wins!", 0, 10, VIRTUAL_WIDTH, 'center')
		love.graphics.setFont(retroFont)
		love.graphics.printf('Press Enter to restart!', 0, 50, VIRTUAL_WIDTH, 'center')
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
