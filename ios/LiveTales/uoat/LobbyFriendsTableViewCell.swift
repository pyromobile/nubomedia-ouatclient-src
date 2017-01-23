//
//  LobbyFriendsTableViewCell.swift
//  uoat
//
//  Created by Pyro User on 12/8/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import Foundation

class LobbyFriendsTableViewCell: UITableViewCell
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.acceptedImage.hidden = true
    }
    
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var acceptedImage: UIView!
}