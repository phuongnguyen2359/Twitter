//
//  ComposeTweetViewController.swift
//  TwitterApp
//
//  Created by Pj Nguyen on 10/26/16.
//  Copyright © 2016 Pj Nguyen. All rights reserved.
//

import UIKit

@objc protocol ComposeTweetViewControllerDelegate {
    @objc optional func composeTweetViewController(composeTweetViewController: ComposeTweetViewController,contentPosted content: String)
}


class ComposeTweetViewController: UIViewController {

    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var textContent: UITextView!
    @IBOutlet weak var wordCountLable: UILabel!
    @IBOutlet weak var onTweetButton: UIButton!
    
    @IBOutlet weak var keyBoardHeightConstraint: NSLayoutConstraint!
    var delegate: ComposeTweetViewControllerDelegate?
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textContent.text = "What's happending?"
        textContent.textColor = UIColor.lightGray
        textContent.becomeFirstResponder()
        textContent.delegate = self
        
        if let userProfileUrl = User.currentUser?.profileUrl{
            print("\(userProfileUrl)")
            profileImage.setImageWith(userProfileUrl as URL)
        }
        
        // move textfile when keyboard appears
        
        NotificationCenter.default.addObserver(self, selector: #selector(ComposeTweetViewController.onShowKeyboard(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ComposeTweetViewController.onHideKeyBoard(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func onCancelCompose(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTweet(_ sender: UIButton) {
        
        print("on tweet clicked \(textContent.text)")
        TwitterClient.sharedInstance?.postTweet(content: textContent.text, success: { 
            self.delegate?.composeTweetViewController!(composeTweetViewController: self, contentPosted: self.textContent.text)
            self.dismiss(animated: true, completion: nil)
            }, failure: { (error: NSError) in
                print(error.localizedDescription)
        })
    }
}


extension ComposeTweetViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "What's happending?"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text != "What's happending?" && textView.text != "" {
            wordCountLable.text = String(140 - textView.text.characters.count)
            onTweetButton.isUserInteractionEnabled = true
            onTweetButton.backgroundColor = UIColor.clear
        }
        else {
            onTweetButton.isUserInteractionEnabled = false
            onTweetButton.backgroundColor = UIColor.green
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText:NSString = textContent.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with:text)
        
        if updatedText.characters.count < 140 {
            return true
        }
        return false
    }
    
    func onShowKeyboard(_ notification: NSNotification){
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.keyBoardHeightConstraint.constant = keyboardFrame.size.height
        })
    }
    
    func onHideKeyBoard(_ notification: NSNotification){
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.keyBoardHeightConstraint.constant = 0
        })
    }
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textContent.resignFirstResponder()
    }

}

