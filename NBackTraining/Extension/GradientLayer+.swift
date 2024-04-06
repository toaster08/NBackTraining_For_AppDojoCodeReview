//
//  MainViewController+Action.swift
//  NBackTraining
//
//  Created by 山田　天星 on 2022/07/08.
//

import Foundation
import UIKit

extension CAGradientLayer {
    static func gradientLayer(for colors: [CGColor], in frame: CGRect) -> Self {
        let layer = Self()
        layer.colors = colors
        layer.startPoint = CGPoint.init(x: 0, y: 0)
        layer.endPoint = CGPoint.init(x: 1, y: 1)
        layer.frame = frame
        return layer
    }

    static func colors(in result: Int) -> [CGColor] {
        if result >= 80 {
            let beginColor: UIColor = UIColor(named: "up1")!
            let interColor: UIColor = UIColor(named: "up2")!
            let endColor: UIColor = UIColor(named: "up3")!
            return [beginColor.cgColor, interColor.cgColor, endColor.cgColor]
        } else if result >= 60 {
            let beginColor: UIColor = UIColor(named: "normal1")!
            let interColor: UIColor = UIColor(named: "normal2")!
            let endColor: UIColor = UIColor(named: "normal3")!
            return [beginColor.cgColor, interColor.cgColor, endColor.cgColor]
        } else {
            let beginColor: UIColor = UIColor(named: "down1")!
            let interColor: UIColor = UIColor(named: "down2")!
            let endColor: UIColor = UIColor(named: "down3")!
            return [beginColor.cgColor, interColor.cgColor, endColor.cgColor]
        }
    }
}


