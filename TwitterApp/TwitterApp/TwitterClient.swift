//
//  TwitterClient.swift
//  TwitterApp
//
//  Created by Pj Nguyen on 10/25/16.
//  Copyright © 2016 Pj Nguyen. All rights reserved.
//

import UIKit
import BDBOAuth1Manager


class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance  = TwitterClient(baseURL: NSURL(string: "https://api.twitter.com/") as URL!, consumerKey: "Hn3NfUEx5Zv2YdGgu2j0LEJA1", consumerSecret: "hyRhQUyDoDrBn2uOh9lWPJA8xS0olHBHMq6SoRWWaMFjfyAhIx")
    
    var loginSuccess: (()->())?
    var loginFailure: ((NSError)->())?
    
    func login(success: @escaping ()->(), failure: @escaping (NSError) -> ()) {
        
        loginSuccess = success
        loginFailure = failure
        // log out if the app still login in other device or before in other device
        TwitterClient.sharedInstance?.deauthorize()
        
        TwitterClient.sharedInstance?.fetchRequestToken(withPath: "oauth/request_token", method: "POST", callbackURL: URL(string: "mytwitter://auth"), scope: nil, success: { (response: BDBOAuth1Credential?) in
            print("got request token")
            
            if let response = response {
                let authURL = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(response.token!)")
                UIApplication.shared.openURL(authURL!)
            }
            else{
                print("response is nil")
            }
            
            }, failure: { (error:Error?) in
                print("error: \(error!.localizedDescription)")
                self.loginFailure?(error as! NSError)
        })
    }
    
    func logout(){
        User.currentUser = nil
        deauthorize()
    }
   
    func handleOpenUrl(url: NSURL){
     
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (response: BDBOAuth1Credential?) in
            print("i got access token \(response?.token)")

            self.currentAccount(success: { (user: User) in
                User.currentUser = user
                print("save current user")
                self.loginSuccess?()
                }, falilure: { (error: NSError) in
                print("cannot save current user")
                self.loginFailure?(error)
            })
       
        }, failure: { (error: Error?) in
            print("error: \(error?.localizedDescription)")
            self.loginFailure?(error as! NSError)
        })
    }
    
    
    func homeTimeLine(success: @escaping ([Tweet]) -> (), failure: @escaping (NSError) -> ()) {
        
    
        get("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response) in
            
            let tweetDictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries: tweetDictionaries)
            
            success(tweets) 
            }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error as NSError)
        })
    }
    
    func currentAccount(success: @escaping (User)-> (), falilure: (NSError) -> ()){
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response) in
            let userDictionary = response as! NSDictionary
            let user = User(dictionary: userDictionary)
            
            print("user: \(user.name)")
            print("current user \(user.profileUrl)")
            success(user)
            
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                self.loginFailure?(error as NSError)
        })

    }
    
    
    func postTweet(content: String, success: @escaping ()-> (), failure: @escaping (NSError)-> () ){

        var parameter: [String: AnyObject] = [:]
        parameter["status"] = content as AnyObject?
        post("1.1/statuses/update.json", parameters: parameter, progress: nil, success: { (task: URLSessionDataTask, response) in
            print("post status")
            success()
            
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                failure(error as NSError)
        })
    }
    
    func onFavorite(id: Int, success: @escaping ()->(), failure: @escaping (NSError)->()){
    
        var parameter: [String: AnyObject] = [:]
        parameter["id"] = id as AnyObject?
        post("1.1/favorites/create.json", parameters: parameter, progress: nil, success: { (task: URLSessionDataTask, response) in
            print("love tweet")
            success()
            
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                failure(error as NSError)
        })
    }
    
    func unFavorite(id: Int, success: @escaping ()->(), failure: @escaping (NSError)->()) {
        post("1.1/favorites/destroy.json", parameters: ["id": id], progress: nil, success: { (task: URLSessionDataTask, response) in
            print("unlove tweet")
            success()
            
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                failure(error as NSError)
        })
    }
    
    
    func onRetweet(id: Int, success: @escaping ()-> (), failure: @escaping (NSError)->()){
        //1.1/statuses/retweet/\(id).json"
        post("1.1/statuses/retweet/\(id).json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response) in
            print("on reTweet")
            success()
            
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                failure(error as NSError)
        })
        
    }
    
    func unRetweet(id: Int, success: @escaping ()-> (), failure: @escaping (NSError)->()){
        //1.1/statuses/retweet/\(id).json"
        post("1.1/statuses/unretweet/\(id).json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response) in
            print("un reTweet")
            success()
            
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                failure(error as NSError)
        })
    }
    
    func onReply(id: Int, text: String,success: @escaping ()->(), failure: @escaping (NSError)->()) {
        var parameter:[String: AnyObject] = [:]
        parameter["in_reply_to_status_id"] = id as AnyObject?
        parameter["status"] = text as String? as AnyObject?
        post("1.1/statuses/update.json", parameters: parameter, progress: nil, success: { (task: URLSessionDataTask, response) in
            print("reply successfully")
            success()
            
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                failure(error as NSError)
        })
    }
}
