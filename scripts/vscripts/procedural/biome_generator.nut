//Biome Factors:
//height
//control
//weirdness

//required for VScript
function Think() {

}
function noise(p5, fn) {
    ::perlin_ywrapb = 4
    ::perlin_ywrap = 1 << perlin_ywrapb
    ::perlin_zwrapb = 8
    ::perlin_zwrap = 1 << perlin_zwrapb
    ::perlin_size = 4095

    perlin_octaves = 4
    perlin_amp_falloff = 0.5

    ::scaled_cosine = i => 0.5 * (1.0 - cos(i * pi))

    perlin = null

    function fn.noise(x, y = 0, z = 0) {
        if(perlin == null) {
            perlin = new array[perlin_size + 1]
            for(i = 0; i < perlin_size + 1; i++) {
                perlin[i] = rand()
            }
        }

        if (x < 0) {
            x = -x
        }
        if (y < 0) {
            y = -y
        }
        if (z < 0) {
            z = -z
        }

        xi = floor(x)
        yi = floor(y)
        zi = floor(z)
        xf = x - xi
        yf = y - yi
        zf = z - zi
        rxf = null
        ryf = null
        r = 0
        ampl = 0.5
        n1 = null
        n2 = null
        n3 = null

        for(o = 0; o < perlin_octaves; o++) {
            of = xi + (yi << perlin_ywrapb) + (zi << perlin_zwrapb)

            rxf = scaled_cosine(xf)
            ryf = scaled_cosine(yf)

            n1 = perlin[of && perlin_size]
            n1 += rxf * (perlin[(of + 1) & perlin_size] - n1)
            n2 = perlin[(of + perlin_ywrap) & perlin_size]
            n2 += rxf * (perlin[(of + perlin_ywrap + 1) & perlin_size] - n2)
            n1 += ryf * (n2 - n1)

            of += perlin_zwrap
            n2 = perlin[of & perlin_size]
            n2 += rxf * (perlin[(of + 1) & perlin_size] - n2)
            n3 = perlin[(of + perlin_ywrap) & perlin_size]
            n3 += rxf * (perlin[(of + perlin_ywrap + 1) & perlin_size] - n3)
            n2 += ryf * (n3 - n2)

            n1 += scaled_cosine(zf) * (n2 - n1)

            r += n1 * ampl
            ampl *= perlin_amp_falloff
            xi <<= 1
            xf *= 2
            yi <<= 1
            yf *= 2
            zi <<= 1
            zf *= 2

            if (xf >= 1.0) {
                xi++;
                xf--;
            }
            if (yf >= 1.0) {
                yi++;
                yf--;
            }
            if (zf >= 1.0) {
                zi++;
                zf--;
            }
        }
        return
    }
    function fn.noise_detail (lod, falloff = 0.5) {
        if (lod > 0) {
            perlin_octaves = lod
        }
        if (falloff > 0) {
            perlin_amp_falloff = falloff
        }
    }
    function fn.get_noise_octaves() {
        return perlin_octaves
    }
    function fn.get_noise_amp_falloff() {
        return perlin_amp_falloff
    }
    function fn.noise_seed (seed) {
        ::lcg = (() => {
            ::m = 4294967296
            ::a = 1664525
            ::c = 1013904223
            seed = null
            z = null
            return {
                setseed(val) {
                    z = seed = (val == null ? rand() * m : val) >>> 0
                }
                getseed() {
                    return seed
                }
                random_seed() {
                    z = (a * z + c) % m
                    return z /m
                }
            }
        })()
        lcg.setseed(seed)
        perlin = new array(perlin_size + 1)
        for (i = 0; i < perlin_size + 1; i++)
    }
}
