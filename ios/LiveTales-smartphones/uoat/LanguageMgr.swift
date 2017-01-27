//
//  LanguageMgr.swift
//  uoat
//
//  Created by Pyro User on 5/5/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import Foundation

class LanguageMgr
{
    static let getInstance = LanguageMgr();
    
    func getId() -> String
    {
        return self.langId;
    }
    
    func setId( langId:String )
    {
        self.langId = ( SUPPORTED_LANGS.contains( langId ) ) ? langId : DEFAULT_LANG;
    }
    
    
    /*=============================================================*/
    /*                       Private Section                       */
    /*=============================================================*/
    private  init()
    {
        self.langId = DEFAULT_LANG;
    }
    
    private var langId:String;
    private let SUPPORTED_LANGS = ["en","es","de"];
    private let DEFAULT_LANG:String = "en";
}