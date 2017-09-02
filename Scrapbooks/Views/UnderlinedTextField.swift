//
//  UnderlinedTextField.swift
//  Scrapbooks
//
//  Created by Alan Li on 2017-09-02.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import UIKit

class UnderlinedTextField: UITextField {
    
    override func draw(_ rect: CGRect) {

        let context = UIGraphicsGetCurrentContext()
        
        let line = CGMutablePath()
        line.move(to: CGPoint(x: 0.0, y: rect.maxY))
        line.addLine(to: CGPoint(x: rect.width, y: rect.maxY))
        
        
        context?.addPath(line)
        context?.setStrokeColor(Colours.maroon.cgColor)
        context?.setLineWidth(2.0)
        context?.strokePath()
        
        super.draw(rect)
    }

}
