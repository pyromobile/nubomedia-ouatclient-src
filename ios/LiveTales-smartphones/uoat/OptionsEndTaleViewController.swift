//
//  OptionsEndTaleViewController.swift
//  uoat
//
//  Created by Pyro User on 31/5/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import UIKit

class OptionsEndTaleViewController: UIViewController, ExitDelegate
{

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Load resources
        //Arrow image (flipped).
        let leftArrowActiveImage:UIImage = Utils.flipImage(named: "btn_next_available", orientation: .Down)
        
        //Close button (header)
        let closeButton = UIButton()
        closeButton.frame = CGRectMake( 10, 10, leftArrowActiveImage.size.width, leftArrowActiveImage.size.height )
        closeButton.addTarget( self, action: #selector(OptionsEndTaleViewController.closeDialog(_:)), forControlEvents: .TouchUpInside )
        closeButton.setBackgroundImage( leftArrowActiveImage, forState: .Normal )
        closeButton.setBackgroundImage( leftArrowActiveImage, forState: .Highlighted )
        
        self.view.subviews.first?.addSubview( closeButton )
        
        //Title header.
        let mutableAttrString = NSMutableAttributedString(string: headerLabel.text!,
            attributes: [NSStrokeWidthAttributeName: -7.0,
                NSFontAttributeName: UIFont(name: "ArialRoundedMTBold", size: 20)!,
                NSStrokeColorAttributeName: UIColor.whiteColor(),
                NSForegroundColorAttributeName: headerLabel.textColor ])
        headerLabel.attributedText! = mutableAttrString

        //Add blur efect to hide the last view.
        let blurEffectView:UIVisualEffectView = Utils.blurEffectView(self.view, radius: 10)
        self.view.addSubview(blurEffectView)
        self.view.sendSubviewToBack(blurEffectView)
    }

    override func viewDidLayoutSubviews()
    {
        let x:Int = Int(self.view.bounds.width)/2 - Int(self.dialogView.bounds.width)/2
        let y:Int = Int(self.view.bounds.height)/2 - Int(self.dialogView.bounds.height)/2
        
        self.dialogView.frame = CGRect(x: x, y: y, width: Int(self.dialogView.frame.width), height: Int(self.dialogView.frame.height))
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
    
    func closeDialog(sender: UIButton)
    {
        self.dismissViewControllerAnimated( true, completion: nil );
        //delegate?.notify();
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    /*=============================================================*/
    /*                       From ExitDelegate                     */
    /*=============================================================*/
    func onCancel()
    {
        self.dismissViewControllerAnimated(true, completion:nil )
    }
    
    func onExit()
    {
    }
    
    
    /*=============================================================*/
    /*                          UI Section                         */
    /*=============================================================*/
    
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBAction func repeatTale(sender: UIButton)
    {
        let message = Message(type:MessageType.repeatTale,data:["empty":"empty"]);
        Observer.getInstance.sendMessage( message );
        
        self.dismissViewControllerAnimated( true, completion: nil );
    }
    
    @IBAction func chooseOtherTale(sender: UIButton)
    {
        //Show library dialog.
        //self.performSegueWithIdentifier( "showLibraryView", sender: nil )
        
        let libraryViewController = self.storyboard?.instantiateViewControllerWithIdentifier( "libraryViewController" ) as? LibraryViewController;
        libraryViewController?.delegate = self
        self.presentViewController( libraryViewController!, animated: true, completion:{()->Void in
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                //self.view.hidden = true
                self.view.alpha = 0.0
            })
        })
    }
    
    @IBAction func backToMainMenu(sender: UIButton)
    {
        let mainViewController = self.storyboard?.instantiateViewControllerWithIdentifier( "mainViewController" ) as? ViewController;
        mainViewController!.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        self.presentViewController( mainViewController!, animated: true, completion: nil );

    }
}
