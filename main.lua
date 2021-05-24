-- Pong Video Game created in Lua with the LÖVE framework

-- size of the window where the game is displayed
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

--[[ love.load function is called on game startup, it's used to setup objects,
variables & other game requirements so the game world can be prepared properly.
]]
function love.load()
	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
		fullscreen = false,
		resizable = false,
		vsync = true
	})
end

--[[ love.draw function called each frame after the update function, responsible
for drawing objects & more to the game screen
]]
function love.draw()
	love.graphics.printf(
		'Hello Pong!', 			-- text to be rendered on screen
		0, 						-- starting X coord (set to 0 as will be centered)
		WINDOW_HEIGHT / 2 - 6,  -- starting Y coord (halfway down the game screen)
		WINDOW_WIDTH,			-- number of pixels to center the text in (width of screen)
		'center')				-- mode of allignment, set to 'center' as we want the text centered
end
