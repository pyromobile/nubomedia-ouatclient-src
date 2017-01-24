//
//  FriendsListManagerViewController.swift
//  uoat
//
//  Created by Pyro User on 21/6/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import UIKit

class FriendsListManagerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    weak var user:User!
    var friends:[(id:String, nick:String, isPending:Bool)]!
    weak var friendsListDelegate:FriendsListDelegate?
    
    deinit
    {
        self.user = nil
        self.friends.removeAll()
        print("FriendsListManagerViewController - deInit....OK")
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
        
        self.friendsTableView.delegate = self
        self.friendsTableView.dataSource = self
        
        self.removeButton.enabled = false
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
    
    
    func willDelete(sender:UIButton)
    {
        let row:Int = sender.tag
        let friend:(id:String,nick:String,isPending:Bool) = self.friends[row]
        
        if( !self.friendsSelected.contains( friend.id ) )
        {
            let checkedImage:UIImage = UIImage( named: "checkbox_checked" )!
            sender.setBackgroundImage(checkedImage, forState: .Normal )
            
            self.friendsSelected.append( friend.id )
        }
        else
        {
            let checkedImage:UIImage = UIImage( named: "checkbox_unchecked" )!
            sender.setBackgroundImage(checkedImage, forState: .Normal )
            
            let index = self.friendsSelected.indexOf( friend.id )
            self.friendsSelected.removeAtIndex( index! )
        }
        
        self.removeButton.enabled = !self.friendsSelected.isEmpty
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
        let cell = tableView.dequeueReusableCellWithIdentifier( self.cellIdentifier, forIndexPath:indexPath ) as! EditFriendsTableViewCell
        
        let row = indexPath.row
        
        //User information.
        let friend:(id:String,nick:String, isPending:Bool) = self.friends[row]
        
        cell.imageView?.image = UIImage() //TODO: foto usuario??
        cell.nickNameLabel.text = friend.nick
        
        //Actions.
        cell.checkButton.hidden = friend.isPending
        if( friend.isPending )
        {
            cell.nickNameLabel.textColor = UIColor.lightGrayColor()
        }
        cell.checkButton.addTarget( self, action:#selector(FriendsListManagerViewController.willDelete(_:)), forControlEvents:.TouchUpInside )
        cell.checkButton.tag = row

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
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var removeButton: UIButton!
    
    //---------------------------------------------------------------
    //                         UI Actions
    //---------------------------------------------------------------
    @IBAction func back(sender: UIButton)
    {
        self.friendsListDelegate?.updatedFriendsList( self.friends )
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func removeFriends(sender: UIButton)
    {
        FriendsModel.deleteFriendship( self.user.id, friendIds:self.friendsSelected, onDeleteFriendshipReady:{ [weak self](error)in
            if( !error )
            {
                for friendIdRemoved:String in self!.friendsSelected
                {
                    var pos:Int = 0
                    let foundItem:Bool = self!.friends.contains({ (item:(id: String, nick: String, isPending: Bool)) -> Bool in
                        let found:Bool = item.id == friendIdRemoved
                        
                        if(!found)
                        {
                            pos += 1
                        }
                        
                        return found
                    })
                    if( foundItem )
                    {
                        self!.friends.removeAtIndex( pos )
                    }
                }
                
                self!.friendsSelected.removeAll()
                self!.friendsTableView.reloadData()
            }
        })
    }
    
    
    /*=============================================================*/
    /*                        Private Section                      */
    /*=============================================================*/
    private let cellIdentifier:String = "EditFriendsTableViewCell"
    private var friendsSelected:[String] = [String]()
}
