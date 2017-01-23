//
//  RoomReadyDelegate.swift
//  uoat
//
//  Created by Pyro User on 2/8/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import Foundation

protocol RoomReadyDelegate:class
{
    func onReady()
    func onError(code:Int)
}