import UIKit
import Foundation


struct app_creds {
}



struct app_colors {
//    static let blue_light = UIColor(hexString: "#00CFEE")
//    static let blue_dark = UIColor(hexString: "#00487B")
//    static let orange = UIColor(hexString: "#F78328")
//    static let green = UIColor(hexString: "#357517")
//    static let red = UIColor(hexString: "#F7104F")
//    static let border_gray = UIColor(hexString: "#D1D9DC")
//    static let labelGray = UIColor(hexString: "#79797A")
}

struct cell_identifiers {
    static let DashboardCell = "DashboardCell"
    static let BeaconCell = "BeaconCell"
}

struct custom_views {
}

struct enums {
    enum storyboard: String {
        case Main
    }
    
    enum vc_identifiers: String {
        case DashboardController
        case RangeBeaconViewController
        case ConfigureBeaconViewController
        case EnterUUIDController
        case SupportController
    }
    
    enum support_type: String {
        case email = "mailto:zainpk121@icloud.com"
        case website = "https://www.developerzain.com"
        case whatsapp = "https://wa.me/+923004601345"
        case call = "tel://+923004601345"
        case linkedin = "https://www.linkedin.com/in/developer-zain"
    }
    
}


struct Helper_functions {
    //Convert 10 digit number to uuid
    static func convertToUUID(_ text: String) -> String {
        let uuidWithoutDashes = "3" + text.inserting(separator: "3", every: 1) //+ "000000000000"
        var uuid = uuidWithoutDashes.inserting(separator: "-", every: 4)
        uuid.remove(at: uuid.index(uuid.startIndex, offsetBy: 4))
        uuid += "-000000000000"
        return uuid
    }
}
