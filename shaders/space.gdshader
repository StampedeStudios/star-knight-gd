shader_type canvas_item;

uniform float time;
uniform float SPEED = 10.0;

uniform sampler2D noiseTexture;
uniform sampler2D backgroundTexture;
uniform sampler2D planetNormalMap;

uniform vec3 sunColor = vec3(3,2,1);
uniform vec3 sunDir = vec3(-0.363696,0.581914,0.727393);

const vec2 EPSILON = vec2(0, 0.005);

vec2 rotate(vec2 point, float angle) {
    return vec2(cos(angle) * point.x + sin(angle) * point.y, -sin(angle) * point.x + cos(angle) * point.y);
}

float noise(in vec3 position) {

    // Separate the integer and fractional parts of the input vector
    vec3 integerPart = floor(position);
    vec3 fractionalPart = fract(position);

    // Apply a smoothing function to the fractional part
    fractionalPart = fractionalPart * fractionalPart * (3.0 - 2.0 * fractionalPart);

    // Compute texture coordinates
    vec2 textureCoords = (integerPart.xy + vec2(37.0, 17.0) * integerPart.z) + fractionalPart.xy;
    
    // Fetch the texture values
    vec2 textureValues = textureLod(noiseTexture, (textureCoords + 0.5) / 256.0, 0.0).yx;

    // Interpolate between the fetched texture values
    return -1.0 + 2.0 * mix(textureValues.x, textureValues.y, fractionalPart.z);
}

mat4 lookAtMatrix(vec3 position, vec3 target, vec3 up) {
    vec3 direction = normalize(target - position);
    vec3 x = normalize(cross(direction, up));
    vec3 y = cross(x, direction);
    return mat4(vec4(x, 0), vec4(y, 0), vec4(direction, 0), vec4(position, 1));
}

float map(vec3 pos, float z_offset) {
    pos.z -= z_offset;
    pos.xy -= vec2(0.0);
    return length(pos.xy) - 1.0;
}

vec3 normal(vec3 pos, float z_offset) {
    vec2 offset = vec2(0, 0.05);
    return normalize(vec3(map(pos + offset.yxx, z_offset), map(pos + offset.xyx, z_offset), map(pos + offset.xxy, z_offset)) - map(pos, z_offset));
}

float intersectPlanets(vec3 pos, vec3 dir, out vec3 normal, out float maxDistance, out int type) {

    const float PLANET_CYCLE = 100.0;
    const int NUM_PLANETS = 3;

    float best_dist = 1e12;
    bool hit = false;
    maxDistance = -1e12;

    for(int i = 0; i < NUM_PLANETS; i++) {
        int planetType = i;

        if(planetType >= 3) {
            planetType -= 3;
        }

        float modTime = time + 60.0 * float(i);
        float planetRound = floor(modTime / PLANET_CYCLE);
        float planetPos = modTime - planetRound * PLANET_CYCLE;
        float planetAngle = planetRound * 45.0;
        float planetDistance = 50.0 + 10.0 * float(i);
        vec3 planetCenter = vec3(cos(planetAngle) * planetDistance, sin(planetAngle) * planetDistance, (PLANET_CYCLE - planetPos) * 10.0);
        vec3 delta = pos - planetCenter;
        float sphereRadius = 2.0;
    
        float B = dot(dir, delta);
        float C = dot(delta, delta) - sphereRadius * sphereRadius;
        float D = B * B - C;
        
        if(D >= 0.0) {
            float t = -B - sqrt(D);

            vec3 spherePos = pos + t * dir;
            normal = normalize(spherePos - planetCenter);
            best_dist = t;
            type = planetType;
            hit = true;
        }
        maxDistance = max(maxDistance, D);
    }
    return hit ? best_dist : -1.0;
}

float earthHeight(vec3 pos) {

    vec2 coord = vec2(acos(pos.y) / (2.0 * PI), atan(pos.x, pos.z) / (2.0 * PI));
    vec3 te = texture(planetNormalMap, coord).rgb + texture(planetNormalMap, coord * 3.0).rgb * 0.4;
    float landLerp = smoothstep(0.45, 0.5, te.x);
    vec3 albedo = mix(vec3(0.2, 0.2, 0.45), (vec3(0.055, 0.275, 0.0275) + 0.45 * te + te * te * 0.5 * texture(planetNormalMap, 2.0 * coord.xy).xyz) * 0.4, landLerp);
    return length(pos) - albedo.x * 0.015;
}

