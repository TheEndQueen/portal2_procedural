//Biome Factors:
//depth
//control
//weirdness

//required for VScript
function Think() {

}

function dot(vec1, vec2) {
    local result = 0
    
    for (var i = 0; i < 3; i++) {
        result += vec1[i] * vec2[i]
    }
    return result
}
function step(x) {
    return x >= 0 ? 1 : 0
}
class vec3 { //AI :(
    x = 0.0;
    y = 0.0;
    z = 0.0;

    constructor(_x, _y, _z) {
        x = _x.tofloat();
        y = _y.tofloat();
        z = _z.tofloat();
    }

    // The metamethod that enables swizzling
    function _get(key) {
        // Only swizzle for strings between 2 and 4 characters
        if (typeof key == "string" && key.len() >= 2 && key.len() <= 4) {
            local result = [];
            local valid = true;

            // Map characters to their corresponding properties
            for (local i = 0; i < key.len(); i++) {
                local char = key[i]; // Gets ASCII value
                if (char == 'x')      result.append(x);
                else if (char == 'y') result.append(y);
                else if (char == 'z') result.append(z);
                else {
                    valid = false;
                    break;
                }
            }

            if (valid) {
                // Return appropriate vector type based on length
                if (result.len() == 3) {
                    return ::vec3(result[0], result[1], result[2]);
                }
                
                return result; // Fallback to an array if type isn't defined
            }
        }
        
        throw null; // Pass through to standard error handling if property doesn't exist
    }

    function _tostring() {
        return "vec3(" + x + ", " + y + ", " + z + ")";
    }
}
class vec4 { //AI :(
    x = 0.0;
    y = 0.0;
    z = 0.0;
    w = 0.0;

    constructor(_x = 0.0, _y = 0.0, _z = 0.0, _w = 0.0) {
        x = _x.tofloat();
        y = _y.tofloat();
        z = _z.tofloat();
        w = _w.tofloat();
    }

    // Metamethod intercepting property access for undefined fields
    function _get(key) {
        if (typeof key == "string" && key.len() > 1) {
            local components = [];
            
            // Map each character in the swizzle mask back to its field value
            for (local i = 0; i < key.len(); i++) {
                local ch = key[i].tochar();
                if (ch == "x") components.append(x);
                else if (ch == "y") components.append(y);
                else if (ch == "z") components.append(z);
                else if (ch == "w") components.append(w);
                else throw "Invalid swizzle component: " + ch; 
            }
            
            // Instantiate a new vector with the reordered components
            // Pad missing fields with 0.0 up to 4 components
            while (components.len() < 4) {
                components.append(0.0);
            }
            
            return ::vec4(components[0], components[1], components[2], components[3]);
        }
        
        throw null; // Fallback for standard property behavior
    }

