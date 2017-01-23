//
//  NotificationsManagerViewController.swift
//  uoat
//
//  Created by Pyro User on 20/6/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import UIKit

class NotificationsManagerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    weak var user:User!
    weak var notificationAcceptedDelegate:NotificationAcceptedDelegate?
    
    //var notifications:[KuasarsEntity]!
    var notifications:[Notification]!
    var roomId:String!
    var type:String!
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NotificationsManagerViewController.networkStatusChanged(_:)), name: NetworkWatcher.reachabilityStatusChangedNotification, object: nil)
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver( self, name: NetworkWatcher.reachabilityStatusChangedNotification, object: nil )
        print("NotificationsManagerViewController - deInit....OK")
    }
    
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
        
        self.notificationsTableView.delegate = self
        self.notificationsTableView.dataSource = self
        
        self.getNickNamesFromNotifications()
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
    
    
    func willAcceptInvite( sender:UIButton )
    {
        if( NetworkWatcher.internetAvailabe )
        {
            print("Accepted - \(sender.tag)")
            
            let row:Int = sender.tag
            
            let inviteNotificationAccepted:Notification = self.notifications[row]
            
            self.notificationIdsToBeConsumed.append( inviteNotificationAccepted.getId() )
            self.notifications.removeAtIndex( row )
            self.notificationsTableView.reloadData()
            self.notificationsAccepted.append( inviteNotificationAccepted )
            
            FriendsModel.createFriendship(inviteNotificationAccepted.getTo(), from: inviteNotificationAccepted.getFrom()) { [weak self](error) in
                if(!error)
                {
                    NotificationModel.removeNotificationsById( [inviteNotificationAccepted.getId()], onNotificationsReady:{[weak self] in
                        if( self!.notifications.count == 0 )
                        {
                            self!.notificationAcceptedDelegate?.addNewFriends( self!.notificationsAccepted )
                            self!.dismissViewControllerAnimated( true, completion:{} )
                        }
                    })
                }
                else
                {
                    //Notificar error.
                }
            }
        }
        else
        {
            Utils.alertMessage( self, title:"Attention", message:"You must have internet connection!", onAlertClose:nil )
        }
    }
    
    func willCancelInvite( sender:UIButton )
    {
        if( NetworkWatcher.internetAvailabe )
        {
            print("Removed - \(sender.tag)")
            
            let row:Int = sender.tag
            
            self.notificationIdsToBeConsumed.append( self.notifications[row].getId() )
            self.notifications.removeAtIndex( row )
            self.notificationsTableView.reloadData()
            
            if( notifications.count == 0 )
            {
                NotificationModel.removeNotificationsById( self.notificationIdsToBeConsumed, onNotificationsReady:{[weak self] in
                    self!.notificationAcceptedDelegate?.addNewFriends( self!.notificationsAccepted )
                    self!.dismissViewControllerAnimated( true, completion:{} )
                })
            }
        }
        else
        {
            Utils.alertMessage( self, title:"Attention", message:"You must have internet connection!", onAlertClose:nil )
        }
    }
    
    func networkStatusChanged(notification:NSNotification)
    {
        print("NotificationsManagerViewController::networkStatusChanged was called...")
        if( NetworkWatcher.internetAvailabe )
        {
            Utils.alertMessage( self, title:"Notice", message:"Internet connection works again!", onAlertClose:nil )
        }
        else
        {
            Utils.alertMessage( self, title:"Attention", message:"Internet connection lost!", onAlertClose:nil )
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
        return self.notifications.count;
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier( self.cellIdentifier, forIndexPath:indexPath ) as! FriendsNotificationsTableViewCell
        
        let row = indexPath.row
        
        //User information.
        cell.imageView?.image = UIImage() //TODO: foto usuario??
        cell.nickNameLabel.text = self.notifications[row].nickNameFrom
        cell.descriptionLabel.text = "desea ser tu amig@"   //TODO: traducir.
        
        //Actions.
        cell.acceptButton.addTarget( self, action:#selector(InviteNotificationsManagerViewController.willAcceptInvite(_:)), forControlEvents:.TouchUpInside )
        cell.acceptButton.tag = row
        cell.cancelButton.addTarget( self, action:#selector(InviteNotificationsManagerViewController.willCancelInvite(_:)), forControlEvents:.TouchUpInside )
        cell.cancelButton.tag = row
        
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
    /*                          UI Section                         */
    /*=============================================================*/
    @IBOutlet weak var leftArrowImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var notificationsTableView: UITableView!

    //---------------------------------------------------------------
    //                         UI Actions
    //---------------------------------------------------------------
    @IBAction func back(sender: UIButton)
    {
        self.notificationAcceptedDelegate?.addNewFriends( self.notificationsAccepted )
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
        
    /*=============================================================*/
    /*                        Private Section                      */
    /*=============================================================*/
    private func getNickNamesFromNotifications()
    {
        NotificationModel.getNickNamesFromNotifications(self.notifications) { [weak self](notifications) in
            self!.notifications = notifications
            self!.notificationsTableView.reloadData()
        }
    }
    
    
    private let cellIdentifier:String = "FriendsNotificationsTableViewCell"
    private var notificationIdsToBeConsumed:[String] = [String]()
    private var notificationsAccepted:[Notification] = [Notification]()
}
