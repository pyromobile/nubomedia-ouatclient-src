//
//  BDSClientController.h
//  MementoClient
//
//  Created by Javier Cancio on 15/7/15.
//  Copyright (c) 2015 Javier Cancio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDSClientDelegate.h"

/**
 *  Available Memento Environments
 */
typedef NS_ENUM(unsigned char, BDSEnvironment) {
    /**
     *  Integration environment
     */
    BDSEnvironmentINT,
    /**
     *  Pre-production environment (default environment)
     */
    BDSEnvironmentPRE,
    /**
     *  Production environment
     */
    BDSEnvironmentPRO
};

@interface BDSClientController : NSObject

/* Application identifier */
@property (nonatomic, readonly) NSString *appId;

/* Sets the connection timeout */
@property (nonatomic, readwrite) NSTimeInterval connectionTimeout;

/* Turns on/off the logging messages */
@property (nonatomic, readwrite) BOOL debugEnabled;

/* Flag to decide keep events between sessions or not */
@property (nonatomic, readwrite) BOOL batchPersistance;

/* Determines how many events should wait before send the event request */
@property (nonatomic, readwrite) int bufferSize;

/* How much time since last request have to wait to send the new one */
@property (nonatomic, readwrite) double waitingTime;

/* Custom extra headers provided by the developer. This headers are the MAIN request headers */
@property (nonatomic, strong) NSDictionary *extraHeaders;

/* Custom extra headers to be sent on event header fields */
@property (nonatomic, strong) NSDictionary *eventHeaders;

/* BDS Client Delegate */
@property (nonatomic, assign) id<BDSClientDelegate> delegate;


/**
 *  Returns a instance of BDSClientController
 */
+ (instancetype)sharedInstance;

/**
 *  Initialize Memento metrics for a specific user.
 *
 *  @param environment      Memento environment
 *  @param appId            Application identifier
 *  @param password         Memento's user password
 */
- (void)setupEnvironment:(BDSEnvironment)environment appid:(NSString *)appId password:(NSString *)password;

/**
 *  Send a 'start session' event with no additional data. Default values will be used.
 */
- (void)sendStartSessionEvent;

/**
 *  Send a 'start session' event with custom data.
 *
 *  @param userid           User identifier of the event.
 *  @param userPayload      Custom information to be added to this event.
 */
- (void)sendStartSessionEvent:(NSString *)userid payload:(NSDictionary *)userPayload;

/**
 *  Send a 'close session' event with no additional data. Default values will be used.
 */
- (void)sendCloseSessionEvent;

/**
 *  Send a 'end session' event with custom data.
 *
 *  @param userid           User identifier of the event.
 *  @param userPayload      Custom information to be added to this event.
 */
- (void)sendCloseSessionEvent:(NSString *)userid payload:(NSDictionary *)userPayload;

/**
 *  Send a 'purchase' event with custom data.
 *
 *  @param userid           User identifier of the event.
 *  @param userPayload      Custom infotmation to be added to this event.
 */
- (void)sendPurchaseEvent:(NSString *)userid payload:(NSDictionary *)userPayload;

/**
 *  Send a custom event with custom data.
 *  @param  eventType       Type of the custom event.
 *  @param  userid          User identifier of the event
 *  @param  userPayload     Custom information to be added to this event.
 */
- (void)sendCustomEvent:(NSString *)eventType userid:(NSString *)userid payload:(NSDictionary *)userPayload;

/**
 *  Send a 'connection error' event with custom data.
 *
 *  @param userid           User identifier of the event.
 *  @param userPayload      Custom infotmation to be added to this event.
 */
- (void)sendConnectionErrorEvent:(NSString *)userid payload:(NSDictionary *)userPayload;

@end
