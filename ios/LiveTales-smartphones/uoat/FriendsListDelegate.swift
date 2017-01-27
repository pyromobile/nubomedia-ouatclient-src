//
//  FriendsListDelegate.swift
//  uoat
//
//  Created by Pyro User on 11/8/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import Foundation

protocol FriendsListDelegate:class
{
    func updatedFriendsList(friends:[(id:String, nick:String, isPending:Bool)])
}