//
//  FriendsNotificationsTableViewCell.swift
//  uoat
//
//  Created by Pyro User on 9/8/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import Foundation

class FriendsNotificationsTableViewCell: UITableViewCell
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    
    @IBOutlet weak var userImage: UIView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
}
