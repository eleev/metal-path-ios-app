//
//  iRender.swift
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 22/02/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation
import Metal
import MetalKit

/// Custon derivative from the MTKView that adds suport for custom renderer and is responsible for shader compilation, attachment, buffers and encoders
class MetalView: MTKView {
    
    // MARK: - Typealiases
    
    typealias RenderShaderPair = (vertexFunction: MTLFunction, fragmentFunction: MTLFunction)
    typealias Update = (_ vertex: MTLBuffer?, _ index: MTLBuffer?, _ uniform: MTLBuffer?)->Void
    
    // MARK: - Properties
    
    var shaderPair: ShaderPair
    
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?
    var uniformBuffer: MTLBuffer?
    
    
    /// The closure is used as an injection point when updating scene in the update loop. User should set a custom function here to be able to update custom logic
    var updateClosure: Update?
    
    // MARK: - Private properties
    
    private(set) var renderPipelineState: MTLRenderPipelineState?
    
    private(set) var defaultCommandQueue: MTLCommandQueue?
    private(set) var defaultCommandBuffer: MTLCommandBuffer?
    private(set) var defaultRenderCommandEncoder: MTLRenderCommandEncoder?
    private(set) var defaultRenderPassDescriptor: MTLRenderPassDescriptor?
    
    
    // MARK: - Initilziers
    
