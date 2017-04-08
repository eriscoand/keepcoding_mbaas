//
//  PostModel.swift
//  KeepcodingMBaas
//
//  Created by Eric Risco de la Torre on 05/04/2017.
//  Copyright © 2017 COM. All rights reserved.
//

import Foundation
import Firebase

typealias CompletionPostList = ([Post]) -> ()
typealias CompletionPost = (Post) -> ()
typealias CompletionReturn = (Return) -> ()

let posts = FIRDatabase.database().reference().child(Post.className)

class PostModel{
    
    class func observePostValues(event: FIRDataEventType, completion: @escaping CompletionPostList){
        let query = posts.queryOrdered(byChild: "published").queryEqual(toValue : true)
        fetch(query: query, event: event) { (posts) in
            completion(posts)
        }
    }
    
    class func observeUserPostValues(event: FIRDataEventType, useruid: String, completion: @escaping CompletionPostList){
        let query = posts.queryOrdered(byChild: "useruid").queryEqual(toValue : useruid)
        fetch(query: query, event: event) { (posts) in
            completion(posts)
        }
    }
    
    class func savePost(post: Post, imageData: Data, completion: @escaping CompletionReturn){
        
        saveImage(imageData: imageData as NSData) { (photo) in
            
            if photo != "" {
                post.photo = photo
            }
            
            let key = posts.childByAutoId().key
            let post_firebase = ["\(key)": post.toDict()]
            posts.updateChildValues(post_firebase)
            
            DispatchQueue.main.async {
                completion(Return(done: true, message: "Post saved"))
            }
            
        }
        
    }
    
    class func publishPost(postuid: String, completion: @escaping CompletionReturn){
        
        posts.child(postuid).child("published").setValue(true)
        completion(Return(done: true, message: "Post published"))
        
    }
    
    class func deletePost(post: Post, completion: @escaping CompletionReturn){
        posts.child(post.cloudRef!).removeValue(completionBlock: { (error, ref) in
            
            var ret = Return(done: true, message: "Post deleted")
            if let error = error {
                ret = Return(done: false,message: error.localizedDescription)
            }
            
            DispatchQueue.main.async {
                completion(ret)
            }
            
        })
    }
    
    private class func fetch(query: FIRDatabaseQuery, event: FIRDataEventType, completion: @escaping CompletionPostList){

        query.observe(event, with: { (snapshot) in
            
            var model: [Post] = []
    
            for child in snapshot.children {
                if let snapshot = child as? FIRDataSnapshot, snapshot.hasChildren() {
                    let post = Post.init(snapshot: snapshot)
                    model.append(post)
                }
            }
    
            //TODO - ESTO LO TENDRIA QUE HACER EL BACKEND !!
            model.sort(by: { $0.creationDate > $1.creationDate })
            DispatchQueue.main.async {
                completion(model)
            }
    
        }) { (error) in
            completion([])
        }

    }
    
    class func getUserRating(post: String, user: String, completion: @escaping (Int) -> ()){
        
        let query = posts.child(post).child("ratings").child(user)
        
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            
            query.removeAllObservers()
            
            DispatchQueue.main.async {
                if !(snapshot.value is NSNull) {
                    completion(snapshot.value as! Int)
                }else{
                    completion(0)
                }
            }
            
        })
        
    }
    
    class func saveRating(postCloudRef: String, useruid: String, ratingValue: Int,  completion: @escaping CompletionReturn){
        
        let postFetch = posts.child(postCloudRef)
        
        let rating = ["\(useruid)": ratingValue]
        postFetch.child("ratings").updateChildValues(rating)
        
        postFetch.observeSingleEvent(of: .value, with: { (snapshot) in
            
            postFetch.removeAllObservers()
            
            if snapshot.hasChildren() {
                let post_firebase = Post.init(snapshot: snapshot)
                
                //TODO -- ESTO LO TENDRIA QUE HACER EL BACKEND!!!
                post_firebase.totalRated = 0
                post_firebase.totalRating = 0
                if let ratings = post_firebase.ratings {
                    for rating in ratings {
                        post_firebase.totalRated += 1
                        post_firebase.totalRating += rating.rating
                    }
                }
                
                posts.child(postCloudRef).child("totalRated").setValue(post_firebase.totalRated)
                posts.child(postCloudRef).child("totalRating").setValue(post_firebase.totalRating)
                
                DispatchQueue.main.async {
                    completion(Return(done: true, message: "Rating saved"))
                }
                
            }
        })
        
    }
    
    private class func saveImage(imageData: NSData, completion: @escaping (String) -> ()){
        
        if imageData.length == 0 {
            completion("")
        }else{
            let storage = FIRStorage.storage()
            let postImages = storage.reference().child(Post.className)
            let newImage = postImages.child(UUID().uuidString)
            newImage.put(imageData as Data, metadata: nil) { (metadata, error) in
                
                if let url = metadata?.downloadURL()?.absoluteString {
                    completion(url)
                }
                
            }
        }
        
    }
    
}
