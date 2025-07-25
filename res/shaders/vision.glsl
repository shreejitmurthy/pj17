#pragma language glsl3

extern vec2 playerPos;
extern vec2 playerDir;
extern float coneAngle;   // in radians
extern float coneLength;  // in pixels

extern float coneEdgeSoftness;
extern float maxConeBrightness;
extern float ambientModifier;

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 screen_coords) {
    vec4 pixel = texture(tex, uv) * color;

    vec2 toPixel = screen_coords - playerPos;
    float dist = length(toPixel);

    vec2 normToPixel = normalize(toPixel);
    float halfFov = coneAngle * 0.5;
    float ang = acos(dot(normToPixel, normalize(playerDir)));

    // Smoothed angular fade
    float aFall = smoothstep(halfFov, halfFov * (1.0 - coneEdgeSoftness), ang);

    // Smoothed radial fade (outer cone)
    float dFall = smoothstep(coneLength, coneLength * 0.75, dist);

    // Smoothed fade-in near eye
    float nearFade = smoothstep(coneLength * 0.005, coneLength * 0.05, dist);

    // Combine and clamp
    float visibility = clamp(aFall * dFall * nearFade, 0.0, 1.0);

    // Ambient blending for soft outer area
    vec3 ambient = pixel.rgb * ambientModifier;
    pixel.rgb = mix(ambient, pixel.rgb * maxConeBrightness, visibility);

    return pixel;
}
