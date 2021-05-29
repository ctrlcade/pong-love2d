-- Paddle class which represents the paddles which can move upwards & downwards,
-- these are used in the main application to bounce the ball back and forth

Paddle = Class{}

--[[ A class init function is called jsut once when the object is first created, it's
     used to set up all the variables within the class and prepare them for use.
     
     Our paddle should take an X & Y value to be used for paddle positioning as well as
     a width and height for the paddles dimensions.
     
     'self' is a reference to *this* object, whichever object is instatiated at the time
     in which this function is called. Difference objects can have different values for
     each of the variables which shows how these classes serve as containers for data, this
     is similar to how structs work in C.
]]
function Paddle:init(x, y, width, height) 
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0
end

function Paddle:update(dt)
    -- math.max is used to here to ensure that we're greater than 0 or
    -- the players current calculated Y position when moving upwards so
    -- that we don't go into negative values, the movement calculation is
    -- simply our previously-defineds paddle speed scaled by deltaTime
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    -- similar to before but this time math.min is used to ensure we dont
    -- go any farther than the bottom of the screen minus the paddle's height
    -- other wise it will go partially below the screen since its position is based
    -- on its top left corner
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

-- This function is called by the main function in 'love.draw' usually. This uses
-- the 'rectangle' function that LÖVE provides which takes in a drawing mode as the
-- first parameter as well as the position and dimensions of the rectangle. The color
-- can be changed using 'love.graphics.setColor'. Rounded rectangles can also be created
-- within the newer versions of LÖVE
function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
