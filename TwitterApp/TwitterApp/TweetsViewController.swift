//
//  TweetsViewController.swift
//  TwitterApp
//
//  Created by Pj Nguyen on 10/25/16.
//  Copyright © 2016 Pj Nguyen. All rights reserved.
//

import UIKit
import MBProgressHUD

class TweetsViewController: UIViewController {
    
    
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    var tweetsView: [Tweet] = []
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        initTableView()
        loadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadData() {
        // Display HUD right before the request is made
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.label.text = "Loading"
        
        TwitterClient.sharedInstance?.homeTimeLine(success: { (tweets :[Tweet]) in
            self.tweetsView = tweets
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            MBProgressHUD.hide(for: self.view, animated: true)
                      self.tableView.reloadData()
            }, failure: { (error: NSError) in
                print(error.localizedDescription)
                self.refreshControl.endRefreshing()
                MBProgressHUD.hide(for: self.view, animated: true)
        })
    }
    
    // refresh controll
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        // Display HUD right before the request is made
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.label.text = "Loading"
        
        TwitterClient.sharedInstance?.homeTimeLine(success: { (tweets :[Tweet]) in
            self.tweetsView = tweets
            self.tableView.reloadData()
            refreshControl.endRefreshing()
            MBProgressHUD.hide(for: self.view, animated: true)
            
            self.tableView.reloadData()
            }, failure: { (error: NSError) in
                print(error.localizedDescription)
                refreshControl.endRefreshing()
                MBProgressHUD.hide(for: self.view, animated: true)
              
        })
    }
    
    @IBAction func onLogout(_ sender: AnyObject) {
        TwitterClient.sharedInstance?.logout()
        dismiss(animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "replyTweetSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow?.row
            if let detailDes = segue.destination as? DetailViewController{
                detailDes.tweet = tweetsView[indexPath!]
            }
            
        }
        
        if segue.identifier == "composeSegue" {
            let composeVC = segue.destination as! ComposeTweetViewController
            composeVC.delegate = self
        }
    }
    
    
}

extension TweetsViewController: UITableViewDataSource, UITableViewDelegate{
    
    func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sizeToFit()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetsView.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tweetCell = tableView.dequeueReusableCell(withIdentifier: "tweetCell") as! TweetCell
        tweetCell.tweet = tweetsView[indexPath.row]
        return tweetCell
    }
    
}

extension TweetsViewController: ComposeTweetViewControllerDelegate{
    func composeTweetViewController(composeTweetViewController: ComposeTweetViewController, contentPosted content: String) {
        var tweetDictionary = [String:AnyObject]()
        tweetDictionary["text"] = content as AnyObject?
        
        let date = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        let dateStr = formatter.string(from: date as Date)
        tweetDictionary["created_at"] = dateStr as AnyObject?
        tweetDictionary["user"] = User.currentUser?.dictionary
        
        let tweetPosted = Tweet(dictionary: tweetDictionary as NSDictionary)
        tweetsView.insert(tweetPosted, at: 0)
        tableView.reloadData()
        print("posted successfully")
    }
}
