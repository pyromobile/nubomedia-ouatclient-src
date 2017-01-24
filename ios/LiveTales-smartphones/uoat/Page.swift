//
//  Page.swift
//  uoat
//
//  Created by Pyro User on 4/5/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import Foundation

enum PageType
{
    case FrontCover
    case Page
    case BackCover
}

class Page
{
    init( text:String, imagePath:String, changeImage:Bool )
    {
        self.text = text
        self.imagePath = imagePath
        self.changeImage = changeImage
    }
    
    func getText() -> String
    {
        return self.text
    }
    
    func getImagePath() -> String
    {
        return self.imagePath
    }
    
    func isChangeImage() -> Bool
    {
        return self.changeImage
    }

    
    private let text:String
    private let imagePath:String
    private let changeImage:Bool
}
