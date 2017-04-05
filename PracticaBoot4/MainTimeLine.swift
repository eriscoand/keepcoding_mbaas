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
    let rootRef = FIRDatabase.database().reference().child(Post.className)
    
    @IBOutlet weak var addPost: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.refreshControl?.addTarget(self, action: #selector(hadleRefresh(_:)), for: UIControlEvents.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        rootRef.observe(FIRDataEventType.value, with: { (snapshot) in
            
            self.model = []
            
            for child in snapshot.children {
                let post = Post.init(snapshot: child as? FIRDataSnapshot)
                self.model.append(post)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }) { (error) in
            
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentier, for: indexPath)

        cell.textLabel?.text = model[indexPath.row].title

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
