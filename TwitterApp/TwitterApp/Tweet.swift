//
//  Tweet.swift
//  TwitterApp
//
//  Created by Pj Nguyen on 10/25/16.
//  Copyright © 2016 Pj Nguyen. All rights reserved.
//

import UIKit
import NSDate_TimeAgo



class Tweet: NSObject {
    
    var text: String?
    var createdAt: NSDate?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    var favorited: Bool = false
    var reTweet: Bool = false
    
    var id: NSNumber?
    var replyToStatusId: NSNumber?
    var replyToScreenName: String?
    var user: User?
    var url:String?

    
    init(dictionary: NSDictionary) {
        
        id = (dictionary["id"] as? NSNumber!) ?? 0
        user = User(dictionary: dictionary["user"] as! NSDictionary)
        replyToScreenName = (dictionary["in_reply_to_screen_name"] as? String!) ?? ""

        
        text = dictionary["text"] as? String
        
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favorite_count"] as? Int) ?? 0
        
        let timeCreatedString = dictionary["created_at"] as? String
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        if timeCreatedString != nil {
            createdAt = formatter.date(from: timeCreatedString!) as NSDate?
        }
        
        if let favorited = dictionary["favorited"] as? Bool {
            self.favorited = favorited
        }
        
        if let reTweet = dictionary["reTweet"] as? Bool{
            self.reTweet = reTweet
        }
        
        if let media = dictionary.value(forKeyPath: "entities.media") as? [NSDictionary] {
            for image in media {
                if let urlString = image["media_url"] as? String {
                    //images.append(NSURL(string: urlString)!)
                    self.url = urlString
                }
            }
        }

    }
    
    // caculate time
    func timeSinceCreated() -> String {
        if createdAt != nil {
            let totalTime = NSDate().timeIntervalSince(createdAt! as Date)
            if totalTime < 60 {
                return String(Int(totalTime)) + "s"
            } else if totalTime < 3600 {
                return String(Int(totalTime / 60)) + "m"
            } else if totalTime < 24*3600 {
                return String(Int(totalTime / 60 / 60)) + "h"
            } else {
                return String(Int(totalTime / 60 / 60 / 24)) + "d"
            }
        }
        return ""
    }

    
    
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet]
    {
        var tweets = [Tweet]()
        
        for dictionary in dictionaries{
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
        }
        return tweets 
    }
}
