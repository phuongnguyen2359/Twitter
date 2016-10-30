//
//  TweetCell.swift
//  TwitterApp
//
//  Created by Pj Nguyen on 10/25/16.
//  Copyright © 2016 Pj Nguyen. All rights reserved.
//

import UIKit
import AFNetworking

class TweetCell: UITableViewCell {

    @IBOutlet weak var imageConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var usernameLable: UILabel!
    @IBOutlet weak var screenNameLable: UILabel!
    @IBOutlet weak var createTweetLable: UILabel!
    @IBOutlet weak var contentLable: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var retweetCountLable: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var favoriteCountLable: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var imageMedia: UIImageView!
    
    
    var tweet: Tweet!{
        didSet{
            if let user = tweet.user {
                if let profileImageURL = user.profileUrl{
                    //print("url....\(profileImageURL)")
                    self.profileImage.setImageWith(profileImageURL as URL)
                }
                
                if let username = user.name{
                    self.usernameLable.text = username
                }
                
                if let screenName = user.screenname{
                    self.screenNameLable.text = "@\(screenName)"
                }
            }
            
            if let content = tweet.text {
                self.contentLable.text = content
            }
            
            self.createTweetLable.text = tweet.timeSinceCreated()

            self.retweetCountLable.text = String(tweet.retweetCount)
            self.favoriteCountLable.text = String(tweet.favoritesCount)
            
            if let imageUrl = tweet.url{
                imageMedia.setImageWith(URL(string: imageUrl)!)
                imageConstraints.constant = 128
            }
            else{
                imageConstraints.constant = 0
            }
            favorite()
            reTweet()
           
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func onLove(_ sender: AnyObject) {
        
        if tweet.favorited {
            TwitterClient.sharedInstance?.unFavorite(id: tweet.id as! Int, success: {
                self.tweet.favoritesCount -= 1
                self.favoriteCountLable.text = String(self.tweet.favoritesCount)
                self.tweet.favorited = !self.tweet.favorited
                self.favoriteButton.setImage(UIImage(named: "like-action"), for: .normal)

                }, failure: { (error: NSError) in
                    print(error.localizedDescription)
            })
        }
        else{
            TwitterClient.sharedInstance?.onFavorite(id: tweet.id as! Int, success: {
                self.tweet.favoritesCount += 1
                self.favoriteCountLable.text = String(self.tweet.favoritesCount)
                self.tweet.favorited = !self.tweet.favorited
                self.favoriteButton.setImage(UIImage(named: "liked-action"), for: .normal)
                }, failure: { (error: NSError) in
                    print(error.localizedDescription)
            })
        }
    }
    
    @IBAction func onReTweet(_ sender: AnyObject) {
        if tweet.reTweet {
            TwitterClient.sharedInstance?.onRetweet(id: tweet.id as! Int, success: { 
                self.tweet.retweetCount -= 1
                self.retweetCountLable.text = String(self.tweet.retweetCount)
                self.tweet.reTweet = !self.tweet.reTweet
                self.retweetButton.setImage(UIImage(named: "retweet-action"), for: .normal)
                }, failure: { (error: NSError) in
                    print(error.localizedDescription)
            })
        }
        else{
            TwitterClient.sharedInstance?.unRetweet(id: tweet.id as! Int, success: { 
                self.tweet.retweetCount += 1
                self.retweetCountLable.text = String(self.tweet.retweetCount)
                self.tweet.reTweet = !self.tweet.reTweet
                self.retweetButton.setImage(UIImage(named: "retweeted-action"), for: .normal)
                }, failure: { (error: NSError) in
                    print(error.localizedDescription)
            })
        }
        
    }
    
    @IBAction func onRely(_ sender: AnyObject) {
    }
    
    
    func favorite() {
        self.favoriteCountLable.text = String(tweet.favoritesCount)
        if tweet.favorited {
            favoriteButton.setImage(UIImage(named: "liked-action"), for: .normal)
            favoriteCountLable.textColor = UIColor.red
        }
        else {
            favoriteButton.setImage(UIImage(named: "like-action"), for: .normal)
            favoriteCountLable.textColor = UIColor.gray
        }
    }
    
    func reTweet() {
        self.retweetCountLable.text = String(tweet.retweetCount)
        if tweet.reTweet{
            retweetButton.setImage(UIImage(named: "retweeted-action"), for: .normal)
            retweetCountLable.textColor = UIColor.red
        }
        else{
            retweetButton.setImage(UIImage(named: "retweet-action"), for: .normal)
            retweetCountLable.textColor = UIColor.gray
        }
    }
    

}
