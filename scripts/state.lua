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