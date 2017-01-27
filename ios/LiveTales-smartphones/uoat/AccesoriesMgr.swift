//
//  AccesoriesMgr.swift
//  uoat
//
//  Created by Pyro User on 18/8/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import Foundation

class AccesoriesMgr
{
    static func getInstance()->AccesoriesMgr
    {
        return AccesoriesMgr.instance!
    }
    
    static func create(isHD:Bool)
    {
        AccesoriesMgr.instance = AccesoriesMgr( isHD:isHD )
        AccesoriesMgr.instance?.load()
    }

    func getAll() -> [String:[Complement]]
    {
        return self.accesoriesByPack
    }
    
    func getByPack(pack:String) -> [Complement]
    {
        return self.accesoriesByPack[pack]!
    }
    
    
    /*=============================================================*/
    /*                       Private Section                       */
    /*=============================================================*/
    private  init(isHD:Bool)
    {
        self.isHD = isHD
        self.accesoriesByPack = [String:[Complement]]()
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
                self.processComplements( fc )
            }
            catch let error as NSError
            {
                print( "Failed to load: \(error.localizedDescription)" )
            }
        }
    }
    
    private func processComplements( description:String )
    {
        let complement:AnyObject = self.getJSON( description )!
        let id:String = complement["id"] as! String
        let complements = complement["complements"] as! [String]
        
        let resolutionPath = (self.isHD) ? "/" : "/sd/"
        
        self.accesoriesByPack[id] = [Complement]()
        for complementId:String in complements
        {
            let imagePath = NSBundle.mainBundle().pathForResource( "\(complementId)", ofType: "png", inDirectory: "Res/tales/\(id)/complements\(resolutionPath)" )
            let complement = Complement( id:complementId, imagePath:imagePath!, pack:id )
            self.accesoriesByPack[id]?.append( complement )
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
 
    private static var instance:AccesoriesMgr? = nil
    private var accesoriesByPack:[String:[Complement]]
    private var isHD:Bool
}