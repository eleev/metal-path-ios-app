//
//  Structs.metal
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 06/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
};

struct Uniforms {
//    matrix_float4x4 modelMatrix;
//    matrix_float4x4 viewMatrix;
//    matrix_float4x4 projectionMatrix;
    matrix_float4x4 modelViewProjectionMatrix;

};



