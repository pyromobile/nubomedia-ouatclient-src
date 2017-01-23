//
//  Book.swift
//  uoat
//
//  Created by Pyro User on 4/5/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import Foundation

class Book
{
    init( id:String, langId:String, isHD:Bool )
    {
        self.id = id
        self.langId = langId
        self.isHD = isHD
        self.story = [String:AnyObject]()
        self.storyLanguage = [String:String]()
        self.imagesPath = [String:String]()
        self.currentPieceStory = 0
        self.currentPage = 0
        self.state = .FrontCover
    }
    
    func getId() -> String
    {
        return self.id
    }
    
    func load() -> Page
    {
        self.loadStory()
        self.loadStoryLanguage()
        self.loadImages()
        
        self.state = .FrontCover

        let pageToShow:Page = self.preparePageToShow( true )
        return pageToShow
    }
    
    func changeLanguage( langId: String ) -> Page
    {
        self.langId = langId
        self.loadStoryLanguage()
        
        let pageToShow:Page = self.preparePageToShow( true )
        return pageToShow
    }
    
    func goBegin() -> Page
    {
        self.currentPieceStory = 0
        self.currentPage = 0
        self.state = .FrontCover
        
        let pageToShow:Page = self.preparePageToShow( true )
        return pageToShow
    }
    
    func goToPage( pageNum:Int ) -> Page
    {
        self.currentPieceStory = 0
        self.currentPage = 0
        
        //var items:Int = self.story["story"]![self.currentPieceStory]["texts"]!!.count
        var itemsOld:Int = 0
        var foundPage:Bool = false
        while( !foundPage )
        {
            let items:Int = self.story["story"]![self.currentPieceStory]["texts"]!!.count
            if( pageNum <= (items + itemsOld) )
            {
                self.currentPage = pageNum - itemsOld
                foundPage = true
            }
            else
            {
                itemsOld += items
                self.currentPieceStory += 1
            }
        }
        
        let page:Page = self.preparePageToShow( true )
        
        self.checkState()
        
        return page
    }
    
    
    func prevPage() -> Page
    {
        self.currentPage -= 1
        let page:Page = self.checkChangeImage()
        
        self.checkState()

        return page
    }
    
    func nextPage() -> Page
    {
        self.currentPage += 1
        let page:Page = self.checkChangeImage()
        
        self.checkState()
        
        return page
    }
    
    func release()
    {
        //Images.
        for pair in self.imagesPath
        {
            self.imagesPath.removeValueForKey( pair.0 )
        }
        
        //Story
        self.story.removeValueForKey( "story" )
        
        //Story language
        for pair in self.storyLanguage
        {
            self.storyLanguage.removeValueForKey( pair.0 )
        }
    }
    
    func isAtFirstPage() -> Bool
    {
        return self.state == .FrontCover
    }
    
    func isAtLastPage() -> Bool
    {
        return self.state == .BackCover
    }
    
    
    /*=============================================================*/
    /*                       Private Section                       */
    /*=============================================================*/
    private func loadStory()
    {
        let file = NSBundle.mainBundle().pathForResource("story", ofType: "json", inDirectory: "Res/tales/\(self.id)")
        do
        {
            let fileContent = try NSString(contentsOfFile: file!, encoding: NSUTF8StringEncoding )
            //print("Contenido story...\n\(fileContent)")
            
            let fc = fileContent as String!
            self.prepareTexts( fc, type:1 )
            
        }
        catch let error as NSError
        {
            print( "Failed to load: \(error.localizedDescription)" )
        }
    }
    
    private func loadStoryLanguage()
    {
        let file = NSBundle.mainBundle().pathForResource("\(self.langId)", ofType: "json", inDirectory: "Res/tales/\(self.id)/languages")
        do
        {
            let fileContent = try NSString(contentsOfFile: file!, encoding: NSUTF8StringEncoding )
            //print("Contenido storyLangs...\n\(fileContent)")
            
            let fc = fileContent as String!
            self.prepareTexts( fc, type:2 )

        }
        catch let error as NSError
        {
            print( "Failed to load: \(error.localizedDescription)" )
        }
    }
    
