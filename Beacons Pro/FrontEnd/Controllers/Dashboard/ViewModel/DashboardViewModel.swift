//
//  DashboardViewModel.swift
//  Beacon Sample
//
//  Created by Zain Haider on 21/09/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation
import UIKit


class DashboardViewModel {
    
    func getTableData() -> [DashboardModel] {
        let data1 = DashboardModel(title: "Configure a Beacon", subtitle: "Your device will broadcast(transmit) signals and will behave as beacon.", imageName: "antenna", configuration: .act_as_beacon, details: "Points to Remember:\n- iBeacons only 'Advertise' information\n- iBeacons don't know who is scanning them, so you will know if someone has find you or not.")
        let data2 = DashboardModel(title: "Find Beacons", subtitle: "Your device will scan signals from nearby beacons.", imageName: "radar", configuration: .look_for_beacon, details: "Points to Remember:\n- iBeacons don't know who are you\n- You can scan beacons around you only with their UUID\n- Once beacon is found, you will get its distance from you, major and minor values.")
        var models = [DashboardModel]()
        models.append(data1)
        models.append(data2)
        return models
    }
  
}
