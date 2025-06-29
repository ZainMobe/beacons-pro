//
//  DashboardCell.swift
//  Beacon Sample
//
//  Created by Zain Haider on 21/09/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

class DashboardCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var imgCentre: UIImageView!
    @IBOutlet weak var viewInfo: UIView!
    
    var infoButtonPressed: (()-> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setup()
    }
    
    

    private func setup() {
        viewInfo.layer.cornerRadius = 16
    }
    

    private func animateInfoView() {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseIn]) {
            self.viewInfo.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        } completion: { completed in
            if completed {
                UIView.animate(withDuration: 0.2) {
                    self.viewInfo.transform = .identity
                }
            }
        }
    }
    
    @IBAction func actionInfo(_ sender: UIButton) {
        animateInfoView()
        infoButtonPressed?()
    }
    
}
