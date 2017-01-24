//
//  BDSClientEvent.h
//  MementoClient
//
//  Created by Javier Cancio on 12/6/15.
//  Copyright (c) 2015 Javier Cancio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDSClientEvent : NSObject<NSCoding>

/* Event type */
@property (nonatomic, strong, readonly) NSString *type;

/* Event main Application ID */
@property (nonatomic, strong, readonly) NSString *applicationId;

/* User ID associate to this event */
@property (nonatomic, strong, readonly) NSString *userId;

/* Event creation timestamp (in MILLISECONDS) */
@property (nonatomic, readonly) NSTimeInterval timestamp;

/* Custom additional data */
@property (nonatomic, strong, readonly) NSDictionary *payload;

/**
 * Initializes new event
 *
 *  @param type         Event type
 *  @param appId        Event main Application ID
 *  @param userId       User ID associate to this event
 *  @param timestamp    Event creation timestamp (in MILLISECONDS)
 *  @param extraData    Custom additional data
 */
 
- (instancetype)initWithType:(NSString *)type
               applicationId:(NSString *)appId
                      userId:(NSString *)userId
                   timestamp:(NSTimeInterval)timestamp
                     payload:(NSDictionary *)extraData;

/**
 *  @return Dictionary description of this event
 */
- (NSDictionary *)getDictionary;

@end
