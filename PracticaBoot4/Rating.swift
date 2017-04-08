//
//  Rating.swift
//  KeepcodingMBaas
//
//  Created by Eric Risco de la Torre on 07/04/2017.
//  Copyright © 2017 COM. All rights reserved.
//

import Foundation
import Firebase

class Rating: NSObject {
    
    var useruid: String
    var rating: Int
    
    init(useruid: String, rating: Int){
        self.useruid = useruid
        self.rating = rating
    }
    
    init(snapshot: FIRDataSnapshot?){
        self.useruid = (snapshot?.key)!
        self.rating = snapshot?.value as! Int
    }

}
