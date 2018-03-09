//
//  2DSphereTracingViewController.swift
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 09/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import UIKit

class _DSphereTracingViewController: UIViewController {

    // MARK: - Properties

    let rayTracer = RayTracer()
    
    // MARK: - Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.image = prepare()
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
    
    private func prepare() -> UIImage {
        let pixelSet = rayTracer.makeSpherePixelSet(width: 1000, height: 500)
        let renderedImage = rayTracer.render(pixelSet: pixelSet)
        return UIImage(ciImage: renderedImage)
    }
    
}
