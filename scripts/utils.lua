function math.sign(x)
    return x < 0 and -1 or (x > 0 and 1 or 0)
end

function lerpc(v, g, s, dt)
    v = v + (g - v) * math.min(s * dt, 1)
    return v
end

function angleDiff(a, b)
    local d = (a - b) % (2*math.pi)
    if d > math.pi then d = d - 2*math.pi end
    return d
end

-- helper to lerp angles
function lerpAngle(a, b, t)
    local d = (b - a + math.pi) % (2*math.pi) - math.pi
    return a + d * t
end

function normalizeAngle(a)
    return (a + math.pi * 2) % (math.pi * 2)
end
