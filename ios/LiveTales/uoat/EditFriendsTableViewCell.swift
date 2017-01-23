//
//  EditFriendsTableViewCell.swift
//  uoat
//
//  Created by Pyro User on 10/8/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import Foundation

class EditFriendsTableViewCell: UITableViewCell
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    
    @IBOutlet weak var userImage: UIView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
    //Property.
    var checked:Bool
    {
        set(checked){
            self._checked = checked
        }
        get
        {
            return _checked
        }
    }
    
    private var _checked:Bool = false
}