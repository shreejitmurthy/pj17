camera = require "lib.camera"
require "scripts.actor"
wf = require "lib.windfield"

require "scripts.utils"
require "scripts.world"
require "scripts.player"
require "scripts.state"

cam_x, cam_y = 0, 0
cam_zoom = 4

coneEdgeSoftness = 0.4
maxConeBrightness = 0.75
ambientModifier = 0.23

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.mouse.setVisible(false)

    background = love.graphics.newImage("res/images/InertiaCavernBackgroundGameJam.png")

    state:init(player:init())

    cam = camera(nil, nil, cam_zoom)
    local player = state:getActor("player")
    cam_x, cam_y = player.x, player.y

    scene_canvas = love.graphics.newCanvas()
    vision_shader = love.graphics.newShader("res/shaders/vision.glsl")

    initMap()
end

function love.update(dt)
    world:update(dt)
    state:update(dt)
    local player = state:getActor("player") 

    if player then
        local lerpSpeed = 8
        cam_x = lerpc(cam_x, player.x, lerpSpeed, dt)
        cam_y = lerpc(cam_y, player.y, lerpSpeed, dt)

        cam:lookAt(cam_x, cam_y)

        vision_shader:send("playerPos", player:getWorldPos())
        vision_shader:send("playerDir", player:getDirVec(dt))
        vision_shader:send("coneAngle", player:getConeAngle())
        vision_shader:send("coneLength", player:getConeLength())
        vision_shader:send("coneEdgeSoftness", coneEdgeSoftness)
        vision_shader:send("maxConeBrightness", maxConeBrightness)
        vision_shader:send("ambientModifier", ambientModifier)
    end
end

local debug = false

function love.draw()
    love.graphics.setBackgroundColor(0.5, 0.5, 0.5)
    local player = state:getActor("player")

    drawScene(scene_canvas, vision_shader, drawMap)
    
    if player then
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