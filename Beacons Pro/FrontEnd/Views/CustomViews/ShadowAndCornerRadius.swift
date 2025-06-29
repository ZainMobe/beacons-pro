//
//  ShadowAndCornerRadius.swift
//  TTFN
//
//  Created by Zain Haider on 11/01/2021.
//

import UIKit

@IBDesignable
class ShadowAndCornerRadius: UIView {

    @IBOutlet weak var lblFirst4: UILabel!
    @IBOutlet weak var lblSecond4: UILabel!
    @IBOutlet weak var lblThird4: UILabel!
    @IBOutlet weak var lblLast4: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateUI()
    }
    
    @IBInspectable var radius: CGFloat = 16 {
        didSet {
            updateUI()
        }
    }
    
    @IBInspectable var capacity: Float = 0.1 {
        didSet {
            updateUI()
        }
    }
    
    @IBInspectable var shadowLayerColor: UIColor = .gray {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        self.AddShadowAndCornerRadius(capacity: capacity, cornerRadius: self.radius, shadowColor: shadowLayerColor)
    }
}