    private func prepareTexts(text:String, type:Int)
    {
        switch( type )
        {
            case 1:
                self.story = self.getJSON( text )! as! [String : AnyObject]
                break
            
            case 2:
                self.storyLanguage = self.getJSON( text )! as! [String : String]
                break
            
            default:
                break
        }
    }
    
    private func loadImages()
    {
        let resolutionPath = (self.isHD) ? "/" : "/sd/"
        let story = self.story["story"] as! [AnyObject]
        
        for itemStory in story
        {
            let imgId:String = itemStory["image"]!!.description
            
            let imagePath = NSBundle.mainBundle().pathForResource( "esc\(imgId)", ofType: "jpg", inDirectory: "Res/tales/\(self.id)/images\(resolutionPath)" )
            self.imagesPath[imgId] = imagePath!
        }
    }
    
    private func getJSON(stringJSON:String)->AnyObject?
    {
        let json:AnyObject?
        
        do
        {
            let data = stringJSON.dataUsingEncoding( NSUTF8StringEncoding, allowLossyConversion: false )
            json = try NSJSONSerialization.JSONObjectWithData( data!, options: .AllowFragments )
        }
        catch let error as NSError
        {
            print( "Failed to load: \(error.localizedDescription)" )
            json = nil
        }
        
        return json
    }
    
    private func checkChangeImage() -> Page
    {
        let MAX_PIECE_STORY = (self.story["story"]as![AnyObject]).count - 1
        var changeImage:Bool = false
        self.state = .Page
        
        if( self.currentPage >= self.story["story"]![self.currentPieceStory]["texts"]!!.count )
        {
            //self.currentPieceStory = (self.currentPieceStory < MAX_PIECE_STORY) ? self.currentPieceStory + 1 : 0
            if( self.currentPieceStory < MAX_PIECE_STORY )
            {
                self.currentPieceStory += 1
                self.currentPage = 0
                changeImage = true
            }
            /*
            else
            {
                self.currentPieceStory = MAX_PIECE_STORY
                self.currentPage--
                self.state = .BackCover
            }
            */
        }
        else if( self.currentPage < 0)
        {
            //self.currentPieceStory = (self.currentPieceStory <= 0) ? MAX_PIECE_STORY : self.currentPieceStory - 1
            if( self.currentPieceStory > 0 )
            {
                self.currentPieceStory -= 1
                self.currentPage = self.story["story"]![self.currentPieceStory]["texts"]!!.count - 1
                changeImage = true
            }
            /*
            else
            {
                self.currentPieceStory = 0
                self.currentPage = 0
                self.state = .FrontCover
            }
            */
        }
        
        let pageToShow:Page = self.preparePageToShow( changeImage )
        return pageToShow
    }
    
    private func preparePageToShow(changeImage:Bool) -> Page
    {
        //let textId = self.story["story"]![self.currentPieceStory]["texts"]!![self.currentPage] as! String
        let tmp = self.story["story"]![self.currentPieceStory]["texts"] as! [String]
        let textId = tmp[self.currentPage] 
        let text = self.storyLanguage[textId]!
        let imgPos = self.story["story"]![self.currentPieceStory]["image"] as! String
        let imagePath = self.imagesPath[ imgPos ]
        
        let pageToShow:Page = Page( text:text, imagePath:imagePath!, changeImage: changeImage )
        
        return pageToShow
    }
    
    private func checkState()
    {
        let MAX_PIECE_STORY = (self.story["story"]as![AnyObject]).count - 1
        
        if( self.currentPage == 0 && self.currentPieceStory == 0 )
        {
            self.state = .FrontCover
        }
        else if( self.currentPage >= self.story["story"]![self.currentPieceStory]["texts"]!!.count - 1 && self.currentPieceStory == MAX_PIECE_STORY)
        {
            self.state = .BackCover
        }
    }
    
    
    private var id:String
    private var langId:String
    private var isHD:Bool
    private var story:[String:AnyObject]
    private var storyLanguage:[String:String]
    private var imagesPath:[String:String]
    private var currentPieceStory:Int
    private var currentPage:Int
    private var state:PageType
}