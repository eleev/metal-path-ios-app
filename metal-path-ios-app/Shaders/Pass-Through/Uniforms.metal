//
//  Uniforms.metal
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 06/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

#include <metal_stdlib>
#import "Structs.metal"
using namespace metal;

vertex Vertex vertexUniformFunc(constant Vertex *vertices [[buffer(0)]], constant Uniforms &uniforms [[buffer(1)]], uint vid [[vertex_id]]) {
    
    float4x4 matrix = uniforms.modelMatrix;
    Vertex in = vertices[vid];
    Vertex out;
    out.position = matrix * float4(in.position);
    out.color = in.color;
    
    return out;
}

fragment float4 fragmentUniformFunc(Vertex vert [[stage_in]]) {
    return vert.color;
}



