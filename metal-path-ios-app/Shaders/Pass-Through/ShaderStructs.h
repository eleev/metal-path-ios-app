//
//  ShaderStructs.h
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 16/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

#ifndef ShaderStructs_h
#define ShaderStructs_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif

#include <simd/simd.h>


typedef struct
{
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 modelViewMatrix;
    matrix_float4x4 modelViewProjectionMatrix;
} Uniform;


#endif /* ShaderStructs_h */
