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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.refreshControl?.addTarget(self, action: #selector(hadleRefresh(_:)), for: UIControlEvents.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let useruid = FIRAuth.auth()?.currentUser?.uid {
            PostModel.getAllPostsByUser(useruid: useruid) { (posts) in
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
        if post.photo != "" {
            cell.imageView?.imageFromServerURL(urlString: post.photo)
        }
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let post = self.model[indexPath.row] as Post
        
        let publish = UITableViewRowAction(style: .normal, title: "Publicar") { (action, indexPath) in
            post.published = true
            PostModel.savePost(post: post, imageData: Data(), completion: { (ret) in
                print(ret.done,ret.message)
            })
        }
        publish.backgroundColor = UIColor.green
        
        let deleteRow = UITableViewRowAction(style: .destructive, title: "Eliminar") { (action, indexPath) in
            PostModel.deletePost(post: post, completion: { (ret) in
                print(ret.done,ret.message)
            })
        }
        return [publish, deleteRow]
    }


}
