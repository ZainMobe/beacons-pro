//
//  EnterUUIDController.swift
//  Beacon Sample
//
//  Created by Zain Haider on 21/09/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

class EnterUUIDController: BaseViewController {

    @IBOutlet weak var outletPaste: UIButton!
    @IBOutlet weak var outletCopy: UIButton!
    @IBOutlet weak var outletAdd: UIButton!
    @IBOutlet weak var outletDummyUUID: UIButton!
    @IBOutlet weak var outletClose: UIButton!
    @IBOutlet weak var txtUUID: UITextField!

    var uuidAdded: ((_ uuid: UUID)-> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addTapGesture()
        setup()
    }
    
    private func setup() {
        outletAdd.layer.cornerRadius = 12
        outletCopy.layer.cornerRadius = 12
        outletPaste.layer.cornerRadius = 12
        outletDummyUUID.layer.cornerRadius = 12

        outletCopy.layer.borderWidth = 2
        outletCopy.layer.borderColor = UIColor.systemBlue.cgColor
        
        outletPaste.layer.borderWidth = 2
        outletPaste.layer.borderColor = UIColor.systemBlue.cgColor
        
        outletDummyUUID.layer.borderWidth = 2
        outletDummyUUID.layer.borderColor = UIColor.systemBlue.cgColor
        
        outletPaste.isEnabled = UIPasteboard.general.hasStrings
        outletClose.setTitle("", for: .normal)
    }
    
    private func submitUUID() {
        guard let txt = txtUUID.text?.trimmingCharacters(in: .whitespacesAndNewlines), let uuid = UUID(uuidString: txt) else {
            alert(message: "UUID is not valid. Please follow correct formate. i.e E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")
            return
        }
        uuidAdded?(uuid)
        self.dismiss(animated: true)
    }

    @IBAction func actionPaste(_ sender: UIButton) {
        if let txt = UIPasteboard.general.string {
            print(txt)
            txtUUID.text = txt
        }
    }
    
    @IBAction func actionCopy(_ sender: UIButton) {
        if let text = txtUUID.text {
            print(text)
            UIPasteboard.general.string = text
        }
    }
    
    @IBAction func actionDummyUUID(_ sender: UIButton) {
        let uuidString = "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
        txtUUID.text = uuidString
        txtUUID.resignFirstResponder()
        submitUUID()
    }
    
    @IBAction func actionSubmit(_ sender: UIButton) {
        txtUUID.resignFirstResponder()
        let text = txtUUID.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if text.count == 10 {
            let uuid = Helper_functions.convertToUUID(text)
            txtUUID.text = uuid
        }
        submitUUID()
    }
    
    @IBAction func actionClose(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true)
    }
}


extension EnterUUIDController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        outletCopy.isEnabled = textField.text?.count ?? 0 > 4
        return true
    }
}
