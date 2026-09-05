//Biome Factors:
//height
//control
//weirdness

//required for VScript
function Think() {

}

// http://mrl.nyu.edu/~perlin/noise/
// Adapting from p5.js
// which was adapted from PApplet.java
// which was adapted from toxi
// which was adapted from the german demo group farbrausch
// as used in their demo "art": http://www.farb-rausch.de/fr010src.zip

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