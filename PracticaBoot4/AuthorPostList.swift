//
//  AuthorPostList.swift
//  PracticaBoot4
//
//  Created by Juan Antonio Martin Noguera on 23/03/2017.
//  Copyright © 2017 COM. All rights reserved.
//

import UIKit
import Firebase

class AuthorPostList: UITableViewController {

    var model: [Post] = []
    let cellIdentifier = "POSTAUTOR"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FIRAnalytics.setScreenName("Author Post List Screen", screenClass: "AuthorPostList")
        
        self.refreshControl?.addTarget(self, action: #selector(hadleRefresh(_:)), for: UIControlEvents.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let useruid = FIRAuth.auth()?.currentUser?.uid {
            PostModel.observeUserPostValues(event: .value, useruid: useruid) { (posts) in
                self.model = posts
                self.tableView.reloadData()
            }
            PostModel.observeUserPostValues(event: .childRemoved, useruid: useruid) { (posts) in
                self.model = posts
                self.tableView.reloadData()
            }
        }
        
    }
    
    func hadleRefresh(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let post = model[indexPath.row]
        cell.textLabel?.text = post.title
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let post = self.model[indexPath.row] as Post
        
        let publish = UITableViewRowAction(style: .normal, title: "Publicar") { (action, indexPath) in
            PostModel.publishPost(postuid: post.cloudRef!, completion: { (ret) in
                print(ret.description)
                
                FIRAnalytics.logEvent(withName: "PostPublished", parameters: ["user": post.useruid as! NSObject, "post": post.title as NSObject])
                
            })
        }
        publish.backgroundColor = UIColor.green
        
        let deleteRow = UITableViewRowAction(style: .destructive, title: "Eliminar") { (action, indexPath) in
            PostModel.deletePost(post: post, completion: { (ret) in
                print(ret.description)
                
                FIRAnalytics.logEvent(withName: "PostDeleted", parameters: ["user": post.useruid as! NSObject, "post": post.title as NSObject])
                
            })
        }
        return [publish, deleteRow]
    }


}
