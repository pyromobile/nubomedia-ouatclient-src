//
//  KuasarsEvents.h
//  Kuasars
//
//  Created by Javier Cancio on 28/11/13.
//  Copyright (c) 2013 Glass. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BDSClientSDK/BDSClientSDK.h>

/**
 KuasarsEvents class is used to create new event records
 */

@interface KuasarsEvents : BDSClientController

@property NSString *type;
@property NSTimeInterval timestamp;
@property NSDictionary *data;
@property NSString *userid;

///--------------------------
/// @name Creating new events
///--------------------------

/**
 Initializes an `KuasarsEvents` object with specified tye, timestamp and custom data.
 
 This is the designated initializer. You can use default initializer, which uses a default type, actual timestamp and no custom data.
 
 @param type        The type of the event to be recordered
 @param timestamp   Timestamp (milliseconds) of the event
 @param eventData   The event's custom data values to store
 @param userid      User identifier associated to the event
 
 @return The newly-initialized Event object
 */
-(KS_INSTANCETYPE)initWithType:(NSString *)type
                      timestamp:(NSTimeInterval)timestamp
                          data:(NSDictionary *)eventData
                        userid:(NSString *)userid;


/** 
 Saves current event object on Kuasars.
 
 @param completion A block object with Kuasars response
 */
- (void)save:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 Saves multiple events on Kuasars.

 @param events      An array of `KuasarsEvents` objects to store on Kuasars
 @param completion  A block object with Kuasars response
 */
+ (void)saveMultipleEvents:(NSArray *)events completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 Creates and saves new event record for specified user with desired info
 
 @param eventType   The type of the new event
 @param timestamp   Date in timestamp format, to indicate when event has been created
 @param data        Information to be stored on new event
 @param userid      User identifier associated to the event
 @param handler     Block with response information, indicates if something was wrong
 */
+ (void)saveNewEventType:(NSString *)eventType
               timestamp:(NSTimeInterval)timestamp
              customData:(NSDictionary *)data
                  userid:(NSString *)userid
              completion:(void(^)(KuasarsResponse *object, KuasarsError *error))handler;


/**
 *  Send a 'start session' event with custom data.
 *
 *  @param userid           User identifier of the event.
 *  @param data             Custom information to be added to this event.
 *  @param handler          Block with response information, indicates if something was wrong
 */
+ (void)sendStartSessionEventForUserId:(NSString *)userid customData:(NSDictionary *)data completion:(KResponseBlock)handler;


/**
 *  Send a 'end session' event with custom data.
 *
 *  @param userid           User identifier of the event.
 *  @param data             Custom information to be added to this event.
 *  @param handler          Block with response information, indicates if something was wrong
 */
+ (void)sendCloseSessionEventForUserId:(NSString *)userid customData:(NSDictionary *)data completion:(KResponseBlock)handler;


/**
 *  Send a 'purchase' event with custom data.
 *
 *  @param userid           User identifier of the event.
 *  @param data             Custom information to be added to this event.
 *  @param handler          Block with response information, indicates if something was wrong
 */
+ (void)sendPurchaseEventForUserId:(NSString *)userid customData:(NSDictionary *)data completion:(KResponseBlock)handler;

@end
