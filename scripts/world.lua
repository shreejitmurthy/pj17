sti = require "lib.sti"

world = wf.newWorld(0, 600, true)
world:addCollisionClass("Player")
world:addCollisionClass("Ground")

gameMap = sti("res/maps/test.lua")

function createCollidable(object, collisionClass)
    local collidable
    if object.shape == "rectangle" then
        collidable = world:newRectangleCollider(object.x, object.y, object.width, object.height)
    elseif object.shape == "polygon" then
        local vertices = {}
        for _, vertex in pairs(object.polygon) do
            vertices[#vertices+1] = vertex.x
            vertices[#vertices+1] = vertex.y
        end
        collidable = world:newPolygonCollider(vertices)
    end
    if collidable then
        collidable:setType('static')
        collidable:setCollisionClass(collisionClass)
        collidable:setObject(collidable)
    end
    return collidable
end

function processLayer(layerName, collisionClass)
    if gameMap.layers[layerName] then
        for _, object in pairs(gameMap.layers[layerName].objects) do
            local collidable = createCollidable(object, collisionClass)
            if collidable then
                collidables[#collidables+1] = collidable
            end
        end
    end
end

function init_map()
    collidables = {}

    processLayer("Ground", "Ground")
    -- processLayer("Things you cant hold", "Unholdables")

    -- if gameMap.layers["Climbable"] then
    --     for _, object in pairs(gameMap.layers["Climbable"].objects) do
    --         if object.shape == "rectangle" then
    --             local zone = newZone(object.x, object.y, object.width, object.height)
    --             zone:addType("pole")
    --         end
    --     end
    -- end
end

function draw_map()
    gameMap:drawLayer(gameMap.layers["Ground"])
    -- gameMap:drawLayer(gameMap.layers["Water"])
    -- gameMap:drawLayer(gameMap.layers["Grass"])
    -- zone:drawAll()
end