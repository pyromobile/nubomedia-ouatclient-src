//
//  TaleModeViewController.swift
//  uoat
//
//  Created by Pyro User on 4/5/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import UIKit

extension String:CollectionType{};

class TaleModeViewController: UIViewController, UIGestureRecognizerDelegate, Observable, RoomReadyDelegate, OptionsEndTaleDelegate
{
    weak var user:User!
    var isInternetAvailable:Bool = true
    
    required init?(coder aDecoder: NSCoder)
    {
        //Cogemos el libro seleccionado.
        self.book = Library.getInstance().getBook()
        
        self.originalTaleImageSize = CGRectMake(0,0,0,0)
        self.originalTaleTextContainerSize = CGRectMake(0,0,0,0)
        self.originalTaleTextSize  = CGRectMake(0,0,0,0)
        self.originalArrowRightPosition = CGRectMake(0,0,0,0)
        self.originalArrowRightButtonPosition = CGRectMake(0,0,0,0)
        self.sublayers = [UIView:[CALayer]]()
        
        //Full/Exit images
        self.fullScreenImage = UIImage( named: "btn_fullscreen" )!
        self.exitFullScreenImage = UIImage( named: "btn_exit_fullscreen" )!
        
        //Arrow images.
        self.rightArrowActiveImage = UIImage( named: "btn_next_available" )!
        self.rightArrowDisableImage = UIImage( named: "btn_next_idle" )!
        
        //Filp arrow image.
        self.leftArrowActiveImage =  Utils.flipImage(named: "btn_next_available", orientation: .Down)
        self.leftArrowDisableImage = Utils.flipImage(named: "btn_next_idle", orientation: .Down)

        self.isTransitionWorking = false
        
        //FadeInOutImages.
        self.fadeInOutImages = [Int:UIImageView]()
        
        super.init(coder: aDecoder);
    }
    
