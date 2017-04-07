//
//  PostReview.swift
//  PracticaBoot4
//
//  Created by Juan Antonio Martin Noguera on 23/03/2017.
//  Copyright © 2017 COM. All rights reserved.
//

import UIKit
import Firebase

class PostReview: UIViewController {

    @IBOutlet weak var rateSlider: UISlider!
    @IBOutlet weak var imagePost: UIImageView!
    @IBOutlet weak var postTxt: UITextField!
    @IBOutlet weak var titleTxt: UITextField!
    
    var post: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rateSlider.isEnabled = false
        postTxt.isEnabled = false
        titleTxt.isEnabled = false
        
        if let p = post,
            let currentUser = FIRAuth.auth()?.currentUser{
            titleTxt.text = p.title
            postTxt.text = p.description
            
            PostModel.getUserRating(post: p.cloudRef!, user: currentUser.uid, completion: { (rating) in
                self.rateSlider.value = Float(rating)
                self.rateSlider.isEnabled = true
            })
            
            imagePost.imageFromServerURL(urlString: p.photo)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rateAction(_ sender: Any) {
        //print("\((sender as! UISlider).value)")
    }

    @IBAction func ratePost(_ sender: Any) {
        
        if let p = post,
            let currentUser = FIRAuth.auth()?.currentUser{
            
            PostModel.saveRating(post: p.cloudRef!, user: currentUser.uid, rating: Int(rateSlider.value), completion: { (ret) in
                print(ret.description)
            })
            
            
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
