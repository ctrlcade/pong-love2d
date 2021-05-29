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
    self.dx = math.random(-50, 50)
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
