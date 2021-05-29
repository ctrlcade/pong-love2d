-- Ball class which will represent a ball which bounces back and forth between 
-- the paddles & wall until it hits one of the screen boundaries which will 
-- result in a point for one of the players.

Ball = Class{}

-- Ball constructor method
function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    
    -- these variables are used to keep track of the ball's velocity on both the
    -- X & Y axis since the ball can move in two dimensions
    self.dy = math.random(2) == 1 and 100 or -100
    self.dx = math.random(2) == 1 and math.random(-80, -100) or math.random(80, 100)
end

-- takes a paddle object as an argument and returns either true or false depending
-- on whether their rectangles overlap (collide)
function Ball:collides(paddle)
    -- first, check to see if the left edge of either of the rectangles is farther to the
    -- right than the right edge of the other
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either of the rectangles is higher than
    -- the top edge of the other
    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end

    -- if the above statements aren't true then they're overlapping (colliding)
    return true
end

-- positions the ball on the middle of the screen with an initial random velocity
function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.dy = math.random(2) == 1 and 100 or -100
    self.dx = math.random(-50, 50)
end

-- applies velocity scaled by deltaTime to the balls position
function Ball:update(dt) 
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

-- renders the ball onto the screen at its current position
function Ball:render() 
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
