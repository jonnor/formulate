
static inline float
min(float a, float b) {
    return (a < b) ? a : b;
}

static inline float
max(float a, float b) {
    return (a > b) ? a : b;
}

static inline float
bound(float v, float upper, float lower) {
    return min(max(v, lower), upper);
}

