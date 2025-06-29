import Foundation
import UIKit
/**
 * UIViewController extension to show alerts and loader in all screens
 */
extension UIViewController {
  func alert(title: String? = nil, message: String?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    present(alert, animated: true, completion: nil)
  }
    
}

extension UINavigationController {
    
  func popToViewController(ofClass: AnyClass, animated: Bool = true) {
    if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
      popToViewController(vc, animated: animated)
    }
  }
    
}