    init(frame frameRect: CGRect, device: MTLDevice?, shaders pair: ShaderPair) {
        self.shaderPair = pair
        
        super.init(frame: frameRect, device: device)
        self.device = device
        
        do {
            let vertexShaderName = pair.vertexShader.name
            let fragmentShaderName = pair.fragmentShader.name
            
            let shadersPair = try attachShaderPair(vertexShaderName: vertexShaderName, fragmentShaderName: fragmentShaderName)
            let renderPipelineDescriptor = createRenderPipelineDescriptor(shaders: shadersPair)
            
            renderPipelineState = try self.device?.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
            
        } catch {
            debugPrint(#function + " raised error: ", error)
        }
        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        defaultRenderPassDescriptor = prepareRenderPassDescriptor()
        
        do {
            try render()
        } catch {
            debugPrint(#function + " thrown the following error: ", error)
        }
        
        updateClosure?(vertexBuffer, indexBuffer, uniformBuffer)
    }
    
    // MARK: - Private Methods
    
    /// This function is called every frame by the overriden draw(:CGRect) function. The main responsibility is to provide means that clear screen, specify render pass descriptors (RPDs), textures, buffers and everything related to graphics rendering
    ///
    /// - Throws: may throw missing attachments, such as missing drawable target for instance
    private func render() throws {

        guard let renderPipelineState = renderPipelineState else {
            debugPrint(#function + " render pipeline state has not been set or something went horribly wrong")
            throw RenderErrorType.missingRPS
        }

        guard let defaultRenderPassDescriptor = defaultRenderPassDescriptor else {
            debugPrint(#function + " render pass descriptor has not been set or something went horribly wrong")
            throw RenderErrorType.missingRPS
        }
        
        // Create default queues and buffers
        defaultCommandQueue = device?.makeCommandQueue()
        defaultCommandBuffer = defaultCommandQueue?.makeCommandBuffer()
        
        defaultRenderCommandEncoder = defaultCommandBuffer?.makeRenderCommandEncoder(descriptor: defaultRenderPassDescriptor)
        defaultRenderCommandEncoder?.setRenderPipelineState(renderPipelineState)
        
        // Perspective rendering
        defaultRenderCommandEncoder?.setFrontFacing(.counterClockwise)
        defaultRenderCommandEncoder?.setCullMode(.back)
        
        // NOTE: - All buffer bindings must be set before primitive drawing (either vertex or index) - otherwise render command encoder will not be able to do its job.
        
        if let uniformBuffer = uniformBuffer {
            defaultRenderCommandEncoder?.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        }

        // The following code performs primitive drawing without taking into account indicies of geometry primitive
        /*
        if let buffer = vertexBuffer {
            defaultRenderCommandEncoder?.setVertexBuffer(buffer, offset: 0, index: 0)
            // Vertex primitive drawing
            defaultRenderCommandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        }
         */
        
        if let indexBuffer = indexBuffer, let vertexBuffer = vertexBuffer {
            defaultRenderCommandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            
            let indexCount = indexBuffer.length / MemoryLayout<UInt16>.size
            // Indexed primitive drawing
            defaultRenderCommandEncoder?.drawIndexedPrimitives(type: .triangle,
                                                               indexCount: indexCount,
                                                               indexType: MTLIndexType.uint16,
                                                               indexBuffer: indexBuffer,
                                                               indexBufferOffset: 0)
        }
        
        // Make sure that current drawable exsists
        guard let drawable = currentDrawable else {
            debugPrint(#function + " drawable was not specified - the renderer will not be able to commit encodding command buffer and command encoder")
            throw RenderErrorType.missingDrawable
        }
        
        // Finish encoding and comming changes
        defaultRenderCommandEncoder?.endEncoding()
        defaultCommandBuffer?.present(drawable)
        defaultCommandBuffer?.commit()
    }
    
    /// Prepares instance of MTLRenderPassDescriptor class that specifies a group of render targets that serve as the output destination for pixels generated by a render pass.
    ///
    /// - Parameter clearColor: is an instnace of MTLClearColor class that incapsulates color data using RGBA components
    /// - Returns: is a fully prepared instance of MTLRenderPassdDescriptor instance
    private func prepareRenderPassDescriptor(clearColor: MTLClearColor = MTLClearColorMake(0, 0.5, 0.5, 1.0)) -> MTLRenderPassDescriptor {
        // Create render pass descriptor (RPD)
        let rpd = MTLRenderPassDescriptor()
        let bleenColor = clearColor
        rpd.colorAttachments[0].texture = currentDrawable?.texture
        rpd.colorAttachments[0].clearColor = bleenColor
        rpd.colorAttachments[0].loadAction = .clear
        
        return rpd
    }
    
    /// Creates metal shader function pair for vertex and fragment shaders from the default Metal library
    ///
    /// - Parameters:
    ///   - vertexShaderName: in-bundle name for vertex metal shader file
    ///   - fragmentShaderName: in-bundle name for fragment metal shader file
    /// - Returns: tuple containing initialized instnaces of MTLFunction class for both vertex and fragment shaders
    /// - Throws: there a couple of possible throws that may occur during the runtime of the function:
    ///     - couldNotCraeteLibrary
    ///     - couldNotMakeShaderFunction
    private func attachShaderPair(vertexShaderName: String, fragmentShaderName: String) throws -> RenderShaderPair {
        // Make sure that library can be obtaned
        guard let lib = device?.makeDefaultLibrary() else {
            debugPrint(#function + " could not make default library object, the method will be thrown")
            throw RenderErrorType.couldNotCreateLibrary
        }
        // Create vertex shader function
        guard let vertexFunction = lib.makeFunction(name: vertexShaderName) else {
            debugPrint(#function + " could not create vertex function")
            throw RenderErrorType.couldNotMakeShaderFunction
        }
        
        // Create fragment shader function
        guard let fragmentFunction = lib.makeFunction(name: fragmentShaderName) else {
            debugPrint(#function + " could not create fragment function")
            throw RenderErrorType.couldNotMakeShaderFunction
        }
        
        return (vertexFunction: vertexFunction, fragmentFunction: fragmentFunction)
    }
    
    /// Creates Render Pipeline Descriptor instnace that specifies rendering configuration
    ///
    /// - Parameters:
    ///   - shaders: is a tuple of two parameters - one for vertex shader and one of fragment shader
    ///   - pixelFormat: is a MTLPixelFormat enum type that describes the organization and characteristics of individual pixels in a texture
    /// - Returns: fully configured instance of MTLRenderPipelineDescriptor
    private func createRenderPipelineDescriptor(shaders: RenderShaderPair, pixelFormat: MTLPixelFormat = .bgra8Unorm) -> MTLRenderPipelineDescriptor {
        
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = shaders.vertexFunction
        descriptor.fragmentFunction = shaders.fragmentFunction
        descriptor.colorAttachments[0].pixelFormat = pixelFormat
        
        return descriptor
    }
    
}
