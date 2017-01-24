//
//  LanguageViewController.swift
//  uoat
//
//  Created by Pyro User on 9/5/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import UIKit

class LanguageViewController: UIViewController
{

    weak var delegate:ExitDelegate?;
    
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
        closeButton.addTarget( self, action: #selector(LanguageViewController.closeDialog(_:)), forControlEvents: .TouchUpInside )
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
        
        //Tick selector
        let tickImg:UIImage = UIImage(named: "img_tick")!
        self.currentLanguageImage = UIImageView( image:tickImg )
        self.currentLanguageImage!.frame = CGRectMake( 25, 74, tickImg.size.width, tickImg.size.height )
        self.view.subviews.first?.addSubview(self.currentLanguageImage!)

        let checkPosX:CGFloat = (self.view.subviews.first?.bounds.width)! - tickImg.size.width - tickImg.size.width*0.5
        print("Current language:\(LanguageMgr.getInstance.getId())")
        for chkPos in self.checkPositions
        {
            if( chkPos.id == LanguageMgr.getInstance.getId() )
            {
                self.currentLanguageImage!.frame = CGRectMake( checkPosX, CGFloat(chkPos.y), tickImg.size.width, tickImg.size.height )
                break
            }
        }
        self.view.subviews.first?.addSubview(self.currentLanguageImage!)
        
        
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
        dismissViewControllerAnimated( true, completion: nil );
        delegate?.onCancel();
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //dismissViewControllerAnimated( true, completion: nil );
    
    
    /*=============================================================*/
    /*                          UI Section                         */
    /*=============================================================*/
    
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    
    
    @IBAction func spanish()
    {
        self.notifyChangeLanguage("es");
    }
    
    @IBAction func english()
    {
        self.notifyChangeLanguage("en");
    }
    
    @IBAction func german()
    {
        self.notifyChangeLanguage("de");
    }
    
    
    /*=============================================================*/
    /*                       Private Section                       */
    /*=============================================================*/
    private func notifyChangeLanguage( langId:String )
    {
        LanguageMgr.getInstance.setId( langId );
        dismissViewControllerAnimated( true, completion: nil );
        delegate?.onCancel();
        
        let message = Message( type:MessageType.changeLanguage, data:["langId":langId] );
        Observer.getInstance.sendMessage( message );
    }
 
    
    private var currentLanguageImage:UIImageView? = nil
    private let checkPositions:[(id:String,y:Int)] = [(id:"en",y:88),(id:"es",y:136),(id:"de",y:186)]
    
}
