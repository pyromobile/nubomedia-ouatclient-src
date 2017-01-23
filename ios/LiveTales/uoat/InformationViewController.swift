//
//  InformationViewController.swift
//  uoat
//
//  Created by Pyro User on 23/6/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import UIKit

class InformationViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
    @IBOutlet weak var leftArrowImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    
    
    //---------------------------------------------------------------
    //                         UI Actions
    //---------------------------------------------------------------
    @IBAction func back(sender: UIButton)
    {
        self.dismissViewControllerAnimated(true, completion: {})
    }
}
