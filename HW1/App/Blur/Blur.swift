//
//  Blur.swift
//  HW1
//
//  Created by Ilya Doroshkevitch on 07.04.2021.
//

import Foundation
import UIKit

final class Blur {

    static var blur = UIBlurEffect(style: .systemUltraThinMaterialLight)
    static var visualEffect = UIVisualEffectView()
    
    // MARK: Set blur
   class func setBlur(view: UIView) {

        visualEffect = UIVisualEffectView(effect: blur)
        visualEffect.frame = view.bounds

        view.addSubview(visualEffect)
    }

    // MARK: Remove blur
   class func removeBlur() {

        visualEffect.removeFromSuperview()
    }

}
