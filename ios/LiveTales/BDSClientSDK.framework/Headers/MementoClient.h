//
//  Memento.h
//  MementoClient
//
//  Created by Javier Cancio on 01/10/14.
//  Copyright (c) 2014 Javier Cancio. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Available Memento Environments
 */
typedef NS_ENUM(unsigned char, MementoEnvironment) {
    /**
     *  Integration environment
     */
    MementoEnvironmentINT,
    /**
     *  Pre-production environment (default environment)
     */
    MementoEnvironmentPRE,
    /**
     *  Production environment
     */
    MementoEnvironmentPRO
};

__deprecated
@interface MementoClient : NSObject

/**
 *  Initialize Memento metrics for a specific user.
 *
 *  @param environment      Memento environment
 *  @param appId            Application identifier
 *  @param password         Memento's user password
 */
+ (void)setupEnvironment:(MementoEnvironment)environment appId:(NSString *)appId password:(NSString *)password __deprecated;


/**
 *  Set the connection timeout.
 *
 *  @param timeout          Timeout (in seconds) to wait until server response. Default timeout is 10 seconds.
 */
+ (void)setConnectionTimeout:(NSTimeInterval)timeout __deprecated;

/**
 *  Enable/Disable logging messages on console. Only error messages and body requests will be shown.
 *
 *  @param enabled          Indicates whether or not to enable logging.
 */
+ (void)enableDebug:(BOOL)enabled __deprecated;

/**
 *  Send a 'start session' event with no additional data. Default values will be used.
 */
+ (void)sendStartSessionEvent __deprecated;

/**
 *  Send a 'start session' event with custom data.
 *
 *  @param userid           User identifier of the event.
 *  @param userPayload      Custom information to be added to this event.
 */
+ (void)sendStartSessionEvent:(NSString *)userid payload:(NSDictionary *)userPayload __deprecated;

/**
 *  Send a 'close session' event with no additional data. Default values will be used.
 */
+ (void)sendCloseSessionEvent __deprecated;

/**
 *  Send a 'end session' event with custom data.
 *
 *  @param userid           User identifier of the event.
 *  @param userPayload      Custom information to be added to this event.
 */
+ (void)sendCloseSessionEvent:(NSString *)userid payload:(NSDictionary *)userPayload __deprecated;

/**
 *  Send a 'purchase' event with custom data.
 *
 *  @param userid           User identifier of the event.
 *  @param userPayload      Custom infotmation to be added to this event.
 */
+ (void)sendPurchaseEvent:(NSString *)userid payload:(NSDictionary *)userPayload __deprecated;

/**
 *  Send a custom event with custom data.
 *  @param  eventType       Type of the custom event.
 *  @param  userid          User identifier of the event
 *  @param  userPayload     Custom information to be added to this event.
 */
+ (void)sendCustomEvent:(NSString *)eventType userid:(NSString *)userid payload:(NSDictionary *)userPayload __deprecated;

@end