    function _tostring() {
        return "vec4(" + x + ", " + y + ", " + z + ", " + w + ")";
    }
}
function mod289v3(vec3) {
  return [
    v[0] - Math.floor(vec3[0] * (1.0 / 289.0)) * 289.0,
    v[1] - Math.floor(vec3[1] * (1.0 / 289.0)) * 289.0,
    v[2] - Math.floor(vec3[2] * (1.0 / 289.0)) * 289.0
  ]
}
function mod289v4(vec4) {
  return [
    v[0] - Math.floor(vec4[0] * (1.0 / 289.0)) * 289.0,
    v[1] - Math.floor(vec4[1] * (1.0 / 289.0)) * 289.0,
    v[2] - Math.floor(vec4[2] * (1.0 / 289.0)) * 289.0,
    v[3] - Math.floor(vec4[3] * (1.0 / 289.0)) * 289.0
  ]
}
function permute(vec4) {
  return [
    mod289(((vec4[0] * 34.0) + 10.0) * vec4[0]),
    mod289(((vec4[1] * 34.0) + 10.0) * vec4[1]),
    mod289(((vec4[2] * 34.0) + 10.0) * vec4[2]),
    mod289(((vec4[3] * 34.0) + 10.0) * vec4[3])
  ]
}
function taylorInvSqrt(vec4)
{
  return [
    1.79284291400159 - 0.85373472095314 * vec4[0],
    1.79284291400159 - 0.85373472095314 * vec4[1],
    1.79284291400159 - 0.85373472095314 * vec4[2],
    1.79284291400159 - 0.85373472095314 * vec4[3]
  ]
}
function fade(vec3) {
  return [
    vec3[0] * vec3[0] * vec3[0] * (vec3[0] * (vec3[0] * 6.0 - 15.0) + 10.0),
    vec3[1] * vec3[1] * vec3[1] * (vec3[1] * (vec3[1] * 6.0 - 15.0) + 10.0),
    vec3[2] * vec3[2] * vec3[2] * (vec3[2] * (vec3[2] * 6.0 - 15.0) + 10.0)
  ]
}
function fract(x) {
    return x - floor(x)
}
//3D Perlin Noise Generator from https://github.com/franky-adl/perlin-noise-3d/blob/main/src/shaders/perlin3d.glsl
function noise(P) {
    vec3 Pi0 = floor(P); // Integer part for indexing
    vec3 Pi1 = Pi0 + vec3(1.0); // Integer part + 1
    Pi0 = mod289(Pi0);
    Pi1 = mod289(Pi1);
    vec3 Pf0 = fract(P); // Fractional part for interpolation
    vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
    vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
    vec4 iy = vec4(Pi0.yy, Pi1.yy);
    vec4 iz0 = Pi0.zzzz;
    vec4 iz1 = Pi1.zzzz;

    vec4 ixy = permute(permute(ix) + iy);
    vec4 ixy0 = permute(ixy + iz0);
    vec4 ixy1 = permute(ixy + iz1);

    vec4 gx0 = ixy0 * (1.0 / 7.0);
    vec4 gy0 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5;
    gx0 = fract(gx0);
    vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
    vec4 sz0 = step(gz0, vec4(0.0));
    gx0 -= sz0 * (step(0.0, gx0) - 0.5);
    gy0 -= sz0 * (step(0.0, gy0) - 0.5);

    vec4 gx1 = ixy1 * (1.0 / 7.0);
    vec4 gy1 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5;
    gx1 = fract(gx1);
    vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
    vec4 sz1 = step(gz1, vec4(0.0));
    gx1 -= sz1 * (step(0.0, gx1) - 0.5);
    gy1 -= sz1 * (step(0.0, gy1) - 0.5);

    vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
    vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
    vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
    vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
    vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
    vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
    vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
    vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

    vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
    g000 *= norm0.x;
    g010 *= norm0.y;
    g100 *= norm0.z;
    g110 *= norm0.w;
    vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
    g001 *= norm1.x;
    g011 *= norm1.y;
    g101 *= norm1.z;
    g111 *= norm1.w;

    float n000 = dot(g000, Pf0);
    float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
    float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
    float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
    float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
    float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
    float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
    float n111 = dot(g111, Pf1);

    vec3 fade_xyz = fade(Pf0);
    vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
    vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
    float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x); 
    return 2.2 * n_xyz;
}
//Sample Seed: 1721038224
function create_biomes(seed) {
    if (seed != null) {
        set_seed = seed
        set_seed2 = (set_seed * 346368023 + 972933077) % 2147483648
        set_seed3 = (set_seed * 972933077 + 346368023) % 2147483648
    }
    depth = array(5000, 1)
    control = noise(set_seed)
    weirdness = noise(set_seed2)
    is_test_track = noise(set_seed3)
    biome <- none
    if (depth <= 1000) { //Depth of Facility, in meters
        if (control <= -0.25) {
            if (is_test_track < 0) { //Overgrown
                if (weirdness >= 0.8) {
                    biome == ovg_office
                } else {
                    biome == ovg_bts
                }
            } else {
                biome == ovg_test
            }
        } else if (control > -0.25 && control <= 0.34) {
            if (is_test_track < 0) { //Reconstructing
                if (weirdness >= 0.8) {
                    biome == reconstruct_office
                } else {
                    biome == reconstruct_bts
                }
            } else {
                biome == reconstruct_test
            }
        } else {
            if (is_test_track < 0) { //Clean
                if (weirdness >= 0.8) {
                    biome == clean_office
                } else {
                    biome == clean_bts
                }
            } else {
                biome == clean_test
            }
        }
    } else if (depth > 1000 && depth <= 2000) {
        if (control <= -0.47) {
            if (is_test_track < 0) { //Destroyed
                if (weirdness >= 0.8) {
                    biome == destroyed_office
                } else {
                    biome == destroyed_bts
                }
            } else {
                biome == destroyed_test
            }
        } else if (control > -0.47 && control <= 0.38) {
            if (is_test_track < 0) { //Clean
                if (weirdness >= 0.8) {
                    biome == clean_office
                } else {
                    biome == clean_bts
                }
            } else {
                biome == clean_test
            }
        } else {
            if (weirdness >= 0.7) { //Clean + Wheatley
                if (is_test_track < 0) {
                    biome == wheatley_bts
                } else {
                    biome == wheatley_test
                }
            } else if (is_test_track < 0) { //Clean
                if (weirdness >= 0.8) {
                    biome == clean_office
                } else {
                    biome == clean_bts
                }
            } else {
                biome == clean_test
            }
        }
    } else if (depth > 2000 && depth <= 2100) {
        biome == transition
    ///////////////
    //UNDERGROUND//
    ///////////////
    } else { 
        if (control <= -0.14) {
            biome == tartaros
        } else if (control > -0.14 && control <= 0.74) {
            if (is_test_track < -0.15) {
                biome == under_office
            } else {
                biome == art_therapy
            }
        } else {
            if (is_test_track < -0.2) {
                biome == under_office
            } else {
                if (weirdness < -0.7) {
                    biome == under_test_cave //Chamber akin to Portal: Revolution Chapter 6
                } else {
                    biome == under_test_sphere
                }
            }
        }
    }
}