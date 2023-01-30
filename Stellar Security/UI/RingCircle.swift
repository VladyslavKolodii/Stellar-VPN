//
//  RingCircle.swift
//  Stellar Security
//
//  Created by Aira on 14.01.2021.
//

import UIKit

class RingCircle: UIView {
    
    override func draw(_ rect: CGRect) {
        initCircleRing(fillColor: UIColor(named: "mainBlue")!)
    }
    
    func initCircleRing(fillColor: UIColor) {
        if self.layer.sublayers != nil {
            self.layer.sublayers?.forEach{
                $0.removeFromSuperlayer()
            }
        }
        let path = UIBezierPath(arcCenter: CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0), radius: self.frame.size.height / 2.0 - 20.0, startAngle: 0.0, endAngle: 2 * .pi, clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor(named: "mainWhite")?.cgColor
        shapeLayer.fillColor = fillColor.cgColor
        shapeLayer.lineWidth = 30.0
        self.layer.addSublayer(shapeLayer)
    }

}
