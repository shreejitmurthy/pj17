camera = require "lib.camera"
require "scripts.actor"
wf = require "lib.windfield"

require "scripts.utils"
require "scripts.player"

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
world:addCollisionClass("Player")
world:addCollisionClass("Ground")

platform = {}

cam_x, cam_y = 0, 0

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

    cam = camera(nil, nil, 3)
    local player = state:getActor("player")
    cam_x, cam_y = player.x, player.y
end

function love.update(dt)
    world:update(dt)
    state:update(dt)
    local player = state:getActor("player")

    local lerpSpeed = 8
    cam_x = lerpc(cam_x, player.x, lerpSpeed, dt)
    cam_y = lerpc(cam_y, player.y, lerpSpeed, dt)

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