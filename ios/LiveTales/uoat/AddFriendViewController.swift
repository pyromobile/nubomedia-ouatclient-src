//
//  AddFriendViewController.swift
//  uoat
//
//  Created by Pyro User on 16/6/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import UIKit

class AddFriendViewController: UIViewController, UITextFieldDelegate
{
    weak var user:User!
    weak var addFriendDelegate:AddFriendDelegate?
    
    required init?(coder aDecoder: NSCoder)
    {
        self.preparedKeyboard = false
        self.adjustedKeyboard = false
        
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddFriendViewController.networkStatusChanged(_:)), name: NetworkWatcher.reachabilityStatusChangedNotification, object: nil)
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver( self )
        print("AddFriendViewController - deInit....OK")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //Title header.
        let mutableAttrString = NSMutableAttributedString(string: headerLabel.text!,
                                attributes: [NSStrokeWidthAttributeName: -7.0,
                                NSFontAttributeName: UIFont(name: "ArialRoundedMTBold", size: 24)!,
                                NSStrokeColorAttributeName: UIColor.whiteColor(),
                                NSForegroundColorAttributeName: headerLabel.textColor ])
        headerLabel.attributedText! = mutableAttrString
        
        //Add blur efect to hide the last view.
        let blurEffectView:UIVisualEffectView = Utils.blurEffectView( self.view, radius: 10 )
        self.view.addSubview( blurEffectView )
        self.view.sendSubviewToBack( blurEffectView )
        
        //Keyboard
        self.friendsSecrectCodeText.addTarget(self, action: #selector(AddFriendViewController.prepareKeyboard(_:)), forControlEvents: UIControlEvents.TouchDown )
        self.friendsNickText.addTarget(self, action: #selector(AddFriendViewController.prepareKeyboard(_:)), forControlEvents: UIControlEvents.TouchDown )
        
        self.friendsSecrectCodeText.delegate = self
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func prepareKeyboard( sender:UITextField )
    {
        if( !self.preparedKeyboard )
        {
            self.preparedKeyboard = true
            //Keyboard.
            NSNotificationCenter.defaultCenter().addObserver( self, selector: #selector(AddFriendViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil )
            NSNotificationCenter.defaultCenter().addObserver( self, selector: #selector(AddFriendViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil )
        }
    }
    
    func adjustInsetForKeyboardShow(show: Bool, notification: NSNotification)
    {
        guard let value = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.CGRectValue()
        let adjustmentHeight = (CGRectGetHeight(keyboardFrame) - CGRectGetHeight(keyboardFrame)*0.5) * (show ? -1 : 1)
        self.view.frame.offsetInPlace(dx: 0, dy: adjustmentHeight )
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        if(!self.adjustedKeyboard)
        {
            self.adjustedKeyboard = true
            adjustInsetForKeyboardShow(true, notification: notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        self.adjustedKeyboard = false
        adjustInsetForKeyboardShow(false, notification: notification)
    }
    
    func networkStatusChanged(notification:NSNotification)
    {
        print("AddFriendViewController::networkStatusChanged was called...")
        if( NetworkWatcher.internetAvailabe )
        {
            Utils.alertMessage( self, title:"Notice", message:"Internet connection works again!", onAlertClose:nil )
        }
        else
        {
            Utils.alertMessage( self, title:"Attention", message:"Internet connection lost!", onAlertClose:nil )
        }
    }
    
    
    /*=============================================================*/
    /*                  from UITextFieldDelegate                   */
    /*=============================================================*/
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        var change:Bool = false
        
        if( textField == self.friendsSecrectCodeText )
        {
            let text = textField.text?.uppercaseString
            let text2 = (text! as NSString).stringByReplacingCharactersInRange( range, withString:string.uppercaseString )
            
            change = text2.characters.count <= 11
            if(change)
            {
                //Set uppercase string.
                textField.text = text2
                change = false
            }
        }
        
        return change
    }
    
    
    /*=============================================================*/
    /*                          UI Section                         */
    /*=============================================================*/
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var friendsSecrectCodeText: UITextField!
    @IBOutlet weak var friendsNickText: UITextField!
    
    
    //---------------------------------------------------------------
    //                         UI Actions
    //---------------------------------------------------------------
    @IBAction func sendRequest(sender: UIButton)
    {
        //Hide keyboard.
        self.view.endEditing( true )
        
        if( self.friendsSecrectCodeText.text?.isEmpty == false && self.friendsNickText.text?.isEmpty == false )
        {
            if( self.friendsSecrectCodeText.text != self.user.secretCode )
            {
                if( NetworkWatcher.internetAvailabe )
                {
                    let code:String = self.friendsSecrectCodeText.text!
                    let nick:String = self.friendsNickText.text!
                    NotificationModel.sendFriendshipRequest(self.user.id, friendSecrectCode: code, friendNick: nick, onFriendshipReady: { (error) in
                        if( !error )
                        {
                            Utils.alertMessage( self, title:"Info", message:"You request has been sent!", onAlertClose:{[weak self](action:UIAlertAction) in
                                self!.addFriendDelegate?.addPendingFriend( nick )
                                self!.dismissViewControllerAnimated( true, completion: nil);
                            })
                        }
                        else
                        {
                            Utils.alertMessage( self, title:"Warning!", message:"Imposible send your request.", onAlertClose:{[weak self] (action:UIAlertAction) in
                                self!.dismissViewControllerAnimated( true, completion: nil);
                            })
                        }
                    })
                }
                else
                {
                    Utils.alertMessage( self, title:"Attention", message:"You must have internet connection!", onAlertClose:nil )
                }
            }
            else
            {
                Utils.alertMessage( self, title:"Warning!", message:"You can't sent a request yourself!", onAlertClose:nil)
            }
        }
        else
        {
            Utils.alertMessage( self, title:"Warning!", message:"You must fill two fields.",onAlertClose:nil)
        }
    }
    
    @IBAction func cancel(sender: UIButton)
    {
        //Hide keyboard.
        self.view.endEditing( true );
        
        dismissViewControllerAnimated( true, completion: nil );
    }
    
    private var preparedKeyboard:Bool
    private var adjustedKeyboard:Bool
}
