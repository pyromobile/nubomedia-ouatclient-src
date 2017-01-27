//
//  ConfigModel.swift
//  uoat
//
//  Created by Pyro User on 17/11/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import Foundation

class ConfigModel
{
    class func getConfig( onConfigReady:(config:[String:String]?)->Void)
    {
        var config:[String:String]? = nil //[String:String]()
        
        /*
        let criteria:[String:AnyObject] = ["id":"appconfig"]
        let query = KuasarsQuery( criteria, retrievingFields: nil ) as KuasarsQuery
        KuasarsEntity.query( query, entityType: "config", occEnabled: false, completion:{ (response:KuasarsResponse!, error:KuasarsError!) -> Void in
            if( error != nil )
            {
                print( "Error from kuasars: \(error.description)" )
            }
            else
            {
                config = [String:String]()
                let entities = response.contentObjects as! [KuasarsEntity]
                for entity:KuasarsEntity in entities
                {
                    let id:String = entity.ID
                    let kmsServiceUrl:String = (entity.customData!["kms_service_url"])! as! String
                    
                    config!["id"] = id
                    config!["kms_service_url"] = kmsServiceUrl
                }
            }
            onConfigReady( config:config )
        })
        */
        KuasarsEntity.getWithType("config", entityID: "appconfig", occEnabled: false) { (response:KuasarsResponse!, error:KuasarsError!) in
            if( error != nil )
            {
                print( "Error from kuasars: \(error.description)" )
            }
            else
            {
                config = [String:String]()
                let configEntity = response.contentObjects[0] as! KuasarsEntity
                let id:String = configEntity.ID
                let kmsServiceUrl:String = (configEntity.customData!["kms_service_url"])! as! String
                
                config!["id"] = id
                config!["kms_service_url"] = kmsServiceUrl
            }
            onConfigReady( config:config )
        }
    }
}