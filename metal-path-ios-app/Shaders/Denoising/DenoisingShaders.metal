/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Metal shaders used for ray tracing
*/

#include <metal_stdlib>
#include <simd/simd.h>

#import "DenoisingShaderTypes.h"

using namespace metal;

// Maps two uniformly random numbers to a uniform distribution within a cone
float3 sampleCone(float2 u, float cosAngle) {
    float phi = 2.0f * M_PI_F * u.x;
    
    float cos_phi;
    float sin_phi = sincos(phi, cos_phi);
    
    float cos_theta = 1.0f - u.y + u.y * cosAngle;
    float sin_theta = sqrt(1.0f - cos_theta * cos_theta);
    
    return float3(sin_theta * cos_phi, cos_theta, sin_theta * sin_phi);
}

// Aligns a direction such that the "up" direction (0, 1, 0) maps to the given
// surface normal direction
float3 alignWithNormal(float3 sample, float3 normal) {
    // Set the "up" vector to the normal
    float3 up = normal;
    
    // Find an arbitrary direction perpendicular to the normal. This will become the
    // "right" vector.
    float3 right = normalize(cross(normal, float3(0.0072f, 1.0f, 0.0034f)));
    
    // Find a third vector perpendicular to the previous two. This will be the
    // "forward" vector.
    float3 forward = cross(right, up);
    
    // Map the direction on the unit hemisphere to the coordinate system aligned
    // with the normal.
    return sample.x * right + sample.y * up + sample.z * forward;
}

// Vertex shader outputs
struct VertexOut {
    float4 position [[position]];
    float4 prevPosition;
    float3 worldPosition;
    float3 viewPosition;
    float3 normal;
};

// Fragment shader outputs
struct FragmentOut {
    float4 color                [[color(0)]];
    float4 depthNormal          [[color(1)]];
    float2 motionVector         [[color(2)]];
    float4 originMinDistance    [[color(3)]];
    float4 directionMaxDistance [[color(4)]];
};

// Vertex shader for the rasterization pass
vertex VertexOut vertexFunction(uint vid [[vertex_id]],
                                constant Uniforms & uniforms,                    // Current frame's uniform data
                                constant Uniforms & prevUniforms,                // Previous frame's uniform data
                                const device float3 *vertices,                   // Current frame's vertex data
                                const device float3 *prevVertices,               // Previous frame's vertex data
                                const device float3 *normals,                    // Vertex normals
                                const device float4x4 *instanceTransforms,       // Current frame's Instance transformation matrices
                                const device float4x4 *prevInstanceTransforms,   // Previous frame's instance transformation matrices
                                const device float3x3 *instanceNormalTransforms, // Instance normal transformation matrixes
                                constant unsigned int & instanceIndex)           // Index of the current instance being rendered
{
    // Look up vertex position and normal
    float3 prevPosition = prevVertices[vid];
    float3 position = vertices[vid];
    float3 normal = normals[vid];
    
    // Look up transformation matrices
    float4x4 prevTransform = prevInstanceTransforms[instanceIndex];
    float4x4 transform = instanceTransforms[instanceIndex];
    float3x3 normalTransform = instanceNormalTransforms[instanceIndex];
    
    // Compute the world space position for the current and previous frame
    float4 prevWorldPosition = prevTransform * float4(prevPosition, 1.0f);
    float4 worldPosition = transform * float4(position, 1.0f);
    
    VertexOut out;
    
    // Compute the vertex position in NDC space for the current and previous frame
    out.position = uniforms.viewProjectionMatrix * worldPosition;
    out.prevPosition = prevUniforms.viewProjectionMatrix * prevWorldPosition;
    
    // Also output the world space and view space positions for shading
    out.worldPosition = worldPosition.xyz;
    out.viewPosition = (uniforms.viewMatrix * worldPosition).xyz;
    
    // Finally, transform and output the normal vector
    out.normal = normalTransform * normal;
    
    return out;
}

