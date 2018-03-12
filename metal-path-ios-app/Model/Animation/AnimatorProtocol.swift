
//
//  Animator.swift
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 12/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation

enum EasingFunction {
    case easeIn
    case easeOut
    case easeInOut
    case linear
}

protocol AnimatorProtocol {
    var speed: Float { get set }
    var isAnimating: Bool { get set }
    var easing: EasingFunction { get set }
}
