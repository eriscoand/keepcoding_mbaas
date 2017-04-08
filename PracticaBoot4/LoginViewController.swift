//
//  LoginViewController.swift
//  KeepcodingMBaas
//
//  Created by Eric Risco de la Torre on 04/04/2017.
//  Copyright © 2017 COM. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FIRAnalytics.setScreenName("Login Screen", screenClass: "LoginViewController")
        
        reloadUI()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func facebookLoginButton(_ sender: Any) {
        
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform login by calling Firebase APIs
            FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                
                FIRAnalytics.logEvent(withName: "FacebookLogin", parameters: nil)
                
                DispatchQueue.main.async {
                    self.reloadUI()
                }
                
            })
            
        }
    }

    @IBAction func signOutButtonClicked(_ sender: Any) {
        do{
            try FIRAuth.auth()?.signOut()
            
            FIRAnalytics.logEvent(withName: "FacebookSignOut", parameters: nil)
            
        }catch{
            
        }
        reloadUI()
    }
    
    func reloadUI(){
        if let currentUser = FIRAuth.auth()?.currentUser {
            
            usernameLabel.text = currentUser.displayName
            uuidLabel.text = currentUser.uid
            
            if let url = currentUser.photoURL {
                profileImage.imageFromServerURL(urlString: url.absoluteString)
            }
            
        }else{
            usernameLabel.text = ""
            uuidLabel.text = ""
            profileImage.image = nil
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
