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
        
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            debugPrint(#function + " Metal API is not supported")
            return
        }

        let triangle = TriangleMesh2D(device: defaultDevice)
        
        renderer = MetalView(frame: view.frame, device: defaultDevice)
        renderer.buffer = triangle?.buffer
        
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
