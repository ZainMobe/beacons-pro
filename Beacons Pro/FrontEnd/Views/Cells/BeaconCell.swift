//
//  BeaconCell.swift
//  Beacon Sample
//
//  Created by Zain Haider on 21/09/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

class BeaconCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblDistance: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
