--[[
    MIT License

    Copyright (c) 2025 Shreejit Murthy

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]

local Spritesheet = {}
Spritesheet.__index = Spritesheet

local Animation = {}
Animation.__index = Animation

function Animation.new(frames, delay, left, top, loop)
    return setmetatable({
        frames = frames,
        delay = delay,
        top = top or 0,
        left = left or 0,
        flipv = 1,
        r = 0,
        currentTime = 0,
        currentIndex = 1,
        loop = loop or true,
    }, Animation)
end

---@param spritesheet_path string
---@param frameWidth integer
---@param frameHeight integer
function newSpritesheet(spritesheet_path, frameWidth, frameHeight)
    local self = setmetatable({}, Spritesheet)
    self.path = spritesheet_path
    self.image = love.graphics.newImage(self.path)
    self.frameWidth = frameWidth
    self.frameHeight = frameHeight
    return self
end

function Spritesheet:getFrames(sx, sy, fx, fy)
    local frames = {}
    for y = sy, fy do
        for x = sx, fx do
            local quad = love.graphics.newQuad(
                ((x - 1) * self.frameWidth),
                ((y - 1) * self.frameHeight),
                self.frameWidth,
                self.frameHeight,
                self.image:getDimensions()
            )
            frames[#frames+1] = quad
        end
    end

    return frames
end

function Spritesheet:newAnimation(s, f, delay, left, top, loop)
    if not delay then
        error("No delay value given to animation (" .. self.path .. ")")
    end
    local sx, sy = unpack(s)
    local fx, fy = unpack(f)
    local frames = self:getFrames(sy, sx, fy, fx)

    return Animation.new(frames, delay, left, top, loop)
end

function Animation:update(dt)
    self.currentTime = self.currentTime + dt
    if self.currentTime >= self.delay then
        self.currentTime = self.currentTime - self.delay
        self.currentIndex = (self.currentIndex % #self.frames) + 1
        if self.currentIndex > #self.frames then
            self.currentIndex = 1
        end
    end
end

function Animation:flipV(n)
    self.flipv = n
end

function Animation:rotate(r)
    self.r = r
end

function Spritesheet:draw(animation, x, y, debug)
    local quad = animation.frames[animation.currentIndex]
    ox, oy = self.frameHeight / 2, self.frameHeight / 2
    love.graphics.push()
    love.graphics.translate(animation.left, -animation.top)
    love.graphics.draw(self.image, quad, x, y, self.r, animation.flipv, 1, ox, oy)
    if debug then
        love.graphics.rectangle("line", x, y, self.frameWidth, self.frameHeight)
        love.graphics.print(tostring(animation.currentIndex), x + self.frameWidth + 3, y)
    end
    love.graphics.pop()
end