vec3 backgroundInner(vec3 pos, vec3 dir, bool enableSun, out bool sphereHit, out vec3 spherePos, out vec3 sphereNormal, out vec3 reflectivity) {

    vec3 nebulaPos = dir.yxz;

    float v = noise(nebulaPos * 1.3 + noise(nebulaPos * 0.5) * 3.0) + 0.1;
    vec3 color = vec3(0.5);
    vec2 uv = vec2(cos(dir.y), atan(dir.x, dir.z));
    vec3 a = texture(backgroundTexture, uv * 0.8).rgb;
    vec3 b = texture(backgroundTexture, uv * 0.5).rgb;
    
    color *= (a * b) * 2.0;
    color += pow(texture(backgroundTexture, uv * 2.0).rgb, vec3(2.0)) * 1.5;

    if(enableSun) {
        float sunDot = max(0.0, dot(dir, sunDir));
        color += (pow(sunDot, 8.0) * 0.03 + pow(sunDot, 512.0)) * 5.0 * sunColor;
    }

    sphereHit = false;
    reflectivity = vec3(0.1);
    float max_d;
    int type;
    float t = intersectPlanets(pos, dir, sphereNormal, max_d, type);

    if(t >= 0.0) {
        spherePos = pos + t * dir;
        vec2 coord = vec2(acos(sphereNormal.y) / (2.0 * PI), atan(sphereNormal.x, sphereNormal.z) / (2.0 * PI));
        float time_offset = time * 0.04;
        coord.y += time_offset;

        if(type == 0) {
            float offset = texture(planetNormalMap, coord).r * 0.005;
            vec3 lookup = sphereNormal;
            lookup.xy = rotate(lookup.xy, time_offset * 2.0 * PI);
            float height = noise(lookup * 4.0) * 0.5 + 0.9;
            texture(planetNormalMap, coord + vec2(offset)).r;
            height = pow(min(height, 1.0), 8.0);

            vec3 fire = (texture(planetNormalMap, coord * 5. + time * .02).rgb + texture(planetNormalMap, coord * 1.0 + time * 0.006).rgb) * vec3(3, 1, 1) * 0.5;
            vec3 albedo = texture(planetNormalMap, coord + vec2(offset)).rgb * 0.25 - texture(planetNormalMap, coord * 7.0).rgb * 0.1;
            color = albedo * max(0.0, dot(sphereNormal, sunDir)) * sunColor + fire * pow(1.0 - height, 16.0);

        } else if(type == 2) {
            float offset = texture(planetNormalMap, coord).x * .003;
            vec3 te = texture(planetNormalMap, coord).rgb + texture(planetNormalMap, coord * 3.0).rgb * 0.3;
            vec3 albedo = (texture(planetNormalMap, coord * vec2(0.4, 0) + vec2(offset,0)).rgb - 0.5) * 0.7 + 0.4;

            albedo += texture(planetNormalMap, coord * 1.0).rgb * 0.2;
            albedo += texture(planetNormalMap, coord * 16.0).rgb * 0.075;
            color = albedo * max(0.0, dot(sphereNormal, sunDir)) * sunColor;

        } else if(type == 1) {

            vec3 te = texture(planetNormalMap, coord).rgb + texture(planetNormalMap, coord * 3.0).rgb * 0.3;
            vec3 bumpedNormal = normalize(vec3(earthHeight(sphereNormal + EPSILON.yxx), earthHeight(sphereNormal + EPSILON.xyx), earthHeight(sphereNormal + EPSILON.xxy)) - earthHeight(sphereNormal));
            sphereNormal = bumpedNormal;
            float landLerp = smoothstep(0.45, 0.5, te.x);
            vec3 albedo = mix(vec3(0.1, 0.2, 0.45), (vec3(0.055, 0.275, 0.0275) + 0.45 * te + te * te * 0.5 * texture(planetNormalMap, 2.0 * coord.xy).xyz) * 0.4, landLerp);
            float specPower = mix(2048.0, 32.0, landLerp);

            float q = (texture(planetNormalMap, coord + vec2(0,time * 0.02)).x + texture(planetNormalMap, coord * 2.0 + vec2(0,time * .013)).x) * 0.5;

            float skyLerp = smoothstep(0.4, 0.8, q);
            reflectivity = mix(vec3(0.1), vec3(0.0), skyLerp);

            float NdotL = max(0., dot(sphereNormal, sunDir));
            vec3 opaque = albedo * NdotL * sunColor;
            color = opaque + pow(max(0.0, dot(bumpedNormal, normalize(-dir + sunDir))), specPower) * (specPower + 8.0) / (8.0 * PI) * sunColor * reflectivity;

            vec3 sky = vec3(0.9) * NdotL * sunColor;
            color = mix(color, sky, skyLerp);        
        }

        sphereHit = true;
    }
    
    return color;
}
    
