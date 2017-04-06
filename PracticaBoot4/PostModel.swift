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

let rootRef = FIRDatabase.database().reference().child(Post.className)

class PostModel{
    
    public static func getAllPosts(completion: @escaping CompletionPostList){
        fetch(query: rootRef) { (posts) in
            completion(posts)
        }
    }
    
    public static func getAllPostsByUser(useruid: String, completion: @escaping CompletionPostList){
        let query = rootRef.queryOrdered(byChild: "useruid").queryEqual(toValue : useruid)
        fetch(query: query) { (posts) in
            completion(posts)
        }
    }
    
    public static func savePost(post: Post, imageData: Data, completion: @escaping CompletionReturn){
        let query = rootRef.child(post.cloudRef!)
        
        fetch(query: query, removeObservers: true) { (posts) in
            
            saveImage(imageData: imageData as NSData, completion: { (downloadUrl) in
                
                if downloadUrl != "" {
                    post.photo = downloadUrl
                }
                
                if post.cloudRef != nil, var post_db = posts.first {
                    post_db = Post(post: post, cloudRef: post_db.cloudRef!)
                    let recordInFb = ["\(String(describing: post_db.cloudRef))": post_db.toDict()]
                    rootRef.updateChildValues(recordInFb)
                }else{
                    let key = rootRef.childByAutoId().key
                    let recordInFb = ["\(key)": post.toDict()]
                    rootRef.updateChildValues(recordInFb)
                }
                
                DispatchQueue.main.async {
                    completion(Return(done: true, message: "Post saved"))
                }
            })
        }
        
    }
    
    public static func deletePost(post: Post, completion: @escaping CompletionReturn){
        let query = rootRef.child(post.cloudRef!)
        query.removeValue(completionBlock: { (error, ref) in
            print(ref)
            if let error = error {
                completion(Return(done: false,message: error.localizedDescription))
            }
            completion(Return(done: true, message: "Post deleted"))
        })
    }
    
    private static func fetch(query: FIRDatabaseQuery, removeObservers: Bool = false, completion: @escaping CompletionPostList){
    
        var model: [Post] = []
    
        query.observe(FIRDataEventType.value, with: { (snapshot) in
    
            for child in snapshot.children {
                let post = Post.init(snapshot: child as? FIRDataSnapshot)
                model.append(post)
            }
    
            //TODO - ESTO LO TENDRIA QUE HACER EL BACKEND !!
            model.sort(by: { $0.creationDate > $1.creationDate })
            DispatchQueue.main.async {
                if(removeObservers){
                    query.removeAllObservers()
                }
                completion(model)
            }
    
        }) { (error) in
            completion(model)
        }

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
