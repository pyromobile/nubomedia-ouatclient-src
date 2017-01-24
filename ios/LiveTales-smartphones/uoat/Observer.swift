//
//  Observer.swift
//  uoat
//
//  Created by Pyro User on 9/5/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import Foundation

enum MessageType { case changeLanguage, changeFont, changeMediaCtrl, loadNewBook, repeatTale, changeAccesory, remoteChangePage, inviteRoomNotification, syncBook };

struct Message {
    var type:MessageType;
    var data:[String:AnyObject];
};


protocol Observable:class
{
    //func notify( messageType:MessageType );
    func notify( message:Message );
    func equals( other:Observable)->Bool;
}


class Observer
{
    static let getInstance = Observer();
    
    func subscribe( object:Observable, message:MessageType )
    {
        if( !self.messages.keys.contains( message ) )
        {
            //self.messages[message] = [Observable]()
            //self.messages[message]?.append( object )
            self.messages[message] = [ObservableWeak]()
            self.messages[message]?.append( ObservableWeak(observable:object) )
        }
        else
        {
            var exist = false;
            for( _, objObservableTmp ) in ( self.messages[message]?.enumerate() )!
            {
                if( !exist )
                {
                    exist = ( object.equals( objObservableTmp.observable! ) );
                }
            }
            if( !exist )
            {
                //self.messages[message]?.append( object );
                self.messages[message]?.append( ObservableWeak(observable:object) )
            }
        }
    }
    
    func unsubscribe( object:Observable, message:MessageType )
    {
        if( self.messages.keys.contains( message ) )
        {
            var position = -1;
            for( index, objObservableTmp ) in ( self.messages[message]?.enumerate() )!
            {
                
                if( objObservableTmp.observable == nil ||  object.equals( objObservableTmp.observable! ) )
                {
                    position = index;
                }
            }
            if( position>=0 )
            {
                self.messages[message]?.removeAtIndex( position );
                if( self.messages[message]?.isEmpty == true )
                {
                    self.messages.removeValueForKey( message );
                }
            }
        }
    }
    
    
    //func sendMessage( message:MessageType )
    func sendMessage( message:Message )
    {
        if( self.messages.keys.contains( message.type ) )
        {
            for( _, objObservable ) in ( self.messages[message.type]?.enumerate() )!
            {
                objObservable.observable!.notify( message );
            }
        }
    }

    
    /*=============================================================*/
    /*                       Private Section                       */
    /*=============================================================*/
    private  init()
    {
        self.messages = [MessageType:Array<ObservableWeak>]();
    }
    
    private var messages:[MessageType:Array<ObservableWeak>];
}


class ObservableWeak
{
    init(observable:Observable?)
    {
        self.observable = observable
    }
    
    weak var observable:Observable?
}