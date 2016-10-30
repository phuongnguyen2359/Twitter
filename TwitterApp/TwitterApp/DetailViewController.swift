//
//  DetailViewController.swift
//  TwitterApp
//
//  Created by Pj Nguyen on 10/28/16.
//  Copyright © 2016 Pj Nguyen. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLable: UILabel!
    @IBOutlet weak var screenNameLable: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextField!
    @IBOutlet weak var mediaImage: UIImageView!
    @IBOutlet weak var favoriteCountLable: UILabel!
    @IBOutlet weak var reTweetCountLable: UILabel!
    @IBOutlet weak var timeCreated: UILabel!
    @IBOutlet weak var imagesContrain: NSLayoutConstraint!
    
    
    var tweet: Tweet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = tweet.user {
            if let username = user.name{
                usernameLable.text = username
            }
            
            if let profileUrl = user.profileUrl{
                profileImage.setImageWith(profileUrl as URL)
            }
            if let screenName = user.screenname{
                screenNameLable.text = screenName
            }
            if let content = tweet.text{
                contentLabel.text = content
            }
        }
        if let imageUrl = tweet.url{
            mediaImage.setImageWith(URL(string: imageUrl)!)
            imagesContrain.constant = 304
        }
        else{
            imagesContrain.constant = 0
        }
        
        
    
        
        reTweetCountLable.text = String(tweet.retweetCount)
        favoriteCountLable.text = String(tweet.favoritesCount)
        
        
        timeCreated.text = tweet.timeSinceCreated()
        contentTextView.text = "\(screenNameLable.text!) "
        retweetCountLabel.text = String(140 - (contentTextView.text?.characters.count)!)
        love()
        favorite()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onTextChange(_ sender: UITextField) {
        retweetCountLabel.text = String(140 - (contentTextView.text?.characters.count)!)
    }
   

    @IBAction func onReply(_ sender: AnyObject) {
        TwitterClient.sharedInstance?.onReply(id: (tweet.id as! Int), text: contentTextView.text!, success: {
            print("success")
            self.dismiss(animated: true, completion: nil)
            }, failure: { (error: NSError) in
                print("error reply")
                print(error.localizedDescription)
        })
    }
    
    func love() {
        favoriteCountLable.text = String(tweet.favoritesCount)
        if tweet.favorited{
            likeButton.setImage(UIImage(named: "liked-action"), for: .normal)
            favoriteCountLable.textColor = UIColor.red
        }
        else{
            likeButton.setImage(UIImage(named: "like-action"), for: .normal)
            favoriteCountLable.textColor = UIColor.gray
        }
    }
    
    func favorite(){
        retweetCountLabel.text = String(tweet.retweetCount)
        if tweet.reTweet {
            retweetButton.setImage(UIImage(named: "retweeted-action"), for: .normal)
            retweetCountLabel.textColor = UIColor.red
        }
        else{
            retweetButton.setImage(UIImage(named: "retweet-action"), for: .normal)
            retweetCountLabel.textColor = UIColor.gray
        }
    }
   
}
