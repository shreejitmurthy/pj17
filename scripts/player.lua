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

    p.eye_y = 9   -- 9 pixels from top of frame
    p.eye_x = 11  -- 11 pixels from the left of frame
    p.eye = {}
    p.fovn = 45
    p.length = 85
    p.visionAngle = 0
    p.coneTurnSpeed = 15

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

    self.eye = {
        self.x + (self.eye_x / 2 - 2.75 --[[ -2.75 to bring into image --]]) * self.dir, 
        self.y + 1 --[[ +1 to account for idle anim --]]
    }

    self.current_animation:flipV(self.dir)
    self.current_animation:update(dt)
end

function player:keypressed(key)
    if (key == "space") and self.grounded then
        self.collider:applyLinearImpulse(0, -self.jumpForce)
    end

    if key == 'up' then
        self.fovn = self.fovn + 5
    elseif key == 'down' then
        self.fovn = self.fovn - 5
    end
end

function player:debugVisionCone(segments, fill)
    segments = segments or 20  -- Number of segments to smooth the cone
    fill = fill or false

    local points = self.eye  -- Start at the player's eye
    local startAngle = (self.dir == -1 and math.pi or 0) - math.rad(self.fovn) / 2
    local angleStep = math.rad(self.fovn) / segments

    for i = 0, segments do
        local angle = startAngle + i * angleStep
        local px = points[1] + math.cos(angle) * self.length
        local py = points[2] + math.sin(angle) * self.length
        table.insert(points, px)
        table.insert(points, py)
    end

    if fill then
        love.graphics.setColor(1, 1, 0, 0.3) -- yellowish translucent
        love.graphics.polygon("fill", points)
    end

    love.graphics.setColor(1, 1, 0, 0.6)
    love.graphics.polygon("line", points)

    love.graphics.setColor(1, 1, 1, 1) -- reset color
end

local py_offset = 0.5

function player:draw(alpha)
    love.graphics.setColor(1, 1, 1, alpha)
    self.spritesheet1:draw(self.current_animation, self.x, self.y + py_offset)
    love.graphics.setColor(1, 1, 1, 1)
end

function player:debug()
    love.graphics.setColor(1, 1, 0)
    love.graphics.circle("fill", self.eye[1], self.eye[2], 0.5)
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", self.x, self.y, 1)

    self:debugVisionCone()
end

function player:getWorldPos()
    local cx, cy = cam_x, cam_y
    local sw, sh = love.graphics.getDimensions()
    local ex, ey = self.eye[1], self.eye[2]
    local sx = (ex - cx) * cam_zoom + sw / 2
    local sy = (ey - cy) * cam_zoom + sh / 2
    return {sx, sy}
end

function player:getDirVec(dt)
    local mx, my = cam:mousePosition()
    local px, py = self.eye[1], self.eye[2]
    local dx, dy = mx - px, my - py

    local targetAngle = math.atan2(dy, dx)
    if targetAngle < 0 then
        targetAngle = targetAngle + math.pi * 2
    end

    -- Clamp target angle based on facing direction
    if self.dir == 1 then
        -- Right-facing: allow [270° → 360°] and [0° → 90°]
        if targetAngle > math.rad(90) and targetAngle < math.rad(270) then
            if targetAngle < math.pi then
                targetAngle = math.rad(90)
            else
                targetAngle = math.rad(270)
            end
        end
    else
        -- Left-facing: clamp to [90°, 270°]
        targetAngle = math.max(math.rad(90), math.min(math.rad(270), targetAngle))
    end
    self.visionAngle = lerpAngle(self.visionAngle, targetAngle, self.coneTurnSpeed * dt)

    return { math.cos(self.visionAngle), math.sin(self.visionAngle) }
end

function player:getConeAngle()
    return math.rad(self.fovn)
end

function player:getConeLength()
    return self.length * cam_zoom
end