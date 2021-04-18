/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header containing types and enum constants shared between Metal shaders and Swift/ObjC source
*/

#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

struct Uniforms {
    matrix_float4x4 viewMatrix;
    matrix_float4x4 viewProjectionMatrix;
    unsigned int width;
    unsigned int height;
    unsigned int frameIndex;
    vector_float2 jitter;
};

struct PlaneParams {
    unsigned int resolution;
    float invResolution;
    float size;
    float frequency;
    float amplitude;
    float time;
    vector_float2 timeScale;
};

#ifdef __METAL_VERSION__
#define CONSTANT constant
#define vector2 float2
#else
#define CONSTANT static
#endif

// Halton(2, 3) sequence used for temporal antialiasing and shadow ray sampling
CONSTANT vector_float2 haltonSamples[] = {
    vector2(0.5f, 0.333333333333f),
    vector2(0.25f, 0.666666666667f),
    vector2(0.75f, 0.111111111111f),
    vector2(0.125f, 0.444444444444f),
    vector2(0.625f, 0.777777777778f),
    vector2(0.375f, 0.222222222222f),
    vector2(0.875f, 0.555555555556f),
    vector2(0.0625f, 0.888888888889f),
    vector2(0.5625f, 0.037037037037f),
    vector2(0.3125f, 0.37037037037f),
    vector2(0.8125f, 0.703703703704f),
    vector2(0.1875f, 0.148148148148f),
    vector2(0.6875f, 0.481481481481f),
    vector2(0.4375f, 0.814814814815f),
    vector2(0.9375f, 0.259259259259f),
    vector2(0.03125f, 0.592592592593f),
};

#endif

