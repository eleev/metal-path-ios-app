//
//  Uniforms.metal
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 06/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

#include <metal_stdlib>
#include <simd/simd.h>
#import "Structs.metal"

using namespace metal;

vertex Vertex vertexUniformFunc(constant Vertex *vertices [[buffer(0)]], constant Uniforms &uniforms [[buffer(1)]], uint vid [[vertex_id]]) {
    
    // Routines
    
//    float4x4 modelMatrix = uniforms.modelMatrix;
//    float4x4 viewMatrix = uniforms.viewMatrix;
//    float4x4 projectionMatrix = uniforms.projectionMatrix;
//    float4x4 modelViewMatrix = viewMatrix * modelMatrix;
//    float4x4 modelViewProjectionMatrix = projectionMatrix * modelViewMatrix;
    
    // Preparation of variables
    
    Vertex in = vertices[vid];
    Vertex out;
    
    // Vertex projection
    
//    out.position = modelViewProjectionMatrix * float4(in.position);
    out.position = uniforms.modelViewProjectionMatrix * float4(in.position);
    out.color = in.color;
    
    
    return out;
}

fragment float4 fragmentUniformFunc(Vertex vert [[stage_in]]) {
    return vert.color;
}



