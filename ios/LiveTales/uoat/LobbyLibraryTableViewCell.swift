//
//  LobbyLibraryTableViewCell.swift
//  uoat
//
//  Created by Pyro User on 12/8/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import Foundation

class LobbyLibraryTableViewCell: UITableViewCell
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    @IBOutlet weak var shelfImage: UIImageView!
    @IBOutlet weak var bookHole1: UIImageView!
    @IBOutlet weak var bookHole2: UIImageView!
    @IBOutlet weak var bookHole3: UIImageView!
    @IBOutlet weak var bookHole4: UIImageView!
}