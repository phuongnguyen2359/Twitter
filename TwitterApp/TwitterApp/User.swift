//
//  User.swift
//  TwitterApp
//
//  Created by Pj Nguyen on 10/25/16.
//  Copyright © 2016 Pj Nguyen. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var name: String?
    var screenname: String?
    var profileUrl: NSURL?
    var tagline: String?
    var dictionary: NSDictionary?
    
    static  var _currentUser: User?
    let currentUserKey = "kCurrentUserKey"

    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
       
        if let profileUrlString = dictionary["profile_image_url_https"] as? String {
            self.profileUrl = NSURL(string: profileUrlString)
        }
        
        tagline = dictionary["description"] as? String

    }
    
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let userData = UserDefaults.standard.object(forKey: "currentUserData") as? NSData

                if let userData = userData {
                    
                    do {
                        let dictionary = try JSONSerialization.jsonObject(with: userData as Data, options: [])
                        _currentUser = User(dictionary: dictionary as! NSDictionary)
                    } catch  {
                        print("fail..........")
                    }
                }
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user
    
            if let user = user {
                do {
                    let data = try JSONSerialization.data(withJSONObject: user.dictionary!, options: JSONSerialization.WritingOptions())
                    
                    UserDefaults.standard.set(data, forKey: "currentUserData")
                    
                } catch {
                    print("JSON serialization failed:  \(error)")
                }
            }
            else {
                UserDefaults.standard.set(nil, forKey: "currentUserData")
            }
                UserDefaults.standard.synchronize()
        }
    }
    
    
    
    
    
}
