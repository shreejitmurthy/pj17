function math.sign(x)
    return x < 0 and -1 or (x > 0 and 1 or 0)
end

camera = require "lib.camera"
require "scripts.actor"
wf = require "lib.windfield"

state = {
    actors = {},
    canvas = nil,
}

function state:init(...)
    self.canvas = love.graphics.newCanvas()
    local args = { ... }
    for _, actor in ipairs(args) do
        self.actors[#self.actors+1] = actor
    end
end

function state:getActor(label)
    for _, actor in ipairs(self.actors) do
        if actor.label == label then
            return actor
        end
    end
    return nil
end

function state:update(dt)
    for _, actor in ipairs(self.actors) do
        actor:update(dt)
    end
end

function state:draw()
    for _, actor in ipairs(self.actors) do
        actor:draw()
    end
end

world = wf.newWorld(0, 600, true)
-- world:setQueryDebugDrawing(true)
world:addCollisionClass("Player")
world:addCollisionClass("Ground")

platform = {}

cam_x, cam_y = 0, 0

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

function love.load()
    platform.width = _G.confw.width
    platform.height = 40
    platform.x = 0
    platform.y = _G.confw.height / 2 + 60

    -- Create a static ground collider
    platform.collider = world:newRectangleCollider(platform.x, platform.y, platform.width, platform.height)
    platform.collider:setType("static")
    platform.collider:setCollisionClass("Ground")

    state:init(player:init())

    cam = camera(nil, nil, 4)
    local player = state:getActor("player")
    cam_x, cam_y = player.x, player.y
end

function lerp(v, g, s, dt)
    v = v + (g - v) * math.min(s * dt, 1)
end

function love.update(dt)
    world:update(dt)
    state:update(dt)
    local player = state:getActor("player")

    local lerpSpeed = 8
    cam_x = cam_x + (player.x - cam_x) * math.min(lerpSpeed * dt, 1)
    cam_y = cam_y + (player.y - cam_y) * math.min(lerpSpeed * dt, 1)
    -- lerp(cam_x, player.x, lerpSpeed, dt)

    cam:lookAt(cam_x, cam_y)
end

function love.draw()
    love.graphics.setBackgroundColor(0.5, 0.5, 0.5)
    local player = state:getActor("player")
    love.graphics.setColor(1, 1, 1)
    cam:attach()
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle('fill', platform.x, platform.y, platform.width, platform.height)
        love.graphics.setColor(1, 1, 1)
        state:draw()
        -- world:draw(0.5)
    cam:detach()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("(" .. math.floor(player.x) .. ", " .. math.floor(player.y) .. ")", 10, 10)
    love.graphics.print(tostring(player.grounded), 10, 30)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    local player = state:getActor("player")
    if player and player.keypressed then
        player:keypressed(key)
    end
end