    deinit
    {
        for var item in self.sublayers
        {
            item.1.removeAll()
        }
        self.sublayers.removeAll()
        
        self.activityIndicator = nil
        self.loadingView = nil
        self.roomModel = nil
        
        print("TaleModeViewController - deInit....OK")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.prepareView()
        
        Observer.getInstance.subscribe( self, message: MessageType.changeLanguage )
        //Observer.getInstance.subscribe( self, message: MessageType.changeFont )
        //Observer.getInstance.subscribe( self, message: MessageType.changeMediaCtrl )
        //Observer.getInstance.subscribe( self, message: MessageType.loadNewBook )
        //Observer.getInstance.subscribe( self, message: MessageType.repeatTale )
        Observer.getInstance.subscribe( self, message: MessageType.remoteChangePage )
        Observer.getInstance.subscribe( self, message: MessageType.changeAccesory )
        Observer.getInstance.subscribe( self, message: MessageType.syncBook )
        
        if( self.isInternetAvailable )
        {
            //Room model.
            self.roomModel = RoomModel( delegate:self, isReadingRoom:true, video1View: meView, video2View: friend1View, video3View: friend2View, video4View: friend3View /*, video5View: friend4View*/)
            var userNick = "Guest\(Int(arc4random_uniform( 10000 ) ) )"
            if( self.user.isLogged() )
            {
                userNick = self.user.nick
            }
            let roomName = self.user.roomId
            
            self.roomModel!.joinRoom( userNick, roomName: roomName )
        }
        //Force orientation.
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        self.isVisible = true
    }

    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        if( self.isFirstCall )
        {
            self.isFirstCall = false

            //Hide controls...
            self.showUserUI( false )
            
            //Add view loading...
            self.loadingView = UIView(frame: self.view.bounds)
            self.loadingView!.center = self.view.center
            self.loadingView!.backgroundColor = UIColor.blackColor()
            self.loadingView!.clipsToBounds = true
            self.loadingView!.layer.zPosition = 1
            
            self.activityIndicator = UIActivityIndicatorView()
            self.activityIndicator!.frame = CGRectMake( 0, 0, 80, 80 )
            self.activityIndicator!.activityIndicatorViewStyle = .WhiteLarge
            self.activityIndicator!.center = CGPointMake( self.loadingView!.bounds.width/2, self.loadingView!.bounds.height/2 )
        }
        else
        {
            self.loadingView!.frame = self.view.bounds
            self.loadingView!.center = self.view.center
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
            
            if( !self.isInternetAvailable )
            {
                self.onReady()
            }
        })
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        print("Me voy....")
        Observer.getInstance.unsubscribe( self, message: MessageType.changeLanguage )
        //Observer.getInstance.unsubscribe( self, message: MessageType.changeFont )
        //Observer.getInstance.unsubscribe( self, message: MessageType.changeMediaCtrl )
        //Observer.getInstance.unsubscribe( self, message: MessageType.loadNewBook )
        //Observer.getInstance.unsubscribe( self, message: MessageType.repeatTale )
        Observer.getInstance.unsubscribe( self, message: MessageType.remoteChangePage )
        Observer.getInstance.unsubscribe( self, message: MessageType.changeAccesory )
        Observer.getInstance.unsubscribe( self, message: MessageType.syncBook )
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
        if( segue.identifier == "showAccesoriesView" )
        {
            let controller = segue.destinationViewController as! AccesoriesViewController
            controller.pack = self.book?.getId()
        }
        else if( segue.identifier == "optionsEndTaleView" )
        {
            let controller = segue.destinationViewController as! OptionsEndTaleViewController
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
            case MessageType.changeLanguage:
                Library.getInstance().changeLanguage( message.data["langId"]! as! String )
                let page = self.book!.changeLanguage( message.data["langId"]! as! String )
                
                self.FontSizeMax = self.FontSizeMaxByLang[message.data["langId"]! as! String]!
                
                self.updateView( page )
                break
            
            /* by delegate.
            case MessageType.loadNewBook:
                //TODO: poner algo por delante a modo de carga...
                Library.getInstance().setBookIdSelected(message.data["bookId"]! as! String)
                self.book = Library.getInstance().getBook()
                let page = self.book!.load()
                
                if( self.isFullTale )
                {
                    self.showTaleInNormalMode()
                }
                self.isFirstTime = true
                
                //TODO:Quitar algo en modo de carga.
                self.updateView( page )
                break
            */
            /* by delegate.
            case MessageType.repeatTale:
                self.isFirstTime = true
                let pageToShow:Page = self.book!.goBegin()
                self.updateView( pageToShow )
                break
            */
            case MessageType.remoteChangePage:
                let action:String = message.data["action"]! as! String
                if( action == "prev" )
                {
                    self.doPrevPage()
                }
                else if( action == "next" )
                {
                    self.doNextPage()
                }
                break

            case MessageType.changeAccesory:
                self.roomModel!.putAccesory(message.data["accesoryId"]! as! String, pack: message.data["pack"]! as! String)
                break
            
            case MessageType.syncBook:
                let bookId:String = message.data["id"] as! String
                let pageNum:Int = message.data["currentPage"] as! Int
                let languageId:String = message.data["langId"] as! String
                
                Library.getInstance().changeLanguage( languageId )
                Library.getInstance().setBookIdSelected( bookId )
                self.book = Library.getInstance().getBook()
                self.book!.load()
                let page = self.book!.goToPage( pageNum )
                self.updateView( page )
                
                dispatch_async(dispatch_get_main_queue(), {[unowned self] in
                    print("Parando activity indicator....")
                    self.activityIndicator!.stopAnimating()
                    self.activityIndicator!.removeFromSuperview()
                    self.loadingView!.removeFromSuperview()
                    print("Activity indicator parado OK!")
                    
                    UIView.animateWithDuration(1.5) { [unowned self] in
                        self.showUserUI( true )
                    }
                });
            break
            
            default:
                break
        }
    }
    
    func equals(other: Observable) -> Bool
    {
        return other.dynamicType.self === self.dynamicType.self
    }
    
    let swipeGestureLeft = UISwipeGestureRecognizer()
    let swipeGestureRight = UISwipeGestureRecognizer()
    

    /*=============================================================*/
    /*                    From RoomReadyDelegate                   */
    /*=============================================================*/
    func onReady()
    {
        if( !self.user.acceptedRoomInvitation )
        {
            //preparamos el libro.
            let bookId:String = Library.getInstance().getBook().getId()
            let langId:String = LanguageMgr.getInstance.getId()
            
            self.FontSizeMax = self.FontSizeMaxByLang[langId]!
            
            self.roomModel?.prepareBook( bookId, langId:langId )
            
            dispatch_async(dispatch_get_main_queue(), {[unowned self] in
                print("Parando activity indicator....")
                self.activityIndicator!.stopAnimating()
                self.activityIndicator!.removeFromSuperview()
                self.loadingView!.removeFromSuperview()
                print("Activity indicator parado OK!")
                
                UIView.animateWithDuration(1.5) { [unowned self] in
                    self.showUserUI( true )
                }
            });
        }
        else
        {
            //pedioms el libro que se está leyendo en la habitación.
            self.roomModel!.requestBook()
        }
        
        self.roomModel?.getPacks()
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
                    //self.bgMainImage.alpha = 1.0
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
    /*                  From OptionsEndTaleDelegate                */
    /*=============================================================*/
    func onExit()
    {
        self.isUserGoBack = true
        if( self.isInternetAvailable )
        {
            self.roomModel!.leaveRoom { [weak self] in
                
                UIView.animateWithDuration(1.25, animations: { [weak self] in
                    self?.showUserUI( false )
                    },completion: {[weak self](finished:Bool) in
                        self!.performSegueWithIdentifier("goToMainView", sender: self)
                    })
            }
        }
        else
        {
            UIView.animateWithDuration(1.25, animations: { [weak self] in
                self?.showUserUI( false )
                },completion: {[weak self](finished:Bool) in
                    self!.performSegueWithIdentifier("goToMainView", sender: self)
                })
        }
    }
    
    func onRepeatTale()
    {
        self.isFirstTime = true
        let pageToShow:Page = self.book!.goBegin()
        self.updateView( pageToShow )
    }
    
    func onChooseOtherTale(bookId:String)
    {
        //TODO: poner algo por delante a modo de carga...
        Library.getInstance().setBookIdSelected( bookId )
        self.book = Library.getInstance().getBook()
        let page = self.book!.load()
        
        if( self.isFullTale )
        {
            self.showTaleInNormalMode()
        }
        self.isFirstTime = true
        
        //TODO:Quitar algo en modo de carga.
        self.updateView( page )
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func handleSwipeLeft( gesture: UISwipeGestureRecognizer )
    {
        self.doNextPage()
    }
    
    func handleSwipeRight( gesture: UISwipeGestureRecognizer )
    {
        self.doPrevPage()
    }
    
    func toggleTaleView( sender:UIButton )
    {
        if( self.isTransitionWorking )
        {
            return
        }

        self.isTransitionWorking = true
        if( !self.isFullTale )
        {
            self.showTaleInFullMode()
        }
        else
        {
            self.showTaleInNormalMode()
        }
    }
    
    func willTakePhoto(sender: UIButton!)
    {
        if( self.isInternetAvailable )
        {
            let isSavedOk:Bool = Utils.saveImageFromView( self.meView )
            if( isSavedOk )
            {
                Utils.alertMessage(self, title:Utils.localize("takePhoto.title"), message:Utils.localize("takePhoto.ok"), onAlertClose: nil )
            }
            else
            {
                Utils.alertMessage(self, title:Utils.localize("takePhoto.title"), message:Utils.localize("takePhoto.error"), onAlertClose: nil)
            }
        }
    }
    
    func willShowCostumes(sender: UIButton!)
    {
        print("Show costumes...")
    }
    
    func willShowAccesories(sender: UIButton!)
    {
        if( self.isInternetAvailable )
        {
            performSegueWithIdentifier("showAccesoriesView", sender: nil);
        }
    }

    func willDoPrevPage( sender:UIButton )
    {
        self.doPrevPage()
    }
    
    func willDoNextPage( sender:UIButton )
    {
        self.doNextPage()
    }
    
    /*
    func onExit()
    {
        self.isUserGoBack = true
        if( self.isInternetAvailable )
        {
            self.roomModel!.leaveRoom { [weak self] in
            
                UIView.animateWithDuration(1.25, animations: { [weak self] in
                        self?.showUserUI( false )
                    },completion: {[weak self](finished:Bool) in
                        self!.performSegueWithIdentifier("goToMainView", sender: self)
                })
            }
        }
        else
        {
            UIView.animateWithDuration(1.25, animations: { [weak self] in
                self?.showUserUI( false )
                },completion: {[weak self](finished:Bool) in
                    self!.performSegueWithIdentifier("goToMainView", sender: self)
            })
        }
    }
    */
    
    /*=============================================================*/
    /*                          UI Section                         */
    /*=============================================================*/
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var toggleTaleViewButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var taleImage: UIImageView!
    @IBOutlet weak var taleText: UITextView!
    @IBOutlet weak var taleTextViewContainer: UIView!
    
    @IBOutlet weak var arrowLeftButton: UIButton!
    @IBOutlet weak var arrowLeft: UIImageView!
    @IBOutlet weak var arrowRightButton: UIButton!
    @IBOutlet weak var arrowRight: UIImageView!
    
    @IBOutlet weak var containerTakePhotoImage: UIImageView!
    @IBOutlet weak var takePhoto: UIButton!
    @IBOutlet weak var showCostumes: UIButton!
    @IBOutlet weak var showAccesiries: UIButton!
    @IBOutlet weak var userButtonsView: UIView!
    
    @IBOutlet weak var meView: UIView!
    @IBOutlet weak var friend1View: UIView!
    @IBOutlet weak var friend2View: UIView!
    @IBOutlet weak var friend3View: UIView!
    
    
    /*=============================================================*/
    /*                       Private Section                       */
    /*=============================================================*/
    private func prepareView()
    {
        //Common.
        self.isFirstTime = true

        if( self.revealViewController() != nil )
        {
            self.revealViewController().rightViewRevealWidth = 290.0    //Size white box options.
            self.revealViewController().rearViewRevealWidth = 290.0     //Size white box options.
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.translucent = true
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        }
        
        //.:UIButtons.
        self.toggleTaleViewButton.addTarget(self, action:#selector(TaleModeViewController.toggleTaleView(_:)), forControlEvents:.TouchUpInside )
        self.arrowLeft.frame = CGRectMake(0,0,self.leftArrowActiveImage.size.width, self.leftArrowActiveImage.size.height)
        self.arrowLeft.image = self.leftArrowDisableImage
        self.takePhoto.addTarget( self, action:#selector(TaleModeViewController.willTakePhoto(_:)), forControlEvents:.TouchUpInside )
        self.showCostumes.addTarget( self, action:#selector(TaleModeViewController.willShowCostumes(_:)), forControlEvents:.TouchUpInside )
        self.showAccesiries.addTarget( self, action:#selector(TaleModeViewController.willShowAccesories(_:)), forControlEvents:.TouchUpInside )

        self.drawFrameInUIViewObject( taleImage, red:186, green:182, blue:182 )
        self.drawFrameInUIViewObject( taleTextViewContainer, red:186, green:182, blue:182 )
        
        if( !self.user.acceptedRoomInvitation )
        {
            //UIButtons.
            self.arrowLeftButton.addTarget( self, action: #selector(TaleModeViewController.willDoPrevPage(_:)), forControlEvents: .TouchUpInside )
            self.arrowRightButton.addTarget( self, action: #selector(TaleModeViewController.willDoNextPage(_:)), forControlEvents: .TouchUpInside )
            
            self.swipeGestureLeft.delegate = self
            self.swipeGestureRight.delegate = self
            self.swipeGestureLeft.direction = UISwipeGestureRecognizerDirection.Left
            self.swipeGestureRight.direction = UISwipeGestureRecognizerDirection.Right
            self.swipeGestureLeft.addTarget(self, action: #selector(TaleModeViewController.handleSwipeLeft(_:)))
            self.swipeGestureRight.addTarget(self, action: #selector(TaleModeViewController.handleSwipeRight(_:)))
            self.view.addGestureRecognizer(self.swipeGestureLeft)
            self.view.addGestureRecognizer(self.swipeGestureRight)
            
            let page = self.book!.load()
            self.updateView( page )
        }
    }
    
    private func updateView( page:Page )
    {
        var textDuration:Double = 0.9
        
        if( page.isChangeImage() )
        {
            let currentTaleImage:UIImage = UIImage(contentsOfFile: page.getImagePath())!
            
            if( self.isFirstTime )
            {
                self.isFirstTime = false
                
                //Arrows.
                self.arrowLeft.image = self.leftArrowDisableImage
                self.arrowRight.image = self.rightArrowActiveImage
                
                //Image cuento.
                self.taleImage.image = currentTaleImage
                
                //Image fondo.
                self.backgroundImage.image = currentTaleImage
                self.backgroundImage.contentMode = .ScaleToFill
                self.backgroundImage.frame = self.view.bounds
                if( self.backgroundImage.subviews.isEmpty )
                {
                    let blurEffectView:UIVisualEffectView = Utils.blurEffectView(self.backgroundImage, radius: 10)
                    self.backgroundImage.addSubview( blurEffectView )
                }
                
                //Set fadein views.
                //.:Background.
                self.fadeInOutImages[0]?.removeFromSuperview()
                self.fadeInOutImages[0] = UIImageView()
                self.view.insertSubview( self.fadeInOutImages[0]!, belowSubview: self.backgroundImage)
                let blurEffect:UIVisualEffectView = Utils.blurEffectView( self.fadeInOutImages[0]!, radius: 10 )
                self.fadeInOutImages[0]!.addSubview( blurEffect )
                
                //.:Tale
                self.fadeInOutImages[1]?.removeFromSuperview()
                self.fadeInOutImages[1] = UIImageView()
                self.view.insertSubview( self.fadeInOutImages[1]!, belowSubview: self.taleImage)
                
                //Texts.
                textDuration = 0.0
            }
            else
            {
                self.isTransitionWorking = true
                self.fadeInOutImageView( 0, imageView:self.backgroundImage, duration:0.9, newImage: currentTaleImage, blur:true, completion:nil )
                self.fadeInOutImageView( 1, imageView:self.taleImage, duration:0.9, newImage:currentTaleImage, blur:false, completion:{[unowned self](isFinished:Bool) -> Void in
                    self.isTransitionWorking = false
                })
            }
        }
        
        self.fadeInOutText( textDuration, text: page.getText(), fontSize: ( ( self.isFullTale ) ? FontSizeMax : FontSizeMin ) )
    }
    
    private func fadeInOutText(duration:Double, text:String, fontSize:Int )
    {
        UIView.animateWithDuration(duration, animations: { [unowned self]() -> Void in
            
            self.taleText.alpha = 0.0
            
            }) { [unowned self](isFinished:Bool) -> Void in
                
                self.taleText.text = text
                let fontSize:Int = fontSize //( self.isFullTale ) ? FontSizeMax : FontSizeMin
                self.taleText.font = UIFont( name:"ArialRoundedMTBold", size:CGFloat(fontSize) )
                self.taleText.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
                
                //Align
                var topCorrect:CGFloat = ( self.taleText.bounds.size.height - self.taleText.contentSize.height * self.taleText.zoomScale )/2
                topCorrect = ( topCorrect < 0.0 ) ? 0.0 : topCorrect
                self.taleText.contentOffset = CGPoint(x: 0, y: -topCorrect)
       
                UIView.animateWithDuration(duration, animations: { [unowned self]() -> Void in
                    self.taleText.alpha = 1.0
                })
        }
    }
    
    private func fadeInOutImageView(id:Int, imageView:UIImageView, duration:Double, newImage:UIImage, blur:Bool, completion:((Bool)->Void)?)
    {
        let viewBack:UIImageView = self.fadeInOutImages[id]!
        viewBack.image = newImage
        viewBack.frame = imageView.frame
        viewBack.alpha = 0.0
        
        UIView.animateWithDuration(duration, animations: { [unowned viewBack, unowned imageView]() -> Void in
            
            imageView.alpha = 0.0
            viewBack.alpha = 1.0
            
            }) { (isFinished:Bool) -> Void in
                
                imageView.image = viewBack.image
                imageView.alpha = 1.0
                viewBack.alpha = 0.0
                
                completion?(true)
        }
    }
    
    private func drawFrameInUIViewObject(uiviewObject:UIView, red:Int, green:Int, blue:Int )
    {
        self.sublayers[uiviewObject] = [CALayer]()
        let uiColor = UIColor.init(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
    
        let topLayer = CALayer()
        topLayer.frame = CGRectMake(0,0,uiviewObject.bounds.size.width,1)
        topLayer.backgroundColor = uiColor.CGColor
        uiviewObject.layer.addSublayer(topLayer)
        self.sublayers[uiviewObject]?.append(topLayer)
        
        let bottomLayer = CALayer()
        bottomLayer.frame = CGRectMake(0,uiviewObject.bounds.size.height-1,uiviewObject.bounds.size.width,1)
        bottomLayer.backgroundColor = uiColor.CGColor
        uiviewObject.layer.addSublayer(bottomLayer)
        self.sublayers[uiviewObject]?.append(bottomLayer)
    
        let leftLayer = CALayer()
        leftLayer.frame = CGRectMake(0,0,1,uiviewObject.bounds.size.height)
        leftLayer.backgroundColor = uiColor.CGColor
        uiviewObject.layer.addSublayer(leftLayer)
        self.sublayers[uiviewObject]?.append(leftLayer)

        let rightLayer = CALayer()
        rightLayer.frame = CGRectMake(uiviewObject.bounds.width-1,0,1,uiviewObject.bounds.size.height)
        rightLayer.backgroundColor = uiColor.CGColor
        uiviewObject.layer.addSublayer(rightLayer)
        self.sublayers[uiviewObject]?.append(rightLayer)
    
        uiviewObject.layer.masksToBounds = true;
    }
    
    private func showFrameInUIViewObject(show:Bool, uiviewObject:UIView)
    {
        for layer:CALayer in self.sublayers[uiviewObject]!
        {
            layer.hidden = !show
        }
    }
    
    private func resizeFrameInUIViewObject( uiviewObject:UIView)
    {
        //top
        self.sublayers[uiviewObject]![0].frame = CGRectMake( 0, 0, uiviewObject.bounds.size.width, 1 )

        //bottom
        self.sublayers[uiviewObject]![1].frame = CGRectMake( 0, uiviewObject.bounds.size.height-1, uiviewObject.bounds.size.width, 1 )
        
        //left
        self.sublayers[uiviewObject]![2].frame = CGRectMake( 0, 0, 1, uiviewObject.bounds.size.height )
        
        //right
        self.sublayers[uiviewObject]![3].frame = CGRectMake( uiviewObject.bounds.width-1, 0, 1, uiviewObject.bounds.size.height )
    }
    
    private func showTaleInFullMode()
    {
        self.toggleTaleViewButton.setBackgroundImage(self.exitFullScreenImage, forState: UIControlState.Normal )

        self.isFullTale = true
        
        //Force orientation.
        let value = UIInterfaceOrientation.LandscapeLeft.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        super.updateViewConstraints()
        self.view.updateConstraints()
        self.backgroundImage.frame = self.view.bounds
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let newHight:CGFloat = screenSize.height - self.taleText.frame.height

        let newWidth:CGFloat = newHight * 4.0 / 3.0
        let border:CGFloat = ( screenSize.width - newWidth ) * 0.5

        UIView.animateWithDuration(0.5, animations: { [unowned self]() -> Void in
            
            //Little hack to enable repaint the background image.
            self.backgroundImage.alpha = 0.9
            
            //Hide UIButtons.
            self.containerTakePhotoImage.alpha = 0
            self.takePhoto.alpha = 0
            self.showCostumes.alpha = 0
            self.showAccesiries.alpha = 0
            
            //Tale Image.
            self.originalTaleImageSize = self.taleImage.frame
            self.taleImage.frame = CGRectMake( border, 0, newWidth, newHight )
            self.taleImage.contentMode = .Redraw
            self.resizeFrameInUIViewObject( self.taleImage )
            
            //Tale Text Container.
            self.originalTaleTextContainerSize = self.taleTextViewContainer.frame
            self.taleTextViewContainer.frame = CGRectMake(border, newHight, newWidth, self.taleTextViewContainer.frame.height)
            self.resizeFrameInUIViewObject( self.taleTextViewContainer )
            
            //GLSurfaces to render video.
            self.meView.alpha = 0
            self.friend1View.alpha = 0
            self.friend2View.alpha = 0
            self.friend3View.alpha = 0

            }, completion: { [unowned self](isCompleted:Bool) -> Void in
                if( isCompleted )
                {
                    //Right arrow.
                    self.originalArrowRightPosition = self.arrowRight.frame
                    let px:CGFloat = newWidth - self.arrowRight.frame.width - 5
                    self.arrowRight.frame = CGRectMake( px,self.arrowRight.frame.origin.y,self.arrowRight.frame.width, self.arrowRight.frame.height)
                    self.originalArrowRightButtonPosition = self.arrowRightButton.frame
                    self.arrowRightButton.frame = CGRectMake( px,self.arrowRightButton.frame.origin.y,self.arrowRightButton.frame.width, self.arrowRightButton.frame.height)

                    //Text
                    self.originalTaleTextSize = self.taleText.frame
                    self.taleText.frame = CGRectMake(36,0,newWidth-70,self.taleTextViewContainer.frame.height)
                    self.taleText.font = UIFont( name:"ArialRoundedMTBold", size:CGFloat(self.FontSizeMax) )

                    //Align
                    var topCorrect:CGFloat = ( self.taleText.bounds.size.height - self.taleText.contentSize.height * self.taleText.zoomScale )/2
                    topCorrect = ( topCorrect < 0.0 ) ? 0.0 : topCorrect
                    self.taleText.contentOffset = CGPoint(x: 0, y: -topCorrect)
                    
                    self.isTransitionWorking = false
                }
        })
    }
    
    private func showTaleInNormalMode()
    {
        self.toggleTaleViewButton.setBackgroundImage(self.fullScreenImage, forState: UIControlState.Normal )

        self.isFullTale = false
        
        //Force orientation.
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        super.updateViewConstraints()
        self.view.updateConstraints()
        self.backgroundImage.updateConstraints()
        
        UIView.animateWithDuration(0.5, animations: { [unowned self]() -> Void in
            self.backgroundImage.alpha = 1.0
            
            //Show UIButtons.
            self.containerTakePhotoImage.alpha = 1.0
            self.takePhoto.alpha = 1.0
            self.showCostumes.alpha = 1.0
            self.showAccesiries.alpha = 1.0
            
            //Restore original size.
            self.taleImage.frame = self.originalTaleImageSize

            self.taleTextViewContainer.frame = self.originalTaleTextContainerSize
            self.taleText.frame = self.originalTaleTextSize
            self.taleText.font = UIFont( name:"ArialRoundedMTBold", size:CGFloat(self.FontSizeMin) )
            self.arrowRight.frame = self.originalArrowRightPosition
            self.arrowRightButton.frame = self.originalArrowRightButtonPosition
            
            //GLSurfaces to render video.
            self.meView.alpha = 1.0
            self.friend1View.alpha = 1.0
            self.friend2View.alpha = 1.0
            self.friend3View.alpha = 1.0
            
            }, completion: { [unowned self](isCompleted:Bool) -> Void in
                if( isCompleted )
                {
                    self.resizeFrameInUIViewObject( self.taleImage )
                    self.resizeFrameInUIViewObject( self.taleTextViewContainer )
                    
                    //Align
                    var topCorrect:CGFloat = ( self.taleText.bounds.size.height - self.taleText.contentSize.height * self.taleText.zoomScale )/2
                    topCorrect = ( topCorrect < 0.0 ) ? 0.0 : topCorrect
                    self.taleText.contentOffset = CGPoint(x: 0, y: -topCorrect)
                    self.isTransitionWorking = false
                }
        })
    }
    
    private func doPrevPage()
    {
        if( self.isTransitionWorking )
        {
            return
        }
        
        if( !self.book!.isAtFirstPage() )
        {
            self.arrowRight.image = self.rightArrowActiveImage
            
            let pageToShow = self.book!.prevPage()
            self.updateView( pageToShow )
            
            if( self.book!.isAtFirstPage() )
            {
                self.arrowLeft.image = self.leftArrowDisableImage
            }
            
            if( self.user.isNarrator && self.isInternetAvailable )
            {
                self.roomModel!.actionPage("prev")
            }
        }
    }
    
    private func doNextPage()
    {
        if( self.isTransitionWorking )
        {
            return
        }
        
        if( !self.book!.isAtLastPage() )
        {
            self.arrowLeft.image = self.leftArrowActiveImage
            
            let pageToShow = self.book!.nextPage()
            self.updateView( pageToShow )
            if( self.book!.isAtLastPage() )
            {
                self.arrowRight.image = self.rightArrowDisableImage
            }
            
            if( self.user.isNarrator && self.isInternetAvailable )
            {
                self.roomModel!.actionPage("next")
            }
        }
        else
        {
            self.showOptionsEndTale()
        }
    }
    
    private func showOptionsEndTale()
    {
        self.performSegueWithIdentifier( "optionsEndTaleView", sender: nil )
    }
 
    private func showUserUI(show:Bool)
    {
        let alphaValue:CGFloat = show ? 1.0 : 0.0
        
        //.: menu buttons.
        self.toggleTaleViewButton.alpha = alphaValue
        
        //.: renderers views.
        self.meView.alpha = alphaValue
        self.userButtonsView.alpha = alphaValue
        
        self.friend1View.alpha = alphaValue
        self.friend2View.alpha = alphaValue
        self.friend3View.alpha = alphaValue
        
        //.: tale section.
        self.taleImage.alpha = alphaValue
        self.taleTextViewContainer.alpha = alphaValue
    }
    
    private func getMessageErrorByCode( code:Int ) -> String
    {
        let msg:String
        switch code {
            case ServerResponseCode.DataBaseConfigFail:
                msg = Utils.localize( "error.databaseCfgFail" )
                break
            case ServerResponseCode.NoInternetConnection:
                msg = Utils.localize( "error.noInternetConnection" )
                break
            case ServerResponseCode.ServerNotWorking:
                msg = Utils.localize( "error.serverNotWorking" )
                break
            case ServerResponseCode.RoomIsFull:
                msg = Utils.localize( "error.roomFull" )
                break
            default:
                msg = Utils.localize( "error.unkwon" )
        }
        
        return msg
    }
    
    //This property is used in AppDelegate to force the application to Portrait mode.
    internal private(set) var isVisible:Bool = false
    internal private(set) var isFullTale:Bool = false
    internal private(set) var isFirstCall:Bool = true
    
    private weak var book:Book?
    private var originalTaleImageSize:CGRect
    private var originalTaleTextContainerSize:CGRect
    private var originalTaleTextSize:CGRect
    private var originalArrowRightPosition:CGRect
    private var originalArrowRightButtonPosition:CGRect
    private var sublayers:[UIView:[CALayer]]
    private let FontSizeMin:Int = 24
    private var FontSizeMax:Int = 28
    private let FontSizeMaxByLang:[String:Int]=["en":28,"de":26,"es":28]    //TODO: put this in tale file.
    private var isFirstTime:Bool = true
    private var leftArrowActiveImage:UIImage
    private var leftArrowDisableImage:UIImage
    private var rightArrowActiveImage:UIImage
    private var rightArrowDisableImage:UIImage
    private var fullScreenImage:UIImage
    private var exitFullScreenImage:UIImage
    private var isTransitionWorking:Bool
    private var fadeInOutImages:[Int:UIImageView]
    private var roomModel:RoomModel?
    private var loadingView:UIView?
    private var activityIndicator:UIActivityIndicatorView?
    private var isUserGoBack:Bool = false

}
