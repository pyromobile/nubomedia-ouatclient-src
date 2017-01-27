//
//  KDevices.h
//  KuasarsDevices
//
//  Created by Matteo Novelli on 13/05/13.
//  Copyright (c) 2013 Glass. All rights reserved.
//

#import "KuasarsObject.h"

@class KuasarsQueryParams;

/**
 Class for managing Kuasars Devices
 */
@interface KuasarsDevice : KuasarsObject

/** @name Device attributes */

/** Device unique ID */
@property (nonatomic, readonly) NSString *ID;

/** Device token */
@property (nonatomic) NSString *notificationToken;

/** Device unique identifier */
@property (nonatomic, readonly) NSString *uniqueIdentifier;

/** Notification service of the device */
@property (nonatomic, readonly) NSString *notificationService;

/** This device will receive notifications */
@property (nonatomic) BOOL notificationEnabled;

/** Wildcard field, that could be used by the developer to internal process */
@property (nonatomic) NSDictionary *custom;

/** Object that store application metaData information. Ex appURLs, logoURL...etc */
@property (nonatomic) NSDictionary *metaData;

/** User identifier */
@property (nonatomic, readonly) NSString *userID;

/**
 @name Constructors
 */

/**
 Returns an KuasarsDevice object initialized by the JSON object returned by the server.
 @param response Dictionary returned by the server
 @return New instance of KuasarsDevice
 */
- (KS_INSTANCETYPE)initWithServerResponse:(NSDictionary *)response;

/**
 Returns a KuasarsDevice object
 @param token Device notification token
 @param notificationEnabled Boolean indicating if push notifications are enabled
 @return New instance of KuasarsUser
 */
- (KS_INSTANCETYPE)initWithNotificationToken:(NSString *)token notificationEnabled:(BOOL)notificationEnabled;

/**
 @name Creating, updating and deleting
 */

/**
 Creates new device object on Kuasars servers using current object as new device. If current device already exists on Kuasars,
 it will updated with current object data.
 @param completion Block with server response
 */
-(void)save:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 Removes current device object from Kuasar servers
 @param completion Block with server response
 */
-(void)delete:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 @name Getting devices
 */

/**
 Returns advanced information about a given device
 @param deviceID Device identifier
 @param completion Handler with server response
 */
+ (void)getDeviceWithID:(NSString *)deviceID completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;



@end
