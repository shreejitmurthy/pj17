player = {}
setmetatable(player, {__index = actor})

function player:init()
    local p = actor.new(self, (_G.confw.width / 2), (_G.confw.height / 2), "player")
    setmetatable(p, {__index = player})
    p.img = love.graphics.newImage("res/images/dude.png")
    p.img:setFilter("nearest", "nearest")

    p.maxSpeed = 150
    p.acceleration = 850
    p.deceleration = 1000
    p.jumpForce = 75

    p.controls = {
        left = {"a", "left"},
        right = {"d", "right"},
        jump = {"space", "up"}
    }

    p.vx = 0
    p.collider = world:newBSGRectangleCollider(p.x, p.y, 12, 16, 3)
    p.collider:setFixedRotation(true)
    p.collider:setCollisionClass("Player")
    p.grounded = false

    p.dir = 1

    return p
end

function player:update(dt)
    local vx, vy = self.collider:getLinearVelocity()
    local desiredVX = 0

    if love.keyboard.isDown(self.controls.right) then
        desiredVX = self.maxSpeed
        self.dir = 1
    elseif love.keyboard.isDown(self.controls.left) then
        desiredVX = -self.maxSpeed
        self.dir = -1
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

    self.collider:setLinearVelocity(self.vx, vy)
    self.x, self.y = self.collider:getX(), self.collider:getY()

    if self.collider:enter('Ground') then
        self.grounded = true
    elseif self.collider:exit('Ground') then
        self.grounded = false
    end
end

function player:keypressed(key)
    if (key == "space") and self.grounded then
        self.collider:applyLinearImpulse(0, -self.jumpForce)
    end
end


function player:draw()
    love.graphics.draw(self.img, self.x, self.y, 0, self.dir, 1, 7, 8)
end