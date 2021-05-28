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

--[[ love.load function is called on game startup, it's used to setup objects, 
variables & other game requirements so the game world can be prepared properly
]]
function love.load()

	-- uses nearest-neighbor filtering when upscaling and downscaling to prevent
	-- blurry text & graphics, without this bilinear filtering would be used by default
	love.graphics.setDefaultFilter('nearest', 'nearest')

	-- initialises the virutal resolution which is rendered within the actual window
	-- regardless of its dimensions, replaces the love.window.setMode call previously used
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, { 
		fullscreen = false,
		resizable = false,
		vsync = true
	})
end

-- keyboard handling, called by LÖVE every frame and passes key pressed as parameter
function love.keypressed(key)
	-- keys can be accessed with a string name
	if key == 'escape' then
		-- LÖVE's quit event function terminates the application
		love.event.quit()
	end
end

--[[ love.draw function called each frame after the update function, responsible
for drawing objects & more to the game screen
]]
function love.draw() 
	-- starts the rendering at the set virtual resolution
	push:apply('start')

	-- condensed into single line
	-- now using the set virtual width and height for the text placement on the screen
	love.graphics.printf('Hello Pong!', 0, VIRTUAL_HEIGHT / 2 - 6, VIRTUAL_WIDTH,'center')

	-- ends the rendering at the set virtual resolution
	push:apply('end')

end