// Fragment shader for the rasterization pass
fragment FragmentOut fragmentFunction(VertexOut in [[stage_in]],
                                      constant Uniforms & uniforms,          // Current frame's uniform data
                                      constant Uniforms & prevUniforms,      // Previous frame's uniform data
                                      texture2d<unsigned int> randomTexture) // Texture containing a random value for each pixel
{
    uint2 pixel = (uint2)in.position.xy;
    
    // The rasterizer will have interpolated the world space position and normal for the fragment
    float3 P = in.worldPosition;
    float3 N = normalize(in.normal);
    
    float2 motionVector = 0.0f;
    
    // Compute motion vectors
    if (uniforms.frameIndex > 0) {
        // Map current pixel location to 0..1
        float2 uv = in.position.xy / float2(uniforms.width, uniforms.height);
        
        // Unproject the position from the previous frame then transform it from
        // NDC space to 0..1
        float2 prevUV = in.prevPosition.xy / in.prevPosition.w * float2(0.5f, -0.5f) + 0.5f;
        
        // Next, remove the jittering which was applied for antialiasing from both
        // sets of coordinates
        uv -= uniforms.jitter;
        prevUV -= prevUniforms.jitter;
        
        // Then the motion vector is simply the difference between the two
        motionVector = uv - prevUV;
    }
    
    unsigned int offset = randomTexture.read(pixel).x;
    
    // Look up two uniformly random numbers for this thread using a low discrepancy Halton
    // sequence. This sequence will ensure good coverage of the light source.
    float2 r = haltonSamples[(offset + uniforms.frameIndex) % 16];
    
    float3 lightDirection = normalize(float3(-0.6f, 1.0f, 0.2f));
    
    // Compute the lighting using a simple diffuse reflection model
    float3 radiance = saturate(dot(N, lightDirection));
    
    // Choose a shadow ray within a small cone aligned with the light direction.
    // This simulates a light source with some non-zero area such as the sun
    // diffused through the atmosphere or a spherical light source.
    float3 sample = sampleCone(r, cos(5.0f / 180.0f * M_PI_F));
    
    lightDirection = alignWithNormal(sample, lightDirection);
    
    // Finally, write out all of the computed values to the render target textures
    FragmentOut out;
    
    out.color = float4(radiance, 1.0f);
    out.depthNormal = float4(length(in.viewPosition), N);
    out.motionVector = motionVector;
    // Add a small offset to the intersection point to avoid intersecting the same
    // triangle again.
    out.originMinDistance = float4(P + N * 1e-3f, 0.0f);
    out.directionMaxDistance = float4(lightDirection, INFINITY);
    
    return out;
}

// Checks if a shadow ray hit something on the way to the light source. If not,
// the point the shadow ray started from was not in shadow so it's color should
// be added to the output image.
kernel void shadowKernel(uint2 tid [[thread_position_in_grid]],
                         constant Uniforms & uniforms,
                         texture2d_array<float> shadowRays,
                         texture2d_array<float> intersections,
                         texture2d<float, access::write> dstTex)
{
    if (tid.x < uniforms.width && tid.y < uniforms.height) {
        float maxDistance = shadowRays.read(tid, 1).w;
        float intersectionDistance = intersections.read(tid, 0).x;
        
        // If the shadow ray was disabled (max distance >= 0) or the shadow ray
        // didn't hit anything on the way to the light source, the original point
        // wasn't in shadow
        if (maxDistance < 0.0f || intersectionDistance < 0.0f)
            dstTex.write(float4(1.0f, 1.0f, 1.0f, 1.0f), tid);
        else
            dstTex.write(float4(0.0f, 0.0f, 0.0f, 1.0f), tid);
    }
}

// Combines the denoised shadow image and original shaded image and
// applies a simple tone mapping operator
kernel void compositeKernel(uint2 tid [[thread_position_in_grid]],
                            constant Uniforms & uniforms,
                            texture2d<float> renderTex,
                            texture2d<float> shadowTex,
                            texture2d<float, access::write> accumTex)
{
    if (tid.x < uniforms.width && tid.y < uniforms.height) {
        float3 color = renderTex.read(tid).xyz * shadowTex.read(tid).x;
                                                  
        // Apply a very simple tone mapping function to reduce the dynamic range of the
        // input image into a range which can be displayed on screen.
        color = color / (1.0f + color);
        
        accumTex.write(float4(color, 1.0f), tid);
    }
}

