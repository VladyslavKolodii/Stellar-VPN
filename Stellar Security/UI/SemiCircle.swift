//
//  SemiCircle.swift
//  Stellar Security
//
//  Created by Aira on 14.01.2021.
//

import UIKit

class SemiCircle: UIView {

   
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: 0.0, y: self.frame.size.height))
        path.addArc(withCenter: CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height), radius: self.frame.size.height, startAngle: .pi, endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: self.frame.size.width, y: 0.0))
        path.close()
        let line = CAShapeLayer()
        line.path = path.cgPath
        line.fillColor = UIColor(named: "mainWhite")?.cgColor
        self.layer.addSublayer(line)
    }
}
