require "lib.spritesheet"

states = {
    IDLE = 0,
    RUN = 1,
    BACKRUN = 2,
    JUMP = 3,
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

    p.reverse_running = false

    p.dir = 1

    p.eye_y = 9   -- 9 pixels from top of frame
    p.eye_x = 11  -- 11 pixels from the left of frame
    p.eye = {}
    p.fovn = 45
    p.length = 85
    p.visionAngle = 0
    p.coneTurnSpeed = 15
    p.visionDir = 1

    p.state = states.IDLE

    p.animations = {}
    p.spritesheet1 = newSpritesheet("res/images/player/atlas.png", 16, 16)
    p.animations.idle = p.spritesheet1:newAnimation({1, 5}, {1, 6}, 0.3)
    p.animations.idle_closed = p.spritesheet1:newAnimation({1, 7}, {1, 8}, 0.3)
    p.animations.run = p.spritesheet1:newAnimation({1, 1}, {1, 4}, 0.1)
    p.animations.run_reverse = p.spritesheet1:newAnimation({2, 1}, {2, 4}, 0.2)
    p.current_animation = p.animations.idle

    return p
end

function player:update(dt)
    local _, vy = self.collider:getLinearVelocity()
    local desiredVX = 0

    self.visionDir = self:getVisionDir()
    local inputDir = 0

    if love.keyboard.isDown(self.controls.right) then
        inputDir = 1
    elseif love.keyboard.isDown(self.controls.left) then
        inputDir = -1
    end

    if inputDir ~= 0 then
        self.dir = inputDir

        if inputDir ~= self.visionDir then
            desiredVX = self.maxSpeed * 0.5 * inputDir
            self.state = states.BACKRUN
        else
            desiredVX = self.maxSpeed * inputDir
            self.state = states.RUN
        end
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
    elseif self.state == states.BACKRUN then
        self.current_animation = self.animations.run_reverse
    end

    if self.y > map_height then
        self.collider:setPosition(50, 10)
    end

    -- local dir = self.dir == self.visionDir and self.dir or self.visionDir
    local eyeOffsetDir = self.visionDir or 1
    self.eye = {
        self.x + (self.eye_x / 2 - 2.75 --[[ -2.75 to bring into image --]]) * eyeOffsetDir, 
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

function player:getVisionDir()
    local angle = self.visionAngle % (2 * math.pi)
    return (angle > math.pi / 2 and angle < 3 * math.pi / 2) and -1 or 1
end

function player:debugVisionCone(segments, fill)
    segments = segments or 20
    fill = fill or false

    local points = self.eye
    local startAngle = self.visionAngle - math.rad(self.fovn) / 2
    local angleStep = math.rad(self.fovn) / segments

    for i = 0, segments do
        local angle = startAngle + i * angleStep
        local px = points[1] + math.cos(angle) * self.length
        local py = points[2] + math.sin(angle) * self.length
        table.insert(points, px)
        table.insert(points, py)
    end

    if fill then
        love.graphics.setColor(1, 1, 0, 0.3)  -- yellowish translucent
        love.graphics.polygon("fill", points)
    end

    love.graphics.setColor(1, 1, 0, 0.6)
    love.graphics.polygon("line", points)

    love.graphics.setColor(1, 1, 1, 1)  -- reset color
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

-- function player:getDirVec(dt)
--     local mx, my = cam:mousePosition()
--     local px, py = self.eye[1], self.eye[2]
--     local targetAngle = math.atan2(my - py, mx - px)
--     if targetAngle < 0 then targetAngle = targetAngle + 2*math.pi end

--     -- hysteresis: only flip when clearly in one hemisphere
--     if targetAngle > leftEntry and targetAngle < leftExit then
--         self.dir = -1
--     elseif targetAngle < rightEntry or targetAngle > rightExit then
--         self.dir = 1
--     end

--     self.visionAngle = lerpAngle(self.visionAngle, targetAngle, self.coneTurnSpeed * dt)
--     return { math.cos(self.visionAngle), math.sin(self.visionAngle) }
-- end

-- above your code, once:
local COS_RIGHT  = math.cos(math.rad(80))   -- ~+0.1736
local COS_LEFT   = math.cos(math.rad(100))  -- ~–0.1736

function player:getDirVec(dt)
    local visionVec
    local mx, my = cam:mousePosition()
    local px, py = self.x, self.y

    local rawA = math.atan2(my - py, mx - px)
    if rawA < 0 then rawA = rawA + 2*math.pi end

    self.visionAngle = lerpAngle(self.visionAngle, rawA, self.coneTurnSpeed * dt)

    local c = math.cos(rawA)
    if     c >  COS_RIGHT then self.visionDir =  1
    elseif c <  COS_LEFT  then self.visionDir = -1
    end

    self.dir = self.visionDir

    visionVec = { math.cos(self.visionAngle), math.sin(self.visionAngle) }
    return visionVec
end


function player:getConeAngle()
    return math.rad(self.fovn)
end

function player:getConeLength()
    return self.length * cam_zoom
end