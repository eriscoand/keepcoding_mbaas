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
    var rating: Int
    var userRef: FIRDatabaseReference?
    var cloudRef: FIRDatabaseReference?
    
    init(title: String, description: String, photo: String, lat: String, lng: String, useruid: String, published: Bool, rating: Int,userRef: FIRDatabaseReference?){
        self.title = title
        self.desc = description
        self.photo = photo
        self.lat = lat
        self.lng = lng
        self.useruid = useruid
        self.published = published
        self.rating = rating
        self.userRef = userRef
        self.cloudRef = nil
    }
    
    init(snapshot: FIRDataSnapshot?){
        self.title = (snapshot?.value as? [String:Any])?["title"] as! String
        self.desc = (snapshot?.value as? [String:Any])?["desc"] as! String
        self.photo = (snapshot?.value as? [String:Any])?["photo"] as! String
        self.lat = (snapshot?.value as? [String:Any])?["lat"] as! String
        self.lng = (snapshot?.value as? [String:Any])?["lng"] as! String
        self.useruid = (snapshot?.value as? [String:Any])?["useruid"] as! String
        self.published = (snapshot?.value as? [String:Any])?["published"] as! Bool
        self.rating = (snapshot?.value as? [String:Any])?["rating"] as! Int
        self.userRef = (snapshot?.value as? [String:Any])?["user"] as? FIRDatabaseReference
        self.cloudRef = snapshot?.ref
    }
    
    convenience override init(){
        self.init(title: "", description: "", photo: "", lat: "", lng: "", useruid: "", published: false, rating: 0, userRef: nil)
    }
    
}

extension Post{
    func toDict() -> [String:Any] {
        var dict = [String:Any]()
        let otherSelf = Mirror(reflecting: self)
        for child in otherSelf.children {
            if let key = child.label {
                dict[key] = child.value
            }
        }
        return dict
    }
}
