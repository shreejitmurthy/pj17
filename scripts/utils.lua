function math.sign(x)
    return x < 0 and -1 or (x > 0 and 1 or 0)
end

function lerpc(v, g, s, dt)
    v = v + (g - v) * math.min(s * dt, 1)
    return v
end