//
//  LoginViewController.swift
//  TwitterApp
//
//  Created by Pj Nguyen on 10/24/16.
//  Copyright © 2016 Pj Nguyen. All rights reserved.
//

import UIKit
import BDBOAuth1Manager


class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogin(_ sender: UIButton) {
        
        let client = TwitterClient.sharedInstance
        client?.login(success: { 
            print("i'm logged in")
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }, failure: { (error: NSError) in
                print(error.localizedDescription)
        })

    }
    

}
