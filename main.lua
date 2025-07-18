platform = {}

function love.load()
	platform.width = _G.confw.width
	platform.height = _G.confw.height
	platform.x = 0
	platform.y = platform.height / 2
end

function love.update(dt)

end

function love.draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle('fill', platform.x, platform.y, platform.width, platform.height)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end