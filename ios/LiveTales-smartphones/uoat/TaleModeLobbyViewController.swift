//
//  TaleModeLobbyViewController.swift
//  uoat
//
//  Created by Pyro User on 23/6/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import UIKit

class TaleModeLobbyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, LoginSignupDelegate
{
    weak var user:User!
    var bgImagePath:String!
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TaleModeLobbyViewController.networkStatusChanged(_:)), name: NetworkWatcher.reachabilityStatusChangedNotification, object: nil)
    }
    
    deinit
    {
        user = nil
        headerLabel = nil
        friendsSelected.removeAll()
        friendsToShow.removeAll()
        friendsGroupView = nil
        libraryGroupView = nil
        beginButton = nil
        bgMainImage?.removeFromSuperview()
        NSNotificationCenter.defaultCenter().removeObserver( self, name: NetworkWatcher.reachabilityStatusChangedNotification, object: nil )
        
        print("TaleModeLobbyViewController - deInit....OK")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
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
        
        self.prepareBackgroundImage()
        
        self.originalPosLibraryView = self.libraryGroupView.frame
        self.originalPosFriendsView = self.friendsGroupView.frame
        self.originalPosBeginButton = self.beginButton.frame
        
        if( self.user.isLogged() )
        {
            self.prepareFriendList()
        }
        else
        {
            self.prepareSuggestLoginView()
        }
        
        //Prepare table views.
        self.libraryTableView.delegate = self
        self.libraryTableView.dataSource = self
        self.friendsTableView.delegate = self
        self.friendsTableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        if( self.user.lobby == .Free )
        {
            self.libraryGroupView.alpha = 0
            
            self.friendsGroupView.frame.origin.x = self.view.frame.width
            self.beginButton.enabled = true
        }
        else if( self.user.lobby == .Tale )
        {
            self.libraryGroupView.frame.origin.x = -self.libraryGroupView.frame.width
            self.friendsGroupView.frame.origin.x = self.view.frame.width
            self.beginButton.enabled = false
        }
        self.beginButton.frame.origin.y = self.view.frame.height
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if( self.user.lobby == .Free )
        {
            UIView.animateWithDuration(0.25) { [unowned self] in
                var position:CGRect
                position = self.friendsGroupView.frame
         
                position.origin.x = self.view.frame.width * 0.5 - position.width * 0.5
         
                self.friendsGroupView.frame = position
                self.beginButton.frame = self.originalPosBeginButton
            }
        }
        else if( self.user.lobby == .Tale )
        {
            UIView.animateWithDuration(0.25) { [unowned self] in
                self.libraryGroupView.frame = self.originalPosLibraryView
                self.friendsGroupView.frame = self.originalPosFriendsView
                self.beginButton.frame = self.originalPosBeginButton
            }
            
            self.beginButton.enabled = false
        }
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if( segue.identifier == "showRevealView" )
        {
            //Indicamos el cuento que queremos leer.
            let books:[(id:String,title:String)] = Library.getInstance().currentBooks()
            Library.getInstance().setBookIdSelected( books[self.bookSelectedIndex].id )
            
            //Cambiamos de vista.
            let swrevealController = segue.destinationViewController as! SWRevealViewController
            swrevealController.loadView()
            let navigationController = swrevealController.frontViewController as! UINavigationController
            let controller = navigationController.topViewController as! TaleModeViewController
            controller.user = self.user
            controller.isInternetAvailable = NetworkWatcher.internetAvailabe
        }
        else if( segue.identifier == "showFreeModeView" )
        {
            //Cambiamos de vista.
            let controller = segue.destinationViewController as! FreeModeViewController
            controller.user = self.user
            controller.bgImagePath = self.bgImagePath
        }
    }
    
    func tapBook(sender:UITapGestureRecognizer)
    {
        let imageView = sender.view as! UIImageView
        self.bookSelectedIndex = imageView.tag
        
        //feedback usuario.
        let originalSize:CGRect = imageView.frame
        UIView.animateWithDuration(0.2, animations: {
            let ff:CGRect = CGRect(x: originalSize.origin.x, y: originalSize.origin.y, width: originalSize.width * 1.3, height: originalSize.height * 1.3 )
            imageView.frame = ff
        }) { (isFinished:Bool) in
            UIView.animateWithDuration(0.2, animations: {
                imageView.frame = originalSize
                }, completion: { (isFinished:Bool) in
                    
            })
        }
        
        self.beginButton.enabled = true
    }

    func tapFriends(sender:UITapGestureRecognizer)
    {
        let cell = sender.view as! LobbyFriendsTableViewCell
        
        if( !self.friendsSelected.contains(cell.nickNameLabel.text!) )
        {
            if( self.friendsSelected.count < 4 )
            {
                self.friendsSelected.append(cell.nickNameLabel.text!)
                cell.acceptedImage.hidden = false
                cell.nickNameLabel.textColor = UIColor(red:CGFloat(227/255.0), green:CGFloat(167/255.0), blue:CGFloat(78/255.0), alpha:CGFloat(255/255.0))
            }
        }
        else
        {
            let index = self.friendsSelected.indexOf( cell.nickNameLabel.text! )
            self.friendsSelected.removeAtIndex( index! )
            cell.acceptedImage.hidden = true
            cell.nickNameLabel.textColor = UIColor(red:CGFloat(224/255.0), green:CGFloat(200/255.0), blue:CGFloat(147/255.0), alpha:CGFloat(255/255.0))
        }
    }
    
    func suggestLogin( sender:UIButton )
    {
        if( NetworkWatcher.internetAvailabe )
        {
            //self.performSegueWithIdentifier("showLoginSignupView", sender: nil);
     
            let loginSignupViewController = self.storyboard?.instantiateViewControllerWithIdentifier( "loginSignupViewController" ) as? LoginSignupViewController
            loginSignupViewController!.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
            loginSignupViewController?.user = self.user
            loginSignupViewController?.delegate = self
            
            self.presentViewController( loginSignupViewController!, animated: true, completion: nil )
        }
        else
        {
            
           Utils.alertMessage( self, title:Utils.localize( "attention.title" ), message:Utils.localize("attention.networkWarning"), onAlertClose:nil )
        }
    }
    
    func networkStatusChanged(notification:NSNotification)
    {
        print("TaleModeLobbyViewController::networkStatusChanged was called...")
        if( NetworkWatcher.internetAvailabe )
        {
            Utils.alertMessage( self, title:Utils.localize("notice.title"), message:Utils.localize("notice.networkWorksAgain"), onAlertClose:nil )
        }
        else
        {
            let msg:String = ( self.user.lobby == .Tale ) ? Utils.localize( "attention.networkLost" ) : Utils.localize( "attention.noNetworkWithFreeMode" )
            
            Utils.alertMessage( self, title:Utils.localize("attention.title"), message:msg, onAlertClose: { [unowned self] (action) in
                if( self.user.lobby == .Free )
                {
                    //Go back to main view.
                    UIView.animateWithDuration(0.25, animations: { [unowned self] in
                        self.friendsGroupView.frame.origin.x = self.view.frame.width
                        self.beginButton.frame.origin.y = self.view.frame.height
                        }, completion: { [unowned self](finished:Bool) in
                            self.dismissViewControllerAnimated(false, completion: {})
                    })
                }
            })
        }
    }


    /*=============================================================*/
    /*                  from UITableViewDataSource                 */
    /*=============================================================*/
    func numberOfSectionsInTableView(tableView:UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        var count:Int = 0
        if( tableView == self.libraryTableView )
        {
            let rowsToShow = ( Library.getInstance().currentBooks().count < 12 ) ? 3 : 1
            
            count = Library.getInstance().currentBooks().count / 4 + rowsToShow
        }
        else if( tableView == self.friendsTableView )
        {
            count = self.friendsToShow.count
        }
        
        return count
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell
        if( tableView == self.libraryTableView )
        {
            cell = self.prepareLobbyLibraryCellForRow( indexPath )
        }
        else
        {
            cell = self.prepareLobbyFriendsCellForRow( indexPath )
        }

        return cell
    }
    
    
    /*=============================================================*/
    /*                   from UITableViewDelegate                  */
    /*=============================================================*/
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        cell.backgroundColor = .clearColor()
    }
    
    
    /*=============================================================*/
    /*                   from LoginSignupDelegate                  */
    /*=============================================================*/
    func onLoginSignupReady()
    {
        if( self.user.isLogged() )
        {
            suggestLoginSignupView?.removeFromSuperview()
            suggestLoginSignupView = nil
            
            self.prepareFriendList()
        }
    }
    
    
    /*=============================================================*/
    /*                          UI Section                         */
    /*=============================================================*/
    @IBOutlet weak var leftArrowImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!

    @IBOutlet weak var libraryGroupView: UIView!
    @IBOutlet weak var libraryTableView: UITableView!

    @IBOutlet weak var friendsGroupView: UIView!
    @IBOutlet weak var friendsTableView: UITableView!
    
    @IBOutlet weak var beginButton: UIButton!
    
    //---------------------------------------------------------------
    //                         UI Actions
    //---------------------------------------------------------------
    @IBAction func backMainMenu(sender: UIButton)
    {
        if( self.user.lobby == .Free )
        {
            UIView.animateWithDuration(0.25, animations: { [unowned self] in
                self.friendsGroupView.frame.origin.x = self.view.frame.width
                self.beginButton.frame.origin.y = self.view.frame.height
                }, completion: { [unowned self](finished:Bool) in
                    self.dismissViewControllerAnimated(false, completion: {})
            })
        }
        else
        {
            UIView.animateWithDuration(0.25, animations: { [unowned self] in
                self.libraryGroupView.frame.origin.x = -self.libraryGroupView.frame.width
                self.friendsGroupView.frame.origin.x = self.view.frame.width
                self.beginButton.frame.origin.y = self.view.frame.height
                }, completion:  {[unowned self](finished:Bool) in
                    self.dismissViewControllerAnimated(false, completion: {})
            })
        }
    }

    @IBAction func begin(sender: UIButton)
    {
        let roomId:String = self.generateRoomId();
        self.user.roomId = roomId
        
        if( self.user.lobby == .Free )
        {
            if( self.user.isLogged() && (self.friendsSelected.count > 0) )
            {
                self.sendNotificationsToSelectedFriends( "playingroom", roomId:roomId, callback: { (error) in
                    if(error)
                    {
                        print("Se ha producido un error al enviar notificaciones")
                        Utils.alertMessage( self, title:Utils.localize("error.title"), message:Utils.localize("error.sendNotification"), onAlertClose: nil)
                    }
                    else
                    {
                        UIView.animateWithDuration(0.25, animations: { [unowned self] in
                            self.friendsGroupView.frame.origin.x = self.view.frame.width
                            self.beginButton.frame.origin.y = self.view.frame.height
                            }, completion: { [unowned self](finished:Bool) in
                                UIView.animateWithDuration( 0.25, animations:{ [unowned self] in
                                    self.view.alpha = 0.0
                                    }, completion:{ [unowned self](finished:Bool) in
                                        self.performSegueWithIdentifier("showFreeModeView", sender: nil)
                                })
                        })
                    }
                })
            }
            else
            {
                UIView.animateWithDuration(0.25, animations: { [unowned self] in
                    self.friendsGroupView.frame.origin.x = self.view.frame.width
                    self.beginButton.frame.origin.y = self.view.frame.height
                    }, completion: { [unowned self](finished:Bool) in
                        UIView.animateWithDuration( 0.25, animations:{ [unowned self] in
                            self.view.alpha = 0.0
                            }, completion:{ [unowned self](finished:Bool) in
                                self.performSegueWithIdentifier("showFreeModeView", sender: nil)
                        })
                })
            }
        }
        else
        {
            self.user.isNarrator = true
            if( self.user.isLogged() && ( self.friendsSelected.count > 0 ) )
            {
                self.sendNotificationsToSelectedFriends( "readingroom", roomId:roomId, callback: { (error) in
                    if(error)
                    {
                        Utils.alertMessage( self, title:Utils.localize("error.title"), message:Utils.localize("error.sendNotification"), onAlertClose: nil)
                    }
                    else
                    {
                        UIView.animateWithDuration(0.25, animations: { [unowned self] in
                            self.libraryGroupView.frame.origin.x = -self.libraryGroupView.frame.width
                            self.friendsGroupView.frame.origin.x = self.view.frame.width
                            self.beginButton.frame.origin.y = self.view.frame.height
                            }, completion:  {[unowned self](finished:Bool) in
                                self.performSegueWithIdentifier("showRevealView", sender: nil)
                        })
                    }
                })
            }
            else
            {
                UIView.animateWithDuration(0.25, animations: { [unowned self] in
                    self.libraryGroupView.frame.origin.x = -self.libraryGroupView.frame.width
                    self.friendsGroupView.frame.origin.x = self.view.frame.width
                    self.beginButton.frame.origin.y = self.view.frame.height
                    }, completion:  {[unowned self](finished:Bool) in
                        UIView.animateWithDuration( 0.25, animations:{ [unowned self] in
                            self.view.alpha = 0.0
                            }, completion:{ [unowned self](finished:Bool) in
                                self.performSegueWithIdentifier("showRevealView", sender: nil)
                        })
                })
            }
        }
    }

    
    /*=============================================================*/
    /*                       Private Section                       */
    /*=============================================================*/
    private func prepareLobbyLibraryCellForRow( indexPath:NSIndexPath ) -> LobbyLibraryTableViewCell
    {
        let row = indexPath.row
        let cell = self.libraryTableView.dequeueReusableCellWithIdentifier( self.lobbyLibraryCellIdentifier, forIndexPath:indexPath ) as! LobbyLibraryTableViewCell
        
        let books:[(id:String,title:String)] = Library.getInstance().currentBooks()
        
        let initPos:Int = row * 4
        let items:Int = 4
        var i:Int = 0
        for index:Int in initPos...(initPos+items-1)
        {
            if( index < books.count )
            {
                let book:(id:String,title:String) = books[index]
                let coverPath = Library.getInstance().getCoverImage(book.id)
                print("COVER:\(coverPath) - TITLE:\(book.title)")
                
                let imageView:UIImageView
                if( i == 0 )
                {
                    imageView = cell.bookHole1
                }
                else if( i == 1)
                {
                    imageView = cell.bookHole2
                }
                else if( i == 2 )
                {
                    imageView = cell.bookHole3
                }
                else
                {
                    imageView = cell.bookHole4
                }
                
                imageView.image = UIImage(contentsOfFile: coverPath)!
                imageView.userInteractionEnabled = true
                imageView.tag = index
                
                let tap = UITapGestureRecognizer( target: self, action: #selector(TaleModeLobbyViewController.tapBook(_:)) )
                imageView.addGestureRecognizer( tap )

                i += 1
            }
        }
        
        return cell
    }
    
    private func prepareLobbyFriendsCellForRow( indexPath:NSIndexPath ) -> LobbyFriendsTableViewCell
    {
        let row = indexPath.row
        let cell = self.friendsTableView.dequeueReusableCellWithIdentifier( self.lobbyFriendsCellIdentifier, forIndexPath:indexPath ) as! LobbyFriendsTableViewCell
        
        cell.nickNameLabel.text = self.friendsToShow[row].nick
        cell.userInteractionEnabled = true
        cell.tag = row
        let tap = UITapGestureRecognizer( target:self, action:#selector(TaleModeLobbyViewController.tapFriends(_:)) )
        cell.addGestureRecognizer( tap )

        return cell
    }
    
    private func prepareFriendList()
    {
        UserModel.loadUserFriends(self.user.id) { [weak self](friends) in
            if( friends == nil )
            {
                print("Error get users...")
                if( NetworkWatcher.internetAvailabe )
                {
                    Utils.alertMessage( self!, title:Utils.localize("error.title"), message:Utils.localize("error.noGetFriendsFromDB "), onAlertClose:nil )
                }
                else
                {
                    Utils.alertMessage( self!, title:Utils.localize("attention.title"), message:Utils.localize("attention.noGetFriendsFromDB "), onAlertClose:nil )
                }
            }
            else
            {
                for friend in friends!
                {
                    self!.friendsToShow.append( friend )
                    print("id:\(friend.id) - nick:\(friend.nick)")
                }
                self?.friendsTableView.reloadData()
            }
        }
    }
    
    private func prepareBackgroundImage()
    {
        if( self.bgMainImage == nil )
        {
            self.bgMainImage = UIImageView( frame:self.view.bounds )
            self.bgMainImage!.image = UIImage( contentsOfFile:self.bgImagePath )!
            let blurEffectView:UIVisualEffectView = Utils.blurEffectView( self.bgMainImage!, radius:6 )   //3
            self.bgMainImage!.addSubview( blurEffectView )
            self.view.insertSubview( self.bgMainImage!, atIndex:0 )
        }
    }
    
    private func prepareSuggestLoginView()
    {
        self.suggestLoginSignupView = UIView( frame:self.friendsGroupView.bounds )
        
        //Label.
        let suggestLabel:UILabel = UILabel()
        suggestLabel.text = Utils.localize( "taleModeLobby.inviteFriends" )
        suggestLabel.numberOfLines=2
        suggestLabel.textAlignment = .Center
        suggestLabel.frame = CGRect(x: 0, y: Int(self.friendsGroupView.bounds.height/2)-150, width: Int(self.friendsGroupView.bounds.width), height: 100)
        suggestLabel.backgroundColor = UIColor.whiteColor()
        suggestLabel.font = UIFont(name: "ArialRoundedMTBold", size: 20)
        suggestLabel.textColor = UIColor(red: CGFloat(227/255.0), green: CGFloat(167/255.0), blue: CGFloat(78/255.0), alpha: CGFloat(255/255.0))
        
        //Button.
        let suggestButton:UIButton = UIButton()
        let title:String = Utils.localize( "taleModeLobby.loginSignup" )
        suggestButton.setTitle( title, forState: UIControlState.Normal )
        suggestButton.setBackgroundImage( UIImage( named:"btn_gui_main_normal" ), forState: UIControlState.Normal)
        suggestButton.frame = CGRect(x: 15, y: Int(self.friendsGroupView.bounds.height/2)+50, width: Int(self.friendsGroupView.bounds.width)-30, height: 55)
        suggestButton.contentEdgeInsets.bottom = 13
        suggestButton.titleLabel?.font = UIFont(name: "ArialRoundedMTBold", size: 20)
        suggestButton.addTarget(self, action: #selector(TaleModeLobbyViewController.suggestLogin(_:)), forControlEvents: UIControlEvents.TouchUpInside )
        
        suggestLoginSignupView!.addSubview( suggestLabel )
        suggestLoginSignupView!.addSubview( suggestButton )
        
        self.friendsGroupView.addSubview( suggestLoginSignupView! )
    }
    
    private func generateRoomId()->String
    {
        var nick = "Guest";
        if( self.user.isLogged() )
        {
            nick = self.user.nick
        }
        
        var str:String = "";
        if( self.friendsSelected.count > 0 )
        {
            for friend in self.friendsSelected
            {
                str += ":\(friend)"
            }
        }
        else
        {
            for _ in 0...3
            {
                str += ":\(Int(arc4random_uniform(10000))+10000)"
            }
        }
        return Utils.md5( string:"room:\(nick)\(str)" )
    }
    
    private func sendNotificationsToSelectedFriends(type:String, roomId:String, callback:(error:Bool)->Void)
    {
        var notifications:[Notification] = [Notification]()
        for selectedFriend in self.friendsSelected
        {
            var index:Int = 0
            let found:Bool = self.friendsToShow.contains({ (friend:(id: String, nick: String)) -> Bool in
                let found:Bool = friend.nick == selectedFriend
                if( !found )
                {
                    index += 1
                }
                return found
            })
            
            if( found )
            {
                let friend:(id:String, nick:String) = self.friendsToShow[index]
                let type:NotificationType
                if( self.user.lobby == .Free )
                {
                    type = NotificationType.PlayingRoom
                }
                else
                {
                    type = NotificationType.ReadingRoom
                }
                
                let notification:Notification = Notification( id:"", type:type, from:self.user.id, to:friend.id, roomId:roomId )
                notifications.append( notification )
            }
        }
        
        NotificationModel.sendNotifications( notifications) { (error) in
            callback(error:error)
        }
    }
    
    private var originalPosLibraryView:CGRect = CGRect.zero
    private var originalPosFriendsView:CGRect = CGRect.zero
    private var originalPosBeginButton:CGRect = CGRect.zero
    
    private var bgMainImage:UIImageView? = nil
    private var suggestLoginSignupView:UIView? = nil
    
    private let lobbyLibraryCellIdentifier:String = "LobbyLibraryTableViewCell"
    private let lobbyFriendsCellIdentifier:String = "LobbyFriendsTableViewCell"
    
    private var bookSelectedIndex:Int = -1
    private var friendsSelected:[String] = [String]()
    private var friendsToShow:[(id:String,nick:String)] = [(id:String,nick:String)]()
    private var roomId:String = ""
}
