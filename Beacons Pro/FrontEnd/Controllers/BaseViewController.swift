//
//  BaseViewController.swift
//  Generic project
//
//  Created by Zain Haider on 10/05/2021.
//

import UIKit
import AVFoundation
import AssetsLibrary
import MobileCoreServices
import Photos
//import MaterialComponents.MaterialTextControls_OutlinedTextFields

class BaseViewController: UIViewController, UINavigationControllerDelegate {

    var tap: UITapGestureRecognizer!
    /// Image picker to pick images from gallery or camera.
    private lazy var imagePickerController = UIImagePickerController()
    /// Once image is picked, this closure will be called.
    var imageClouser: ((_ image: UIImage?) -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        self.view.addGestureRecognizer(tap)
    }
    
    func addTapGesture() {
        self.view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func removeTapGesture() {
        self.view.removeGestureRecognizer(tap)
    }
    /// Push Controller in current navigation stack
    /// - Parameters:
    ///   - storyboard_name: Storyboard name in which contains controller in String formate.
    ///   - vc_identifier: ID of the controller in String formate.
    ///   - animated: Push animation is Boolean value.
    func push(storyboard: enums.storyboard = .Main, identifier: enums.vc_identifiers) {
        let vc = self.getController(storyboard: storyboard, identifier: identifier)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    /// Get controller from storyboard.
    /// - Parameters:
    ///   - storyboard_name: Storyboard name in which contains controller in String formate.
    ///   - vc_identifier: ID of the controller in String formate.
    /// - Returns: UIViewController
    func getController(storyboard: enums.storyboard = .Main, identifier: enums.vc_identifiers) -> UIViewController{
        let storyboard = UIStoryboard(name: storyboard.rawValue, bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier.rawValue)
        return vc
    }
    
    func getFullScreenAlert(storyboard: enums.storyboard = .Main, identifier: enums.vc_identifiers) -> UIViewController{
        let vc = self.getController(storyboard: storyboard, identifier: identifier)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        return vc
    }
    
    func getControllerVC(storyboard:String, identifier: enums.vc_identifiers) -> UIViewController{
        let storyboard = UIStoryboard(name: storyboard, bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier.rawValue)
        return vc
    }
    

//    func setupTextfield(_ field: MDCOutlinedTextField, label: String, placeholder: String, error: String? = nil, outlineColor: UIColor = app_colors.blue_light) {
//        field.label.text = label
//        field.setFloatingLabelColor(outlineColor, for: .editing)
//        field.setNormalLabelColor(.lightGray, for: .normal)
//        field.setOutlineColor(.clear, for: .normal)
//        field.setOutlineColor(outlineColor, for: .editing)
//        field.setOutlineColor(outlineColor, for: .disabled)
//        field.setOutlineColor(app_colors.border_gray, for: .normal)
//        field.containerRadius = 8
//        field.placeholder = placeholder
//        field.leadingAssistiveLabel.isHidden = true
//        field.sizeToFit()
//    }
    
    func openURL(string: String) {
        guard let url = URL(string: string), UIApplication.shared.canOpenURL(url) else {
            print("Can not open url: \(string)")
            return
        }
        UIApplication.shared.open(url, options: [:])
    }
    /// Reset key-window
    /// - Parameters:
    ///   - controller: Controller to which user want to set. Controller is enum. user can select from available options.
    ///   - animate: Whether to show animation or not.
//    func setKeyWindow(_ controller: enums.controller, animate: Bool = false) {
//        switch controller {
//        case .landing:
//            (UIApplication.shared.delegate as? AppDelegate)?.gotoLandingScreen(animate)
//        case .dashboard:
//            (UIApplication.shared.delegate as? AppDelegate)?.gotoDashboard(animate)
//        }
//    }
    /// Pick image from multiple options `Photos` or `Camera`.
    /// - Parameter onSuccess: Image has successfully picked.
    func pickImage(onSuccess: @escaping ((_ image: UIImage?)->Void)) {
        let alert = UIAlertController(title: "Select option", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler:{
            (action) in
            print("Photos")
            // Check for user permissions
            self.checkPhotoLibraryPermission{
                DispatchQueue.main.async {
                    self.imageClouser = onSuccess
                    self.imagePickerController.delegate = self
                    self.imagePickerController.mediaTypes = [kUTTypeImage] as [String]
                    self.imagePickerController.sourceType = .photoLibrary
                    self.imagePickerController.allowsEditing = true
                    self.present(self.imagePickerController, animated: true)
                }
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler:{
            (action) in
            print("Camera")
            // check if source available
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                // Check for user permissions
                self.checkCameraPermission{
                    DispatchQueue.main.async {
                        self.imageClouser = onSuccess
                        self.imagePickerController.delegate = self
                        self.imagePickerController.mediaTypes = [kUTTypeImage] as [String]
                        self.imagePickerController.sourceType = .camera
                        self.imagePickerController.allowsEditing = false
                        self.present(self.imagePickerController, animated: true, completion: nil)
                    }
                }
            }
            else{
                self.alert(message: "Source not available.")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    /// Checking for library access permissions
    /// - Parameter hanler: In case permissions have been granted
    func checkPhotoLibraryPermission(hanler: @escaping () -> Void)
    {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus{
        case .authorized:
            // Access is already granted by user
            hanler()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization{[weak self] (newStatus) in
                if newStatus == PHAuthorizationStatus.authorized{
                    // Access is granted by use
                    hanler()
                } else {
                    DispatchQueue.main.async {
                        self?.showPermissionDeniedAlert(body: "Permission not granted. Please go to settings and allow access to photo library.")
                    }
                }
            }
        default:
            DispatchQueue.main.async {
                self.showPermissionDeniedAlert(body: "Permission not granted. Please go to settings and allow access to photo library.")
            }
        }
    }
    /// Checking for camera access permissions
    /// - Parameter hanler: In case permissions have been granted
    func checkCameraPermission(hanler: @escaping () -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            // Access is already granted by user
            hanler()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) {[weak self] (granted) in
                if granted {
                    hanler()
                } else {
                    DispatchQueue.main.async {
                        self?.showPermissionDeniedAlert(body: "Permission not granted. Please go to settings and allow camera permission.")
                    }
                }
            }
        default:
            DispatchQueue.main.async {
                self.showPermissionDeniedAlert(body: "Permission not granted. Please go to settings and allow camera permission.")
            }
        }
    }
    /// If permissions are denied, show permission denied alert.
    /// - Parameters:
    ///   - body: Body of alert in String formate.
    ///   - goToHome: Set home controller of tabbar active. It is Boolean value.
    func showPermissionDeniedAlert(body: String) {
        let alert = UIAlertController(title: "Permission Denied", message: body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (_) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            guard UIApplication.shared.canOpenURL(settingsUrl) else {return}
            DispatchQueue.main.async {
                UIApplication.shared.open(settingsUrl, options: [:])
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
}
//MARK:- UIimage Picker Delegate
extension BaseViewController: UIImagePickerControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.dismiss(animated: true) {
                self.imageClouser(image)
            }
        } else {
            let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            self.dismiss(animated: true) {
                self.imageClouser(image)
            }
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}
