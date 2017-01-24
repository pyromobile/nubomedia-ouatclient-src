//
//  Complement.swift
//  uoat
//
//  Created by Pyro User on 18/8/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import Foundation

class Complement
{
    init(id:String, imagePath:String, pack:String)
    {
        self.id = id
        self.imagePath = imagePath
        self.pack = pack
    }
    
    internal private(set) var id:String = ""
    internal private(set) var imagePath:String = ""
    internal private(set) var pack:String = ""
}