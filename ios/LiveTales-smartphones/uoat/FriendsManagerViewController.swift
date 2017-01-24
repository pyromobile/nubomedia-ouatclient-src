//
//  FriendsManagerViewController.swift
//  uoat
//
//  Created by Pyro User on 2/6/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import UIKit

class FriendsManagerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddFriendDelegate, NotificationAcceptedDelegate, FriendsListDelegate
{
    weak var user:User!
    var notificationsByType:[NotificationType:[Notification]]!
    
    
    deinit
    {
        self.user = nil
        print("FriendsManagerViewController - deInit....OK")
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.friendsTableView.delegate = self
        self.friendsTableView.dataSource = self
        
        self.loadFriends()
        self.findNotifications()
        
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
        if( segue.identifier == "showAddFriendView" )
        {
            let controller = segue.destinationViewController as! AddFriendViewController;
            controller.user = self.user
            controller.addFriendDelegate = self
        }
        else if( segue.identifier == "showNotificationsManagerView" )
        {
            let controller = segue.destinationViewController as! NotificationsManagerViewController;
            controller.user = self.user
            controller.notifications = self.notificationsByType[NotificationType.FriendShip]
            controller.notificationAcceptedDelegate = self
        }
        else if( segue.identifier == "showFriendsListManagerView" )
        {
            let controller = segue.destinationViewController as! FriendsListManagerViewController;
            controller.user = self.user
            controller.friends = self.friends
            controller.friendsListDelegate = self
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
        return self.friends.count;
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier( self.cellIdentifier, forIndexPath:indexPath ) as! FriendsTableViewCell
        
        let row = indexPath.row
        
        //User information.
        let friend:(id:String,nick:String,isPending:Bool) = self.friends[row]
        cell.imageView?.image = UIImage() //TODO: foto usuario??
        cell.nickNameLabel.text = friend.nick
        if( friend.isPending )
        {
            cell.nickNameLabel.textColor = UIColor.lightGrayColor()
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
    /*                    from AddFriendDelegate                   */
    /*=============================================================*/
    func addPendingFriend( nickName:String )
    {
        let friend:(id:String,nick:String,isPending:Bool) = (id:"",nick:nickName,isPending:true)
        self.friends.append(friend)
        self.friendsTableView.reloadData()
    }
    
    
    /*=============================================================*/
    /*             from NotificationAcceptedDelegate               */
    /*=============================================================*/
    func addNewFriends(notifications:[Notification])
    {
        for notification:Notification in notifications
        {
            let friend:(id:String,nick:String,isPending:Bool) = (id:notification.getTo(),nick:notification.nickNameFrom,isPending:false)
            self.friends.append(friend)
            var pos:Int = 0
            let found:Bool = (self.notificationsByType[NotificationType.FriendShip]?.contains({(item) -> Bool in
                let found = item.getId() == notification.getId()
                if(!found)
                {
                    pos += 1
                }
                return found
            }))!
            if( found )
            {
                self.notificationsByType[NotificationType.FriendShip]?.removeAtIndex( pos )
            }
        }
        self.friendsTableView.reloadData()
        self.findNotifications()
    }

    
    /*=============================================================*/
    /*             from NotificationAcceptedDelegate               */
    /*=============================================================*/
    func updatedFriendsList(friends:[(id:String, nick:String, isPending:Bool)])
    {
        self.friends = friends
        self.friendsTableView.reloadData()
    }
    
    
    /*=============================================================*/
    /*                          UI Section                         */
    /*=============================================================*/    
    @IBOutlet weak var leftArrowImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var bgNotificationImage: UIImageView!
    @IBOutlet weak var notificationCountLabel: UILabel!

    //---------------------------------------------------------------
    //                         UI Actions
    //---------------------------------------------------------------
    @IBAction func back(sender: UIButton)
    {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func addFriend(sender: AnyObject)
    {
        performSegueWithIdentifier("showAddFriendView", sender: nil)
    }

    @IBAction func editFriends(sender: AnyObject)
    {
        performSegueWithIdentifier("showFriendsListManagerView", sender: nil)
    }
    
    @IBAction func notifications(sender: AnyObject)
    {
        performSegueWithIdentifier("showNotificationsManagerView", sender: nil)
    }
    
    
    /*=============================================================*/
    /*                       Private Section                       */
    /*=============================================================*/
    private func loadFriends()
    {
        UserModel.loadUserFriends(self.user.id) { [weak self](friends) in
            if( friends == nil )
            {
                print("Error to get friends...")
            }
            else
            {
                for friend in friends!
                {
                    let friend:(id:String,nick:String,isPending:Bool) = (id:friend.id,nick:friend.nick,isPending:false)
                    self!.friends.append( friend )
                }
                NotificationModel.getNotificationsSentByMe(self!.user.id, onNotificationsReady: { (notifications) in
                    
                    if let notificationsFriendship:[Notification] = notifications[NotificationType.FriendShip]
                    {
                        NotificationModel.getNickNamesFromSentNotifications(notificationsFriendship, onNotificationsReady: { [weak self] (notifications) in
                            for notification:Notification in notifications
                            {
                                if( notification.getFrom() == "pub_\(self!.user.id)" )
                                {
                                    let friend:(id:String,nick:String,isPending:Bool) = (id:notification.getFrom(),nick:notification.nickNameFrom,isPending:true)
                                    self!.friends.append( friend )
                                }
                            }
                            self!.friendsTableView.reloadData()
                        })
                    }
                })
            }
            self!.friendsTableView.reloadData()
        }
     }
    
    private func findNotifications()
    {
        //Busco las notificaciones que recivo y las que he mandado yo (para dibujarlas como pendientes).
        //{$or:[{"to":"pub_573b1d53e4b04c6b97862081"},{"from":"pub_573b1d53e4b04c6b97862081"}]}
        
        let haveNotifications:Bool = self.notificationsByType[NotificationType.FriendShip]?.count > 0
        
        self.notificationButton.enabled = haveNotifications
        self.bgNotificationImage.hidden = !haveNotifications
        self.notificationCountLabel.hidden = !haveNotifications
        
        if( haveNotifications )
        {
            let notificationCount:Int = (self.notificationsByType[NotificationType.FriendShip]?.count)!
            self.notificationCountLabel.text = "\(notificationCount)"
        }
    }
    
    
    private let cellIdentifier:String = "FriendsTableViewCell"
    private var friends:[(id:String,nick:String,isPending:Bool)] = [(id:String,nick:String,isPending:Bool)]()
}
