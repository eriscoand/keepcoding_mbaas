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
    
    public static func observePostValues(event: FIRDataEventType, completion: @escaping CompletionPostList){
        let query = posts.queryOrdered(byChild: "published").queryEqual(toValue : true)
        fetch(query: query, event: event) { (posts) in
            completion(posts)
        }
    }
    
    public static func observeUserPostValues(event: FIRDataEventType, useruid: String, completion: @escaping CompletionPostList){
        let query = posts.queryOrdered(byChild: "useruid").queryEqual(toValue : useruid)
        fetch(query: query, event: event) { (posts) in
            completion(posts)
        }
    }
    
    public static func savePost(post: Post, imageData: Data, completion: @escaping CompletionReturn){
        
        let query = posts.child(post.cloudRef == nil ? "0" : post.cloudRef!)
        
        saveImage(imageData: imageData as NSData) { (photo) in
            
            if photo != "" {
                post.photo = photo
            }
            
            query.observeSingleEvent(of: .value, with: { (snapshot) in
                
                //UPDATING POST
                if snapshot.hasChildren() {
                    var post_firebase = Post.init(snapshot: snapshot)
                    post_firebase = Post(post: post, cloudRef: post_firebase.cloudRef!)
                    let cloudRef = post_firebase.cloudRef!
                    let recordInFb = ["\(cloudRef)": post_firebase.toDict()]
                    posts.updateChildValues(recordInFb)
                }else{
                    //CREATING POST
                    let key = posts.childByAutoId().key
                    let recordInFb = ["\(key)": post.toDict()]
                    posts.updateChildValues(recordInFb)
                }
                
                query.removeAllObservers()
                
                DispatchQueue.main.async {
                    completion(Return(done: true, message: "Post saved"))
                }
                
            })
            
        }
        
    }
    
    public static func deletePost(post: Post, completion: @escaping CompletionReturn){
        let query = posts.child(post.cloudRef!)
        query.removeValue(completionBlock: { (error, ref) in
            
            var ret = Return(done: true, message: "Post deleted")
            if let error = error {
                ret = Return(done: false,message: error.localizedDescription)
            }
            
            query.removeAllObservers()
            
            DispatchQueue.main.async {
                completion(ret)
            }
            
        })
    }
    
    private static func fetch(query: FIRDatabaseQuery, event: FIRDataEventType, completion: @escaping CompletionPostList){

        query.observe(event, with: { (snapshot) in
            
            var model: [Post] = []
    
            for child in snapshot.children {
                if let snapshot = child as? FIRDataSnapshot,
                    snapshot.hasChildren() {
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
    
    public static func getUserRating(post: String, user: String, completion: @escaping (Int) -> ()){
        
        let query = posts.child(post).child("ratings").child(user)
        
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            
            query.removeAllObservers()
            
            var value = 0
            if let number = Int(String(describing: snapshot.value)) {
                value = number
            }
            
            DispatchQueue.main.async {
                completion(value)
            }
            
        })
        
    }
    
    public static func saveRating(post: String, user: String, rating: Int,  completion: @escaping CompletionReturn){
        
        let ratings = posts.child(post).child("ratings")
        
        ratings.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let ratingInFb = ["\(user)": rating.description]
            ratings.updateChildValues(ratingInFb)
            
            DispatchQueue.main.async {
                completion(Return(done: true, message: "Rating saved"))
            }
            
        })
        
    }
    
    public static func updateAverage(post: String, rating: Int, completion: @escaping CompletionReturn){
        
        let postRated = posts.child(post)
        postRated.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let post_firebase = Post.init(snapshot: snapshot)
            
            post_firebase.totalRated += 1
            post_firebase.totalRating += rating
            
            let cloudRef = post_firebase.cloudRef!
            let postInFb = ["\(cloudRef)": post_firebase.toDict()]
            posts.updateChildValues(postInFb)
            
        })
        
    }
    
    private static func saveImage(imageData: NSData, completion: @escaping (String) -> ()){
        
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
