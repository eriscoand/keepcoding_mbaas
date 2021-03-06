//
//  NewPostController.swift
//  PracticaBoot4
//
//  Created by Juan Antonio Martin Noguera on 23/03/2017.
//  Copyright © 2017 COM. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class NewPostController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var locationEnabled = false
    var timer: Timer?
    let locManager = CLLocationManager()
    var loc: CLLocation?
    var coor: CLLocationCoordinate2D?
    var locationError: NSError?
    
    let storage = FIRStorage.storage()
    
    @IBOutlet weak var titlePostTxt: UITextField!
    @IBOutlet weak var textPostTxt: UITextField!
    @IBOutlet weak var imagePost: UIImageView!
    @IBOutlet weak var latPostTxt: UITextField!
    @IBOutlet weak var lngPostTxt: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var isReadyToPublish: Bool = false
    var imageCaptured: UIImage! {
        didSet {
            imagePost.image = imageCaptured
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FIRAnalytics.setScreenName("New Post Screen", screenClass: "NewPostController")

        handleLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        self.present(pushAlertCameraLibrary(), animated: true, completion: nil)
    }
    
    @IBAction func publishAction(_ sender: Any) {
        isReadyToPublish = (sender as! UISwitch).isOn
    }

    @IBAction func savePostInCloud(_ sender: Any) {
        
        let post = Post(title: self.titlePostTxt.text!,
                        desc: self.textPostTxt.text!,
                        lat: self.latPostTxt.text!,
                        lng: self.lngPostTxt.text!,
                        useruid: (FIRAuth.auth()?.currentUser?.uid.description)!,
                        published: self.isReadyToPublish,
                        email: (FIRAuth.auth()?.currentUser?.email)!)
        
        
        FIRAnalytics.logEvent(withName: "PostDeleted", parameters: ["user": post.useruid as! NSObject, "post": post.title as NSObject])
        
        var data = Data.init()
        if let image = imagePost.image,
            let d = UIImagePNGRepresentation(image) {
                data = d
        }
        
        doneButton.isEnabled = false
        PostModel.savePost(post: post, imageData: data, completion: { (ret) in
            print(ret.description)
            self.doneButton.isEnabled = true
            self.navigationController?.popViewController(animated: true)
        })
        
    }

    // MARK: - funciones para la camara
    internal func pushAlertCameraLibrary() -> UIAlertController {
        let actionSheet = UIAlertController(title: NSLocalizedString("Selecciona la fuente de la imagen", comment: ""), message: NSLocalizedString("", comment: ""), preferredStyle: .actionSheet)
        
        let libraryBtn = UIAlertAction(title: NSLocalizedString("Ussar la libreria", comment: ""), style: .default) { (action) in
            self.takePictureFromCameraOrLibrary(.photoLibrary)
            
        }
        let cameraBtn = UIAlertAction(title: NSLocalizedString("Usar la camara", comment: ""), style: .default) { (action) in
            self.takePictureFromCameraOrLibrary(.camera)
            
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        actionSheet.addAction(libraryBtn)
        actionSheet.addAction(cameraBtn)
        actionSheet.addAction(cancel)
        
        return actionSheet
    }
    
    internal func takePictureFromCameraOrLibrary(_ source: UIImagePickerControllerSourceType) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        switch source {
        case .camera:
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                picker.sourceType = UIImagePickerControllerSourceType.camera
            } else {
                return
            }
        case .photoLibrary:
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        case .savedPhotosAlbum:
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        self.present(picker, animated: true, completion: nil)
    }

}

// MARK: - Delegado del imagepicker
extension NewPostController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageCaptured = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        self.dismiss(animated: false, completion: {
        })
    }
    
}

extension NewPostController: CLLocationManagerDelegate {
    
    // MARK: - Delegates
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if (error as NSError).code == CLError.Code.locationUnknown.rawValue {
            return
        }
        locationError = error as NSError?
        stopLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        loc = locations.last!
        
        if let l = loc {
            latPostTxt.text = String(format: "%.8f", l.coordinate.latitude)
            lngPostTxt.text = String(format: "%.8f", l.coordinate.longitude)
        }
        
        locationError = nil
    }
    
    // MARK: - Utils
    
    //Is Location authorized?
    func handleLocation(){
        
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locManager.requestWhenInUseAuthorization()
        }
        
        if authStatus == .denied || authStatus == .restricted {
            locationDisabledAlert()
            return
        }
        
        startLocation()
        
    }
    
    //Start location manager
    func startLocation() {
        if CLLocationManager.locationServicesEnabled() {
            
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locManager.startUpdatingLocation()
            locationEnabled = true
            
            timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(NewPostController.locationTimedOut), userInfo: nil, repeats: false)
        }
    }
    
    //Stop location manager if error
    func stopLocation() {
        if locationEnabled {
            if let timer = timer {
                timer.invalidate()
            }
            locManager.stopUpdatingLocation()
            locManager.delegate = nil
            locationEnabled = false
        }
    }
    
    //Alert if location is disabled
    func locationDisabledAlert() {
        let alert = UIAlertController(title: "Location Alert", message: "Locations are disabled!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "👍", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    //Alert if location has timed out
    func locationTimedOut() {
        if loc == nil {
            stopLocation()
            let alert = UIAlertController(title: "Location Alert", message: "Location timed out!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "👍", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
}











