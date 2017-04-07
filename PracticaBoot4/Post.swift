//
//  Post.swift
//  KeepcodingMBaas
//
//  Created by Eric Risco de la Torre on 03/04/2017.
//  Copyright © 2017 COM. All rights reserved.
//

import Foundation
import Firebase

class Post: NSObject{
    
    var title: String
    var desc: String
    var photo: String
    var lat: String
    var lng: String
    var useruid: String
    var published: Bool
    var creationDate: String
    var totalRating: Int
    var totalRated: Int
    var cloudRef: String?
    
    init(title: String, description: String, lat: String, lng: String, useruid: String, published: Bool){
        self.title = title
        self.desc = description
        self.photo = ""
        self.lat = lat
        self.lng = lng
        self.useruid = useruid
        self.published = published
        self.creationDate = Date().description
        self.totalRating = 0
        self.totalRated = 0
        self.cloudRef = nil
    }
    
    convenience init(post: Post, cloudRef: String){
        self.init(title: post.title, description: post.description, lat: post.lat, lng: post.lng, useruid: post.useruid, published: post.published)
        self.photo = post.photo
        self.totalRating = post.totalRating
        self.totalRated = post.totalRated
        self.cloudRef = cloudRef
    }
    
    init(snapshot: FIRDataSnapshot?){
        self.title = (snapshot?.value as? [String:Any])?["title"] as! String
        self.desc = (snapshot?.value as? [String:Any])?["desc"] as! String
        self.photo = (snapshot?.value as? [String:Any])?["photo"] as! String
        self.lat = (snapshot?.value as? [String:Any])?["lat"] as! String
        self.lng = (snapshot?.value as? [String:Any])?["lng"] as! String
        self.useruid = (snapshot?.value as? [String:Any])?["useruid"] as! String
        self.published = (snapshot?.value as? [String:Any])?["published"] as! Bool
        self.creationDate = (snapshot?.value as? [String:Any])?["creationDate"] as! String
        self.totalRating = (snapshot?.value as? [String:Any])?["totalRating"] as! Int
        self.totalRated = (snapshot?.value as? [String:Any])?["totalRated"] as! Int
        self.cloudRef = snapshot?.key.description
    }
    
}
