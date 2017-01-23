//
//  FreeModeViewController.swift
//  uoat
//
//  Created by Pyro User on 24/6/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import UIKit

class FreeModeViewController: UIViewController, ExitDelegate, Observable, RoomReadyDelegate
{
    weak var user:User!
    var bgImagePath:String!
    
    deinit
    {
        self.roomModel = nil
        self.activityIndicator = nil
        self.loadingView = nil
        self.bgImagePath = nil
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.prepareView()
        
        Observer.getInstance.subscribe( self, message: MessageType.changeAccesory )

        //Room model.
        self.roomModel = RoomModel( delegate:self, video1View:meView, video2View:friend1View, video3View:friend2View, video4View:friend3View )
        
        var userNick = "Guest\(Int(arc4random_uniform( 10000 ) ) )"
        if( self.user.isLogged() )
        {
            userNick = self.user.nick
        }
        let roomName = self.user.roomId
        self.roomModel!.joinRoom( userNick, roomName: roomName )
        
        //let value = UIInterfaceOrientation.Portrait.rawValue
        //UIDevice.currentDevice().setValue(value, forKey: "orientation")
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        if( self.isFirstTime )
        {
            self.isFirstTime = false
            
            /*
            //Hide renderer views.
            self.meView.alpha = 0.0
            self.userButtonsView.alpha = 0.0
            
            self.friend1View.alpha = 0.0
            self.friend2View.alpha = 0.0
            self.friend3View.alpha = 0.0
            */
            self.showUserUI( false )
            
            
            //Add view loading...
            self.loadingView = UIView(frame:self.view.bounds)
            self.loadingView!.center = self.view.center
            self.loadingView!.backgroundColor = UIColor.blackColor()
            self.loadingView!.clipsToBounds = true
            self.loadingView!.layer.zPosition = 1
            
            self.activityIndicator = UIActivityIndicatorView()
            self.activityIndicator!.frame = CGRectMake( 0, 0, 80, 80 )
            self.activityIndicator!.activityIndicatorViewStyle = .WhiteLarge
            self.activityIndicator!.center = CGPointMake( self.loadingView!.bounds.width/2, self.loadingView!.bounds.height/2 )
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        self.view.alpha = 1.0
        
        dispatch_async(dispatch_get_main_queue(), { [unowned self] in
            self.loadingView!.addSubview( self.activityIndicator! )
            self.view.addSubview( self.loadingView! )
            self.activityIndicator!.startAnimating()
            print("Activity indicator esta funcionando...")
        })
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        Observer.getInstance.unsubscribe(self, message: MessageType.changeAccesory )
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true;
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if( segue.identifier == "showExitView" )
        {
            let controller = segue.destinationViewController as! ExitViewController
            controller.delegate = self
        }
    }

    
    /*=============================================================*/
    /*                        From Obervable                       */
    /*=============================================================*/
    func notify( message: Message )
    {
        switch( message.type )
        {
            case MessageType.changeAccesory:
                self.roomModel?.putAccesory( message.data["accesoryId"]! as! String, pack:message.data["pack"]! as! String )
                break
            default:
                break
        }
    }
    
    func equals(other: Observable) -> Bool
    {
        return other.dynamicType.self === self.dynamicType.self
    }

    
    /*=============================================================*/
    /*                      From ExitDelegate                      */
    /*=============================================================*/
    func onCancel()
    {
        //Nothing...
    }
    
    func onExit()
    {
        self.isUserGoBack = true
        Observer.getInstance.unsubscribe( self, message: MessageType.changeAccesory )
        self.roomModel!.leaveRoom { [weak self] in
           UIView.animateWithDuration(1.25, animations: { [weak self] in
                self?.showUserUI( false )
                },completion: {[weak self](finished:Bool) in
                    self?.performSegueWithIdentifier( "goToMainView", sender:self );
            })
        }
    }

    
    /*=============================================================*/
    /*                    From RoomReadyDelegate                   */
    /*=============================================================*/
    func onReady()
    {
        dispatch_async(dispatch_get_main_queue(), {[unowned self] in
            print("Parando activity indicator....")
            self.activityIndicator!.stopAnimating()
            self.activityIndicator!.removeFromSuperview()
            self.loadingView!.removeFromSuperview()
            print("Activity indicator parado OK!")
            self.bgMainImage.alpha = 1.0
            UIView.animateWithDuration(1.5) { [unowned self] in
                /*
                self.meView.alpha = 1.0
                self.userButtonsView.alpha = 1.0
                self.friend1View.alpha = 1.0
                self.friend2View.alpha = 1.0
                self.friend3View.alpha = 1.0
                 */
                self.showUserUI( true )
            }
        });
    }
    
    func onError(code:Int)
    {
        if( !self.isUserGoBack )
        {
            let messageError:String = self.getMessageErrorByCode( code )
            Utils.alertMessage(self, title: "Error", message: messageError) { [unowned self](action) in
                
                dispatch_async(dispatch_get_main_queue(), {[unowned self] in
                    print("Parando activity indicator....")
                    self.activityIndicator!.stopAnimating()
                    self.activityIndicator!.removeFromSuperview()
                    self.loadingView!.removeFromSuperview()
                    print("Activity indicator parado OK!")
                    self.bgMainImage.alpha = 1.0
                    UIView.animateWithDuration(1.5) { [unowned self] in

                        self.showUserUI( true )
                        
                        //User leaves the room.
                        self.user.acceptedRoomInvitation = false
                        self.user.roomId = ""
                        self.user.isNarrator = false
                        
                        self.performSegueWithIdentifier( "goToMainView", sender:self );
                    }
                });
            }
        }
        else
        {
            UIView.animateWithDuration(1.5) { [unowned self] in
                self.performSegueWithIdentifier( "goToMainView", sender:self );
            }
        }
    }
    
    /*=============================================================*/
    /*                          UI Section                         */
    /*=============================================================*/
    @IBOutlet weak var bgMainImage: UIImageView!
    @IBOutlet weak var leftArrowImage: UIImageView!
    @IBOutlet weak var friend1View: UIView!
    @IBOutlet weak var friend2View: UIView!
    @IBOutlet weak var friend3View: UIView!
    @IBOutlet weak var meView: UIView!
    @IBOutlet weak var userButtonsView: UIView!

    //---------------------------------------------------------------
    //                         UI Actions
    //---------------------------------------------------------------
    @IBAction func backMainMenu(sender: UIButton)
    {
        //User leaves the room.
        self.user.acceptedRoomInvitation = false
        self.user.roomId = ""
        self.user.isNarrator = false
        
        performSegueWithIdentifier("showExitView", sender: nil);
    }
    
    @IBAction func showAccesories(sender: UIButton)
    {
        performSegueWithIdentifier("showAccesoriesView", sender: nil);
    }
    
    @IBAction func takePhoto(sender: UIButton)
    {
        /*RELOCATED IN UTILS.
        UIGraphicsBeginImageContextWithOptions(self.meView.bounds.size, true, 0)
        self.meView.drawViewHierarchyInRect(self.meView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Save image in device.
        
        //.:Generate image name.
        let today:NSDate = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let strDateFormat = formatter.stringFromDate( today )
        let fileName:String = "ouat-snapshot-\(strDateFormat).jpg"
        
        //.:Get path to save.
        let documentsURL:NSURL = NSFileManager.defaultManager().URLsForDirectory( .DocumentDirectory, inDomains:.UserDomainMask )[0]
        let fileURL:NSURL = documentsURL.URLByAppendingPathComponent( fileName )
        let imagePath:String = fileURL.path!
        
        print("PATH to save image:\(imagePath)")
        
        //.:Save image as jpg file.
        let jpgImageData:NSData = UIImageJPEGRepresentation( image, 1.0 )!
        let isSavedOk:Bool = jpgImageData.writeToFile( imagePath, atomically:true )
         */
        let isSavedOk:Bool = Utils.saveImageFromView( self.meView )
        if( isSavedOk )
        {
            Utils.alertMessage(self, title: "Take photo", message: "saved ok!", onAlertClose: nil )
        }
        else
        {
            Utils.alertMessage(self, title: "Take photo", message: "error in save photo!", onAlertClose: nil)
        }
    }
    
    @IBAction func showCostumes(sender: AnyObject)
    {
    }
    
    
    /*=============================================================*/
    /*                       Private Section                       */
    /*=============================================================*/
    private func prepareView()
    {
        //Common.
        //load resources.
        //.:Back button
        let leftArrowActiveImage:UIImage = Utils.flipImage( named: "btn_next_available", orientation: .Down )
        self.leftArrowImage.image = leftArrowActiveImage

        if( self.bgMainImage.image == nil )
        {
            self.bgMainImage.image = UIImage( contentsOfFile:self.bgImagePath )!
            let blurEffectView:UIVisualEffectView = Utils.blurEffectView( self.bgMainImage, radius:6 )   //3
            self.bgMainImage.addSubview( blurEffectView )
            self.bgMainImage.alpha = 0.0
        }
    }
    
    private func showUserUI(show:Bool)
    {
        let alphaValue:CGFloat = show ? 1.0 : 0.0
        
        self.meView.alpha = alphaValue
        self.userButtonsView.alpha = alphaValue
        self.friend1View.alpha = alphaValue
        self.friend2View.alpha = alphaValue
        self.friend3View.alpha = alphaValue
    }
    
    private func getMessageErrorByCode( code:Int ) -> String
    {
        let msg:String
        switch code {
        case ServerResponseCode.DataBaseConfigFail:
            msg = "Can\'t get KMS config from database!"
            break
        case ServerResponseCode.NoInternetConnection:
            msg = "You can\'t get KMS config\nbecause you haven\'t internet connection!"
            break
        case ServerResponseCode.ServerNotWorking:
            msg = "Server is not working!"
            break
        case ServerResponseCode.RoomIsFull:
            msg = "Too late! The room is full!"
            break
        default:
            msg = "Unknown error"
        }
        
        return msg
    }

    
    //var isFirstTime:Bool = true
    internal private(set) var isFirstTime:Bool = true
    
    private var roomModel:RoomModel? = nil
    private var loadingView:UIView?
    private var activityIndicator:UIActivityIndicatorView?
    
    private var isUserGoBack:Bool = false
}
