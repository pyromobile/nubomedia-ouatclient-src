//
//  LibraryViewController.swift
//  uoat
//
//  Created by Pyro User on 10/5/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import UIKit

class LibraryViewController: UIViewController {

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
        closeButton.addTarget( self, action: #selector(LibraryViewController.closeDialog(_:)), forControlEvents: .TouchUpInside )
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
        self.self.currentTaleImage = UIImageView( image:tickImg )
        self.self.currentTaleImage!.frame = CGRectMake( 25, 74, tickImg.size.width, tickImg.size.height )
        self.view.subviews.first?.addSubview(self.self.currentTaleImage!)
        
        let checkPosX:CGFloat = (self.view.subviews.first?.bounds.width)! - tickImg.size.width - tickImg.size.width*0.5
        self.view.subviews.first?.addSubview(self.currentTaleImage!)
        
        print("Current tale:\(Library.getInstance().getBook().getId())")
        for chkPos in self.checkPositions
        {
            if( chkPos.id == Library.getInstance().getBook().getId() )
            {
                self.currentTaleImage!.frame = CGRectMake( checkPosX, CGFloat(chkPos.y), tickImg.size.width, tickImg.size.height )
                break
            }
        }
        self.view.subviews.first?.addSubview(self.currentTaleImage!)
        
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
    
    
    /*=============================================================*/
    /*                          UI Section                         */
    /*=============================================================*/
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBAction func book1()
    {
        self.notifyChangeBook( "03_cr" );
    }

    @IBAction func book2()
    {
        self.notifyChangeBook( "01_rdo" );
    }
    
    @IBAction func book3()
    {
        self.notifyChangeBook( "02_l3c" );
    }

    
    /*=============================================================*/
    /*                       Private Section                       */
    /*=============================================================*/
    private func notifyChangeBook(bookId:String)
    {
        dismissViewControllerAnimated( true, completion: nil );
        delegate?.onCancel();
        
        let message = Message(type:MessageType.loadNewBook,data:["bookId":bookId]);
        Observer.getInstance.sendMessage( message );
    }
    
    private var currentTaleImage:UIImageView? = nil
    private let checkPositions:[(id:String,y:Int)] = [(id:"03_cr",y:88),(id:"01_rdo",y:136),(id:"02_l3c",y:186)]

}
