//
//  KuasarsCore.h
//  KuasarsCore
//
//  Created by Matteo Novelli on 22/05/13.
//  Copyright (c) 2013 Glass. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSObjCRuntime.h>

/**
 Takes advantage of the new instancetype value if it's available
 */

#ifndef KS_INSTANCETYPE
#if __has_feature(objc_instancetype)
#define KS_INSTANCETYPE instancetype
#else
#define KS_INSTANCETYPE id
#endif
#endif


@class KuasarsError;
@class KuasarsResponse;
@class KuasarsRequest;

typedef void (^KResponseBlock)(KuasarsResponse *object, KuasarsError *error);
typedef void (^KuasarsGetBlock)(NSUInteger count, KuasarsError *error);

typedef enum {
    KuasarsEnvironmentPRO,
    KuasarsEnvironmentPRE,
    KuasarsEnvironmentDEV
} KuasarsEnvironment;

typedef enum {
    POST,
    PUT,
    DELETE,
    GET,
    PATCH
} RequestMethod;

/**

 Kuasars class is responsible for the local storage of all attributes needed to start working with Kuasars Framework. It provides getters ans setters for each attributes and also provides an interface to realize the login process and execute your own requests directly on Kuasars server. As a developer this is the only class you need to set up before start using any of the Kuasars modules availables.
 
 This class is designed as singleton wich means is no need to create an instance of its. All you need is just to set up the attributes using the static methods provided by Kuasars class. This will ensure in your application exists one and only instance of this class. 

 All methods are described below and some example of uses are given in the following lines.
 
 */
@interface KuasarsCore : NSObject

/** @name Kuasars Core initialization methods */

/**
 Sets the application key for start using Kuasars
 @param appId Unique identifier for the application provided by Kuasars
 @discussion  This is the only required attribute and it represents the identifier for your application. This id is provided by Kuasars when you create an application through the Glass Management Console.
 */
+ (void)setAppId:(NSString *)appId;

/**
 Sets the environment target
 @param environment Kuasars server environment
 @discussion Kuasars server environment points to one of the server environments. The available options are:
 
 - Production (KuasarsEnvironmentPRO)
 - Pre-production (KuasarsEnvironmentPRE)
 - Development (KuasarsEnvironmentDEV)

 Production environment is setted by default.
 
 */
+ (void)setEnvironment:(KuasarsEnvironment)environment;

/**
 Sets the Kuasars backend version you want to use in your application
 @param version An string indicating the version
 @discussion The default value for this attribute is @"v1"
 */
+ (void)setBackendVersion:(NSString *)version;

/**
 Enables debugger log messages
 
 @param enabled It turns on/off debugger messages
 */
+ (void)setDebuggerEnabled:(BOOL)enabled;

/**
 Enables compressed requests
 
 @param enabled It turns on/off compressed requests
 */
+ (void)setCompressionEnabled:(BOOL)enabled;

/**
 Indicates timeout interval.
 @param timeout Timeout interval
 */
+ (void)setTimeout:(NSTimeInterval)timeout;

/**
 Indicates retry intervals.
 @param firstInterval Time interval between retries
 @param ... List with time intervals
 */
+ (void)setRetryIntervals:(NSNumber *)firstInterval, ... NS_REQUIRES_NIL_TERMINATION;

/** @name Getting values */

/**
 Returns Kuasars environment in use
 @return Current Kuasars environment
 */
+ (KuasarsEnvironment)environment;

/**
 Returns Kuasars APP ID in use
 @return Current Kuasars APP ID
 */
+ (NSString *)appId;

/**
 Returns current user's ID
 @return Current user's ID
 */
+ (NSString *)currentUserID;

/**
 Returns current session token
 @return Current session token
 */
+ (NSString *)sessionToken;

/**
 Returns current backend version in use
 @return Current backend version
 */
+ (NSString *)backendVersion;

/**
 Returns whether debugger is enabled or not 
 */
+ (BOOL)isDebuggerEnabled;

/**
 Returns whether compressed requests are enabled or not
 */
+ (BOOL)compressionEnabled;

/**
 Returns timeout interval used for requests
 */
+ (NSTimeInterval)timeout;

/**
 Returns retry intervals
 */
+ (NSArray *)retryIntervals;

/** @name Helper methods */

/**
 Executes requests on the Kuasars backend.
 @param request KuasarsRequest object
 @param completion Handler with server response
 @discussion This method provides an easy way for launching your own requests to the Kuasars backend but it's only recommended for developers who knows the depths of the Kuasars REST API. Furthermore every single module of the Kuasars Framework it provides specific objects that help you to develope your own application.
 */
+ (void)executeRequest:(KuasarsRequest *)request response:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 Executes requests on the Kuasars backend.
 @param method HTTP method (GET, POST, PUT, PATCH, DELETE)
 @param path Path for the service
 @param parameters Parameters for the request
 @param name Filename to be upload
 @param dataFile NSData object with encoded file
 @param mimeType Mime type of the incoming file
 @param completion Handler with server response
 @discussion This method provides an easy way for launching your own requests to the Kuasars backend but it's only recommended for developers who knows the depths of the Kuasars REST API. Furthermore every single module of the Kuasars Framework it provides specific objects that help you to develope your own application.
 */
+ (void)executeRequestWithMethod:(RequestMethod)method path:(NSString *)path parameters:(NSDictionary *)parameters fileName:(NSString *)name data:(NSData *)dataFile mimeType:(NSString *)mimeType response:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 Makes the login process by email and sets up all the session parameters needed for start using Kuasars.
 @param email User`s email
 @param password User`s password
 @param completion Handler with server response
 */
+ (void)loginWithEmail:(NSString *)email password:(NSString *)password completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 Makes the login process by an application's internal access token and sets up all the session parameters needed for start using Kuasars.
 @param token Application internal access token
 @param userId User identifier
 @param completion Handler with server response
 */
+ (void)loginWithAppInternalToken:(NSString *)token userId:(NSString *)userId completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 Makes the login process by an internal token two and sets up all the session parameters needed for start using Kuasars.
 @param internalTokenTwo Application internal access token
 @param completion Handler with server response
 */
+ (void)loginWithAppInternalTokenTwo:(NSString *)internalTokenTwo completion:(KResponseBlock)completion;

/**
 Makes the login process using facebook uid and sets up all the session parameters needed for start using Kuasars.
 @param uid Facebook unique identifier
 @param accessToken Facebook access token
 @param completion Handler with server response
 */
+ (void)loginWithFacebookUID:(NSString *)uid accessToken:(NSString *)accessToken completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 Makes the logout process and cleans all current session parameters.
 @param completion Handler with server response
 */
+ (void)logout:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 Allows to recover a previously obtained session
 @param sessionToken Session token
 @param completion Handler with server response
 */
+ (void)getSessionWithToken:(NSString *)sessionToken completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 Gets the server current time
 @param completion Handler with server response
 */
+ (void)currentTime:(KResponseBlock)completion;


@end
