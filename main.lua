camera = require "lib.camera"
require "scripts.actor"
wf = require "lib.windfield"

require "scripts.utils"
require "scripts.world"
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


cam_x, cam_y = 0, 0
cam_zoom = 4

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    background = love.graphics.newImage("res/images/InertiaCavernBackgroundGameJam.png")

    state:init(player:init())

    cam = camera(nil, nil, cam_zoom)
    local player = state:getActor("player")
    cam_x, cam_y = player.x, player.y

    sceneCanvas = love.graphics.newCanvas()
    vision_shader = love.graphics.newShader("res/shaders/vision.glsl")

    initMap()
end

function love.update(dt)
    world:update(dt)
    state:update(dt)
    local player = state:getActor("player") 

    local lerpSpeed = 8
    cam_x = lerpc(cam_x, player.x, lerpSpeed, dt)
    cam_y = lerpc(cam_y, player.y, lerpSpeed, dt)

    cam:lookAt(cam_x, cam_y)

    local angle = (player.dir == -1) and math.pi or 0
    local dirVec = { math.cos(angle), math.sin(angle) }

    local sw, sh   = love.graphics.getDimensions()
    local zoom     = cam_zoom            -- e.g. 4
    local cx, cy   = cam_x, cam_y        -- camera world-center

    -- world → screen conversion:
    local ex, ey = player.eye[1], player.eye[2]
    local sx = (ex - cx) * zoom + sw/2
    local sy = (ey - cy) * zoom + sh/2
    vision_shader:send("playerPos", { sx, sy })
    vision_shader:send("playerDir", dirVec)
    vision_shader:send("coneAngle", math.rad(player.fovn))
    vision_shader:send("coneLength", player.length * cam_zoom)

end

local debug = false

function love.draw()
    love.graphics.setBackgroundColor(0.5, 0.5, 0.5)
    local player = state:getActor("player")

    -- cam:attach()
    --     love.graphics.setColor(1, 1, 1)

    --     love.graphics.setShader(vison_shader)
    --     love.graphics.setColor(1, 1, 1)
    --     drawMap()
    --     state:draw()
    --     love.graphics.setShader()

    --     if debug then
    --         world:draw(0.5)
    --         drawMapBorders()
    --         player:debug()
    --     end
    -- cam:detach()

    love.graphics.setCanvas(sceneCanvas)
    love.graphics.clear()
    cam:attach()
        drawMap()
    cam:detach()
    love.graphics.setCanvas()

    love.graphics.setShader(vision_shader)
    love.graphics.setColor(1,1,1)
    love.graphics.draw(sceneCanvas, 0, 0)
    love.graphics.setShader()
    
    cam:attach()
        player:draw(0.3)
        if debug then
            world:draw(0.5)
            drawMapBorders()
            player:debug()
        end
    cam:detach()

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("(" .. math.floor(player.x) .. ", " .. math.floor(player.y) .. ")", 10, 10)
    love.graphics.print("fov: " .. player.fovn, 10, 30)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if key == '/' then
        debug = not debug
    end

    local player = state:getActor("player")
    if player and player.keypressed then
        player:keypressed(key)
    end
end