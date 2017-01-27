//
//  Library.swift
//  uoat
//
//  Created by Pyro User on 24/5/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import Foundation

class Library
{
    static func getInstance()->Library
    {
        return Library.instance!
    }

    static func create(langId:String, isHD:Bool)
    {
        Library.instance = Library( langId: langId, isHD:isHD )
        Library.instance?.load()
    }
    
    func currentBooks()->[(id:String,title:String)]
    {
        var lst:[(id:String,title:String)] = [(id:String,title:String)]()
        for taleDescription in self.talesDescription
        {
            let id:String = taleDescription.0
            let title:String = taleDescription.1!["langs"]!![self.langId]!!["title"] as! String
            
            
            lst.append((id:id,title:title))
        }
        
        return lst
    }
    
    func changeLanguage(langId:String)
    {
        self.langId = langId
    }
    
    func setBookIdSelected(bookId:String)
    {
        self.bookId = bookId
    }
    
    func getBook() -> Book
    {
        if( bookId != "" && self.book.getId() != bookId )
        {
            self.book.release()
            self.book = Book( id: bookId, langId: self.langId, isHD: self.isHD )
        }
        return self.book
    }
    
    func getFirstImageToPresentation( bookId:String ) -> String
    {
        let resolutionPath = (self.isHD) ? "/" : "/sd/"
        let imagePath = NSBundle.mainBundle().pathForResource( "esc01", ofType: "jpg", inDirectory: "Res/tales/\(bookId)/images\(resolutionPath)" )

        return imagePath!
    }
    
    func getCoverImage( bookId:String ) -> String
    {
        let resolutionPath = (self.isHD) ? "/" : "/sd/"
        let imagePath = NSBundle.mainBundle().pathForResource( "cover", ofType: "png", inDirectory: "Res/tales/\(bookId)/images\(resolutionPath)" )
        
        return imagePath!
    }
    
    
    /*=============================================================*/
    /*                       Private Section                       */
    /*=============================================================*/
    private init(langId:String, isHD:Bool)
    {
        self.langId = langId
        self.isHD = isHD
        self.talesDescription = [String:AnyObject]()
        self.bookId = ""
        self.book = Book(id: "01_rdo", langId: self.langId, isHD: self.isHD )
    }
    
    private func load()
    {
        //let fm = NSFileManager.defaultManager()
        let talesPath = NSBundle.mainBundle().pathsForResourcesOfType("", inDirectory: "Res/tales/")
        for talePath in talesPath
        {
            let file = talePath+"/description.json"
            do
            {
                let fileContent = try NSString(contentsOfFile: file, encoding: NSUTF8StringEncoding )
                let fc = fileContent as String!
                self.processDescription( fc )
            }
            catch let error as NSError
            {
                print( "Failed to load: \(error.localizedDescription)" )
            }
        }
    }
    
    private func processDescription( description:String )
    {
        let taleDescription:AnyObject = self.getJSON( description )!
        let isBook:Bool = taleDescription["isBook"] as! Bool
        if( isBook )
        {
            let id:String = taleDescription["id"] as! String
            self.talesDescription[id] = taleDescription
        }
    }
    
    private func getJSON(stringJSON:String)->AnyObject?
    {
        let json:AnyObject?;
        
        do
        {
            let data = stringJSON.dataUsingEncoding( NSUTF8StringEncoding, allowLossyConversion: false );
            json = try NSJSONSerialization.JSONObjectWithData( data!, options: .AllowFragments );
        }
        catch let error as NSError
        {
            print( "Failed to load: \(error.localizedDescription)" );
            json = nil;
        }
        
        return json;
    }

    private var talesDescription:[String:AnyObject?]
    private var langId:String
    private static var instance:Library? = nil
    private var book:Book
    private var isHD:Bool
    private var bookId:String
}