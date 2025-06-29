//
//  DashboardModel.swift
//  Beacon Sample
//
//  Created by Zain Haider on 21/09/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

class DashboardModel {
    enum configuration_type {
        case act_as_beacon
        case look_for_beacon
    }
    
    let title: String
    let subtitle: String
    let image: UIImage?
    let details: String
    let configuration: configuration_type
    
    init(title: String, subtitle: String, imageName: String, configuration: configuration_type, details: String) {
        self.title = title
        self.image = UIImage(named: imageName)
        self.configuration = configuration
        self.subtitle = subtitle
        self.details = details
    }
}
