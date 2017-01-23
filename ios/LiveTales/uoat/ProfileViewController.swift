//
//  ProfileViewController.swift
//  uoat
//
//  Created by Pyro User on 13/5/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController
{
    weak var user:User!
    weak var delegate:ProfileDelegate?
    
    required init?(coder aDecoder: NSCoder)
    {
        self.preparedKeyboard = false
        self.adjustedKeyboard = false
        
        super.init(coder: aDecoder)
    }
    
    deinit
    {
        self.user = nil
        self.delegate = nil
        NSNotificationCenter.defaultCenter().removeObserver( self )
        print("ProfileViewController - deInit....OK")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        
        //load resources.
        //.:Back button
        let leftArrowActiveImage:UIImage = Utils.flipImage( named: "btn_next_available", orientation: .Down )
        self.leftArrowImage.image = leftArrowActiveImage
        
        //Head title.
        let headAttrString = NSMutableAttributedString(string: self.headerLabel.text!,
                                                       attributes: [NSStrokeWidthAttributeName: -7.0,
                                                        NSFontAttributeName: UIFont(name: "ArialRoundedMTBold", size: 22)!,
                                                        NSStrokeColorAttributeName: UIColor.whiteColor(),
                                                        NSForegroundColorAttributeName: self.headerLabel.textColor ])
        self.headerLabel.attributedText! = headAttrString
        
        //Add blur efect to hide the last view.
        let blurEffectView:UIVisualEffectView = Utils.blurEffectView( self.view, radius: 10 )
        self.view.addSubview( blurEffectView )
        self.view.sendSubviewToBack( blurEffectView )
        
        userNickNameLabel.text = self.user.nick
        uniqueCodeLabel.text = self.user.secretCode //Utils.md5(string: "(\(self.user.name)\(self.user.password)\(self.user.id)")
        
        //Keyboard
        self.userNickNameLabel.addTarget(self, action: #selector(ProfileViewController.prepareKeyboard(_:)), forControlEvents: UIControlEvents.TouchDown )

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
            NSNotificationCenter.defaultCenter().addObserver( self, selector: #selector(ProfileViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil )
            NSNotificationCenter.defaultCenter().addObserver( self, selector: #selector(ProfileViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil )
        }
    }
    
    func adjustInsetForKeyboardShow(show: Bool, notification: NSNotification)
    {
        guard let value = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.CGRectValue()
        let adjustmentHeight = (CGRectGetHeight(keyboardFrame) + 0) * (show ? -1 : 1)
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

    
    /*=============================================================*/
    /*                          UI Section                         */
    /*=============================================================*/
    @IBOutlet weak var leftArrowImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var uniqueCodeLabel: UITextField!
    @IBOutlet weak var userNickNameLabel: UITextField!
    //@IBOutlet weak var userPasswordLabel: UITextField!
    
    @IBAction func back()
    {
        //Hide keyboard.
        self.view.endEditing( true )
        
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func copyUniqueUserId()
    {
        let pasteboard = UIPasteboard.generalPasteboard()
        pasteboard.string = "\(uniqueCodeLabel.text!)"
        Utils.alertMessage( self, title:"Info", message:"Unique code was copied to clipboard", onAlertClose: nil )
    }
    
    @IBAction func changeNick()
    {
        if( userNickNameLabel.text?.isEmpty == false )
        {
            self.user.nick = userNickNameLabel.text!
            UserModel.updateNick(self.user.id, nick: self.user.nick, uniqueCode: self.uniqueCodeLabel.text!, onUpdateNick: { [weak self](isOK) in
                if( isOK )
                {
                    Utils.alertMessage( self!, title: "Info", message: "Nick name was changed correctly!", onAlertClose: nil )
                }
                else
                {
                    Utils.alertMessage( self!, title: "Error", message: "Nick name wasn't changed!", onAlertClose: nil )
                }
            })
        }
        else
        {
            Utils.alertMessage( self, title:"Warning!", message:"You must fill this field.", onAlertClose: nil )
        }
    }
    
    @IBAction func logout(sender: UIButton)
    {
        UserModel.logout()
        
        //self.user.setProfile( "", name:"", password:"", secretCode: "" )
        self.user.reset()
        
        //Hide keyboard.
        self.view.endEditing( true );
        
        self.dismissViewControllerAnimated(true, completion:{ [unowned self] in
            self.delegate?.onProfileReady()
        })
    }
    
    @IBAction func changePassword()
    {
        /*
        if( userPasswordLabel.text?.isEmpty == false )
        {
            let userKuasars = KuasarsUser(internalToken: Utils.md5(string: self.user.password), andInternalIdentifier: self.user.name)
            userKuasars.changePassword(Utils.md5(string: userPasswordLabel.text!), oldPassword: Utils.md5(string: self.user.password)) { (response:KuasarsResponse!, error:KuasarsError!) -> Void in
                if( error != nil )
                {
                    print( "Error from kuasars \(error.description)" )
                    Utils.alertMessage( self, title: "Error", message: "Password wasn't changed!" )
                }
                else
                {
                    self.user.password = self.userPasswordLabel.text!
                    self.userPasswordLabel.text = ""
                    Utils.alertMessage( self, title: "Info", message: "Password was changed correctly!" )
                }
            }
        }
        else
        {
            Utils.alertMessage( self, title:"Warning!", message:"You must fill this field." )
        }
         */
    }
    
    private var preparedKeyboard:Bool
    private var adjustedKeyboard:Bool
}