vec3 Background(vec3 pos, vec3 dir) {

    dir = normalize(dir);
    
    bool sphereHit;
    vec3 spherePos;
    vec3 sphereNormal;
    vec3 reflectivity;
    vec3 color = backgroundInner(pos, dir, true, sphereHit, spherePos, sphereNormal, reflectivity);

    if(sphereHit) {
        vec3 R = vec3(0);

        vec3 reflectionDir = reflect(dir,sphereNormal);
        bool dummyHit;
        vec3 dummyPos;
        vec3 dummyNormal;
        color += (backgroundInner(spherePos + sphereNormal * 0.01, reflectionDir, false, dummyHit, dummyPos, dummyNormal, reflectivity) * (1.0 - R) + vec3(1,2,3) * 0.075) * R * sunColor;
    }
    
    return color;
}


vec3 LensFlare(vec2 x, in vec2 iResolution) {

    x = abs(x);
    float e = 1.5;
    float d = pow(pow(x.x * 0.5, e) + pow(x.y * 3.0, e), 1.0 / e);
    
    vec3 c = vec3(exp(-2.5 * d)) * sunColor * (0.3 + sin(x.y * iResolution.y * 2.0) * 0.01) * 0.5;
    c += vec3(exp(-dot(vec3(d), vec3(d)))) * sunColor * 0.05;
    
    return c;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord, in vec2 iResolution) {

    vec2 uv = fragCoord / iResolution.xy;
    vec3 camPos = vec3(0);
    float z_offset = time * SPEED;
 
    float introFade = 1.0;
    
    float camZoom = 1.0;
    
    camPos.xy += vec2(0.0) * 0.1;
    vec3 camTarget = vec3(1, 0, 5);
    camTarget.xy += vec2(0.0) * 0.5;
    camTarget = mix(vec3(3, 0, 5), camTarget, introFade);
    
    float camAngle = 1.0;
    vec3 camUp = vec3(sin(camAngle), cos(camAngle), 0);

    mat4 viewToWorld = lookAtMatrix(camPos, camTarget, camUp);
    vec2 uv2 = (fragCoord - 0.5 * iResolution.xy) / (iResolution.y * camZoom);
    vec3 eyeDir = (viewToWorld * normalize(vec4(uv2, 1, 0))).xyz;
    
    float t = 0.0;
    vec3 p = camPos;
    float iterationCount = 0.0;

    for(int i = 0; i < 70; i++) {

        float dist = map(p, z_offset);
        t += dist;
        p += dist * eyeDir;
        iterationCount++;

        if(abs(dist) < 0.001) {
            break;
        }
    }

    vec3 normal = normal(p, z_offset);
    vec3 refraction = refract(normalize(eyeDir), normal, 1.0);
    vec3 reflection = reflect(-normalize(eyeDir), normal);
    
    vec3 R = vec3(0);
    vec3 c = vec3(1);
    vec3 outColor = Background(p, refraction) * (vec3(1.0) - R) * c + Background(p, -reflection) * R;
    
    float fft = 0.5;
    fft = max(0.0, fft - 0.5);
    
    float tunnelDist = length(p - camPos);
    outColor = outColor * exp(-tunnelDist * .01) + (1.0 - exp(-tunnelDist * 0.05)) * vec3(2, 1, 3) * (0.1 + fft * 0.6);
    
    outColor += sqrt(iterationCount) * 0.005;
    
    vec3 sunPos = (vec4(sunDir, 0) * viewToWorld).xyz;
    vec2 sunUV = sunPos.xy / sunPos.z;

    float vignette = uv.x * (1.0-uv.x) * uv.y * (1.0-uv.y) * 32. * 0.75 + 0.25;
    outColor *= vignette;
    
    vec3 sphereNormal;
    float max_d;
    int type;
    intersectPlanets(camPos, sunDir, sphereNormal, max_d, type);
    float lensIntensity = clamp(1.0 - max_d * 0.02, 0.0, 1.0);
    
    outColor += LensFlare(uv2 - sunUV, iResolution) * lensIntensity;
    outColor += LensFlare(uv2 + sunUV, iResolution) * 0.6 * lensIntensity;

    outColor = clamp(outColor, 0.0, 1.0);
    fragColor = vec4(outColor, 1.0);
}

void fragment() {
    vec2 iResolution = 1.0 / TEXTURE_PIXEL_SIZE;
    mainImage(COLOR, UV * iResolution, iResolution);
}

