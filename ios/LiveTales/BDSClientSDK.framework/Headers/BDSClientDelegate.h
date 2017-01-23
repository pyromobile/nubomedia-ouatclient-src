//
//  BDSClientDelegate.h
//  MementoClient
//
//  Created by Javier Cancio on 12/6/15.
//  Copyright (c) 2015 Javier Cancio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDSClientEvent.h"

@protocol BDSClientDelegate <NSObject>

@optional

- (void)sender:(id)sender didQueuedEvent:(BDSClientEvent *)event;
- (void)sender:(id)sender didSentEvents:(NSArray *)sendedEvents;
- (void)sender:(id)sender didSentEventsWithError:(NSArray *)sendedEvents;
- (void)sender:(id)sender didSentSuccessfullyEvents:(NSArray *)events;
- (void)sender:(id)sender didDiscardedEvents:(NSArray *)discardedEvents;

@end