//
//  RenderPassDescriptorViewController.swift
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 21/02/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import UIKit
import MetalKit

class RenderPassDescriptorViewController: UIViewController {

    // MARK: - Properties
    
    var renderer: MetalView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        /// Metal device preperation
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            debugPrint(#function + " Metal API is not supported")
            return
        }
        
        /// Node preperation
//        let triangle = TriangleMesh2D(device: defaultDevice)
        let quad = QuadMesh3D(device: defaultDevice)
        
        let node = Node(device: defaultDevice, geometry: quad!)
        let defaultMatrix = node.modelMatrix
        node.modelMatrix = Matrix4f.scale(matrix: defaultMatrix, factor: float3(x: 0.5, y: 0.5, z: 0.5))
//        node.modelMatrix = Matrix4f.rotate(matrix: node.modelMatrix, rotation: float3(x: 1, y: 0, z: 1))
        
        // TODO: manual buffer memory copy should be optimized
        node.prepareModelBuffer()
        
        /// Shader preperation
        let vertexShader = Shader(type: .vertex, name: "vertexUniformFunc")
        let fragmentShader = Shader(type: .fragment, name: "fragmentUniformFunc")
        let pair = ShaderPair(vertexShader: vertexShader, fragmentShader: fragmentShader)
        
        /// Metal renderer preperation
        renderer = MetalView(frame: view.frame, device: defaultDevice, shaders: pair)
        renderer.vertexBuffer = node.geometry?.vertexBuffer
        renderer.indexBuffer = node.geometry?.indexBuffer
        renderer.uniformBuffer = node.modelMatrixBuffer
        
        
        view = renderer
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
