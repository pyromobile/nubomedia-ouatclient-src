//
//  LoginSignupViewController.swift
//  uoat
//
//  Created by Pyro User on 10/5/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import UIKit

class LoginSignupViewController: UIViewController
{
    weak var user:User!
    weak var delegate:LoginSignupDelegate?
    
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
        print("LoginSignupViewController - deInit....OK")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //Load resources
        //Arrow image (flipped).
        let leftArrowActiveImage:UIImage = Utils.flipImage(named: "btn_next_available", orientation: .Down)
        self.closeButton.setBackgroundImage( leftArrowActiveImage, forState: .Normal )
        self.closeButton.setBackgroundImage( leftArrowActiveImage, forState: .Highlighted )

        //Title header.
        //.:Log In
        let loginAttrString = NSMutableAttributedString(string: self.loginHeader.text!,
                attributes: [NSStrokeWidthAttributeName: -7.0,
                NSFontAttributeName: UIFont(name: "ArialRoundedMTBold", size: 22)!,
                NSStrokeColorAttributeName: UIColor.whiteColor(),
                NSForegroundColorAttributeName: self.loginHeader.textColor ])
        self.loginHeader.attributedText! = loginAttrString
        
        //.:Sign Up
        let signupAttrString = NSMutableAttributedString(string: self.signupHeader.text!,
            attributes: [NSStrokeWidthAttributeName: -7.0,
                NSFontAttributeName: UIFont(name: "ArialRoundedMTBold", size: 22)!,
                NSStrokeColorAttributeName: UIColor.whiteColor(),
                NSForegroundColorAttributeName: self.signupHeader.textColor ])
        self.signupHeader.attributedText! = signupAttrString
        
        //Keyboard
        self.loginUserField.addTarget(self, action: #selector(LoginSignupViewController.cleanKeyboard(_:)), forControlEvents: UIControlEvents.TouchDown )
        self.loginPasswordField.addTarget(self, action: #selector(LoginSignupViewController.cleanKeyboard(_:)), forControlEvents: UIControlEvents.TouchDown )
        self.signupUserField.addTarget(self, action: #selector(LoginSignupViewController.prepareKeyboard(_:)), forControlEvents: UIControlEvents.TouchDown )
        self.signupPasswordField.addTarget(self, action: #selector(LoginSignupViewController.prepareKeyboard(_:)), forControlEvents: UIControlEvents.TouchDown )
        self.signupPasswordRepeatField.addTarget(self, action: #selector(LoginSignupViewController.prepareKeyboard(_:)), forControlEvents: UIControlEvents.TouchDown )
        
        
        //Add blur efect to hide the last view.
        let blurEffectView:UIVisualEffectView = Utils.blurEffectView(self.view, radius: 10)
        self.view.addSubview(blurEffectView)
        self.view.sendSubviewToBack(blurEffectView)
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
            NSNotificationCenter.defaultCenter().addObserver( self, selector: #selector(LoginSignupViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil )
            NSNotificationCenter.defaultCenter().addObserver( self, selector: #selector(LoginSignupViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil )
        }
    }
    
    func cleanKeyboard( sender:UITextField )
    {
        self.preparedKeyboard = false
        //Keyboard.
        NSNotificationCenter.defaultCenter().removeObserver( self )
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
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var loginHeader: UILabel!
    @IBOutlet weak var loginUserField: UITextField!
    @IBOutlet weak var loginPasswordField: UITextField!

    @IBOutlet weak var signupHeader: UILabel!
    @IBOutlet weak var signupUserField: UITextField!
    @IBOutlet weak var signupPasswordField: UITextField!
    @IBOutlet weak var signupPasswordRepeatField: UITextField!
    
    //---------------------------------------------------------------
    //                         UI Actions
    //---------------------------------------------------------------
    @IBAction func back()
    {
        //Hide keyboard.
        self.view.endEditing( true );
        
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func login()
    {
        if( NetworkWatcher.internetAvailabe )
        {
            if( self.loginUserField.text?.isEmpty == false && self.loginPasswordField.text?.isEmpty == false )
            {
                let user:String = self.loginUserField.text!
                let password:String = self.loginPasswordField.text!
                self.doLogin( user, password:password )
            }
            else
            {
                Utils.alertMessage( self, title:Utils.localize("attention.title"), message:Utils.localize("attention.loginNeedsTwoFields"), onAlertClose:nil )
            }
        }
        else
        {
            //Hide keyboard.
            self.view.endEditing( true );
            
            Utils.alertMessage(self, title:Utils.localize("attention.title"), message:Utils.localize("attention.networkLost"), onAlertClose: { [unowned self] (action) in
                self.dismissViewControllerAnimated( true, completion:{} )
            })
        }
    }
    
    
    @IBAction func signup()
    {
        if( NetworkWatcher.internetAvailabe )
        {
            if( self.signupUserField.text?.isEmpty == false && self.signupPasswordField.text?.isEmpty == false && self.signupPasswordRepeatField.text?.isEmpty == false )
            {
                if( self.signupPasswordField.text == signupPasswordRepeatField.text )
                {
                    let user:String = self.signupUserField.text!
                    let password:String = self.signupPasswordField.text!
                    self.doSignup( user, password:password )
                }
                else
                {
                    Utils.alertMessage( self, title:Utils.localize("attention.title"), message:Utils.localize("attention.signupPasswordsMissMatch"), onAlertClose:nil )
                }
            }
            else
            {
                Utils.alertMessage( self, title:Utils.localize("attention.title"), message:Utils.localize("attention.signupNeedsThreeFields"), onAlertClose:nil )
            }
        }
        else
        {
            Utils.alertMessage(self, title:Utils.localize("attention.title"), message:Utils.localize("attention.networkLost"), onAlertClose: { [unowned self] (action) in
                //Hide keyboard.
                self.view.endEditing( true );
                self.dismissViewControllerAnimated(true, completion: {})
            })
        }
    }
    
    
    /*=============================================================*/
    /*                       Private Section                       */
    /*=============================================================*/    
    private func doLogin( userName:String, password: String )
    {
        UserModel.login( userName, password:Utils.md5(string:password)) { [weak self](isOK, userId, nick, code) in
            if( isOK )
            {
                //Hide keyboard.
                self!.view.endEditing( true );
                
                self!.user.setProfile( userId, name:userName, password:password, secretCode: code )
                self!.user.nick = nick
                self!.dismissViewControllerAnimated(true, completion: {[weak self] in
                    self!.delegate?.onLoginSignupReady()
                })
            }
            else
            {
                Utils.alertMessage( self!, title:Utils.localize("error.title"), message:Utils.localize("error.loginUserWrong"), onAlertClose:nil )
            }
        }
    }
    
    private func doSignup( userName:String, password:String )
    {
        let secretCode:String = Utils.randomString(10)
        UserModel.signup( userName, password:Utils.md5(string:password), secretCode:secretCode ) { [weak self](isOK,userId) in
            if( isOK )
            {
                //Hide keyboard.
                self!.view.endEditing( true );
                
                self!.user.setProfile( userId, name:userName, password:password, secretCode:secretCode )
                self!.user.nick = "Guest"
                self!.dismissViewControllerAnimated( true, completion:{[weak self] in
                    self!.delegate?.onLoginSignupReady()
                })
            }
            else
            {
                Utils.alertMessage( self!, title:Utils.localize("error.title"), message:Utils.localize("error.loginUserWrong"), onAlertClose:nil )
            }
        }
    }
    
    
    private var preparedKeyboard:Bool
    private var adjustedKeyboard:Bool
}
