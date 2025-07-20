require "lib.spritesheet"

states = {
    IDLE = 0,
    RUN = 1,
    JUMP = 2,
}

player = {}
setmetatable(player, {__index = actor})

function player:init()
    local p = actor.new(self, 50, 10, "player")
    setmetatable(p, {__index = player})
    p.img = love.graphics.newImage("res/images/dude.png")
    -- p.img:setFilter("nearest", "nearest")

    p.maxSpeed = 100
    p.acceleration = 850
    p.deceleration = 1000
    p.jumpForce = 50

    p.controls = {
        left = {"a", "left"},
        right = {"d", "right"},
        jump = {"space", "up"}
    }

    p.vx = 0
    p.vy = 0
    p.collider = world:newBSGRectangleCollider(p.x, p.y, 12, 16, 3)
    p.collider:setFixedRotation(true)
    p.collider:setCollisionClass("Player")
    p.grounded = false

    p.dir = 1

    p.state = states.IDLE

    p.animations = {}
    p.spritesheet1 = newSpritesheet("res/images/player/atlas.png", 16, 16, 0, 0)
    p.animations.idle = p.spritesheet1:newAnimation({1, 5}, {1, 6}, 0.3)
    p.animations.run = p.spritesheet1:newAnimation({1, 1}, {1, 4}, 0.1)
    p.current_animation = p.animations.idle

    return p
end

function player:update(dt)
    local _, vy = self.collider:getLinearVelocity()
    local desiredVX = 0

    if love.keyboard.isDown(self.controls.right) then
        desiredVX = self.maxSpeed
        self.dir = 1
        self.state = states.RUN
    elseif love.keyboard.isDown(self.controls.left) then
        desiredVX = -self.maxSpeed
        self.dir = -1
        self.state = states.RUN
    else
        self.state = states.IDLE
    end

    -- Accelerate or decelerate
    if desiredVX ~= 0 then
        local change = self.acceleration * dt
        if math.abs(self.vx - desiredVX) < change then
            self.vx = desiredVX
        else
            self.vx = self.vx + math.sign(desiredVX - self.vx) * change
        end
    else
        local change = self.deceleration * dt
        if math.abs(self.vx) < change then
            self.vx = 0
        else
            self.vx = self.vx - math.sign(self.vx) * change
        end
    end

    self.vy = vy
    self.collider:setLinearVelocity(self.vx, self.vy)
    self.x, self.y = self.collider:getX(), self.collider:getY()

    if self.collider:enter('Ground') then
        self.grounded = true
    elseif self.collider:exit('Ground') then
        self.grounded = false
    end

    if self.state == states.IDLE then
        self.current_animation = self.animations.idle
    elseif self.state == states.RUN then
        self.current_animation = self.animations.run
    end

    if self.y > map_height then
        self.collider:setPosition(50, 10)
    end

    self.current_animation:flipV(self.dir)
    self.current_animation:update(dt)
end

function player:keypressed(key)
    if (key == "space") and self.grounded then
        self.collider:applyLinearImpulse(0, -self.jumpForce)
    end
end

local py_offset = 0.5

function player:draw()
    self.spritesheet1:draw(self.current_animation, self.x, self.y + py_offset)
end