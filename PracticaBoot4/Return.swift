//
//  Return.swift
//  KeepcodingMBaas
//
//  Created by Eric Risco de la Torre on 05/04/2017.
//  Copyright © 2017 COM. All rights reserved.
//

import Foundation

struct Return {
    
    var done: Bool
    var message: String
    
    init(done: Bool, message: String){
        self.done = done
        self.message = message
    }
    
    var description : String {
        if self.done {
            return "Operation successful: " + self.message
        }else{
            return "Operation error: " + self.message
        }
    }
    
}
