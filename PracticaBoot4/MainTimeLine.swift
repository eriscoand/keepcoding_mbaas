//
//  MainTimeLine.swift
//  PracticaBoot4
//
//  Created by Juan Antonio Martin Noguera on 23/03/2017.
//  Copyright © 2017 COM. All rights reserved.
//

import UIKit
import Firebase

class MainTimeLine: UITableViewController {

    var model: [Post] = []
    let cellIdentier = "POSTSCELL"
    
    @IBOutlet weak var addPost: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FIRAnalytics.setScreenName("Initial Screen", screenClass: "MainTimeLine")

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        self.refreshControl?.addTarget(self, action: #selector(hadleRefresh(_:)), for: UIControlEvents.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        PostModel.observePostValues(event: .value) { (posts) in
            self.model = posts
            self.tableView.reloadData()
        }
        
        if let _ = FIRAuth.auth()?.currentUser {
            addPost.isEnabled = true
        }else{
            addPost.isEnabled = false
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
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentier)

        let post: Post = model[indexPath.row]
        
        cell.textLabel?.text = post.title
        
        var averageRating = 0
        if post.totalRated > 0 {
            averageRating = post.totalRating / post.totalRated
        }
        
        cell.imageView?.imageFromServerURL(urlString: post.photo)
        
        cell.detailTextLabel?.text = "[" + post.email + "] Average rating: " + averageRating.description

        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowRatingPost", sender: indexPath)
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowRatingPost" {
            let vc = segue.destination as! PostReview
            let selectedIndex = self.tableView.indexPathForSelectedRow?.last
            vc.post = model[selectedIndex!]
        }
    }


}
