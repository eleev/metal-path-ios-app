//
//  GradientViewController.swift
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 08/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import UIKit

class GradientViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepare()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Utility
    
    func prepare() {
        let rayTracer = RayTracer()
        let pixelSet = rayTracer.makeGradientPixelSet(width: 600, height: 400)
        let image = rayTracer.render(pixelSet: pixelSet)
        
        let uimage = UIImage(ciImage: image)
        
        imageView.image = uimage
    }
    
}
