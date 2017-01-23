//
//  ExitViewController.swift
//  uoat
//
//  Created by Pyro User on 31/5/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import UIKit

class ExitViewController: UIViewController
{
    weak var delegate:ExitDelegate?;
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    /*=============================================================*/
    /*                          UI Section                         */
    /*=============================================================*/
    
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var headerLabel: UILabel!


    //---------------------------------------------------------------
    //                         UI Actions
    //---------------------------------------------------------------
    @IBAction func exit(sender: UIButton)
    {
        /*
        let mainViewController = self.storyboard?.instantiateViewControllerWithIdentifier( "mainViewController" ) as? ViewController
        mainViewController!.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        
        //self.navigationController?.presentViewController( mainViewController!, animated: true, completion: nil )
        self.presentViewController( mainViewController!, animated: true, completion: nil )
         */
        dismissViewControllerAnimated(true) { 
            self.delegate?.onExit()
        }
    }
    
    @IBAction func cancel(sender: UIButton)
    {
        dismissViewControllerAnimated(true) { 
            self.delegate?.onCancel()
        }
    }
}