// Screen filling quad in normalized device coordinates
constant float2 quadVertices[] = {
    float2(-1, -1),
    float2(-1,  1),
    float2( 1,  1),
    float2(-1, -1),
    float2( 1,  1),
    float2( 1, -1)
};

struct CopyVertexOut {
    float4 position [[position]];
    float2 uv;
};

// Simple vertex shader which passes through NDC quad positions
vertex CopyVertexOut copyVertex(unsigned short vid [[vertex_id]]) {
    float2 position = quadVertices[vid];
    
    CopyVertexOut out;
    
    out.position = float4(position, 0, 1);
    out.uv = position * float2(0.5f, -0.5f) + 0.5f;
    
    return out;
}

// Simple fragment shader which copies a texture and applies a simple tone mapping function
fragment float4 copyFragment(CopyVertexOut in [[stage_in]],
                             texture2d<float> tex)
{
    constexpr sampler sam(min_filter::nearest, mag_filter::nearest, mip_filter::none);
    
    float3 color = tex.sample(sam, in.uv).xyz;
    
    return float4(color, 1.0f);
}

// Computes the position and normal of a vertex on the animated plane surface
void computeVertex(unsigned int x,
                   unsigned int z,
                   constant PlaneParams & params,
                   device float3 & position,
                   device float3 & normal)
{
    float u = x * params.invResolution * params.frequency + params.time * params.timeScale.x;
    float v = z * params.invResolution * params.frequency + params.time * params.timeScale.y;
    
    float3 P;
 
    // Scale the X and Z axes and compute the Y axis as the product of cos(u) and sin(v)
    P.x = -params.size / 2.0f + x * params.size * params.invResolution;
    P.y = cos(u) * sin(v) * params.amplitude;
    P.z = -params.size / 2.0f + z * params.size * params.invResolution;
    
    position = P;
    
    float3 dPdx, dPdz;
    
    // Differentiate the position with respect to X and Z. This gives us tangent vectors pointing
    // along the X and Z axes.
    dPdx.x = params.size * params.invResolution;
    dPdx.y = -params.amplitude * sin(u) * sin(v) * params.frequency * params.invResolution;
    dPdx.z = 0.0f;
    
    dPdz.x = 0.0f;
    dPdz.y = params.amplitude * cos(u) * cos(v) * params.frequency * params.invResolution;
    dPdz.z = params.size * params.invResolution;
    
    // The cross product of the tangent vectors is the surface normal
    normal = normalize(cross(dPdz, dPdx));
}

// Updates the vertices for one cell of the animated plane surface
kernel void updatePlaneVerticesKernel(uint2 tid [[thread_position_in_grid]],
                                      constant PlaneParams & params,
                                      device float3 *vertices,
                                      device float3 *normals)
{
    if (tid.x < params.resolution && tid.y < params.resolution) {
        unsigned int vertexIndex = (tid.y * params.resolution + tid.x) * 6;
        
        computeVertex(tid.x + 0, tid.y + 0, params, vertices[vertexIndex + 0], normals[vertexIndex + 0]);
        computeVertex(tid.x + 0, tid.y + 1, params, vertices[vertexIndex + 1], normals[vertexIndex + 1]);
        computeVertex(tid.x + 1, tid.y + 1, params, vertices[vertexIndex + 2], normals[vertexIndex + 2]);
        
        computeVertex(tid.x + 0, tid.y + 0, params, vertices[vertexIndex + 3], normals[vertexIndex + 3]);
        computeVertex(tid.x + 1, tid.y + 1, params, vertices[vertexIndex + 4], normals[vertexIndex + 4]);
        computeVertex(tid.x + 1, tid.y + 0, params, vertices[vertexIndex + 5], normals[vertexIndex + 5]);
    }
}
