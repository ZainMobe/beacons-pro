//
//  SupportController.swift
//  Beacons Pro
//
//  Created by Zain Haider on 22/09/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

class SupportController: UIViewController {

    @IBOutlet var collectionButtons: [UIButton]!
    @IBOutlet weak var outletClose: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
    }
    
    private func setup() {
        collectionButtons.forEach({$0.layer.cornerRadius = 12})
        outletClose.setTitle("", for: .normal)
    }
    
    private func openSupportURL(_ type: enums.support_type) {
        guard let url = URL(string: type.rawValue) else {
            print("Invalid URL")
            return
        }
        guard UIApplication.shared.canOpenURL(url) else {
            self.alert(message: "Can not open URL.")
            return
        }
        UIApplication.shared.open(url, options: [:])
    }
    
    @IBAction func actionWebsite(_ sender: UIButton) {
        openSupportURL(.website)
    }

    @IBAction func actionEmail(_ sender: UIButton) {
        openSupportURL(.email)
    }
    
    @IBAction func actionCall(_ sender: UIButton) {
        openSupportURL(.call)
    }
    
    @IBAction func actionLinkedin(_ sender: UIButton) {
        openSupportURL(.linkedin)
    }
    
    @IBAction func actionSkype(_ sender: UIButton) {
        openSupportURL(.whatsapp)
    }

    @IBAction func actionClose(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
