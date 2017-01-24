//
//  KuasarsServices.h
//  Kuasars
//
//  Created by Matteo Novelli on 19/11/13.
//  Copyright (c) 2013 Glass. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KuasarsRequest;
@class KuasarsQueryParams;
@class KuasarsQuery;
@class KuasarsUser;
@class KuasarsDevice;
@class KuasarsEntity;

/**
 KuasarsServices is used to add operations to `KuasarsBatch` queue. This is useful to perform many requests at a once. This class lists available queued-operations
 */
@interface KuasarsServices : NSObject

///--------------------------------------
/// @name KuasarsCore Operations
///--------------------------------------

/**
*  Creates new request for retrieving the current timestamp from Kuasars Servers
*
*  @return Constructed request to be added to `KuasarsBatch` queue
*/
+ (KuasarsRequest *)getCurrentTime;

/**
 *  Creates new request for refreshing users session token
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)refreshSessionToken;

/**
 *  Creates new request for login an user with email and password method
 *
 *  @param  email       User's email addres to login with
 *  @param  password    User's password
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)loginWithEmail:(NSString *)email password:(NSString *)password;

/**
 *  Creates new request for login an user with internal token method
 *
 *  @param  token   Application's internal token
 *  @param  userid  User identifier
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)loginWithInternalToken:(NSString *)token userid:(NSString *)userid;

/**
 *  Creates new request for login an user with facebook method
 *
 *  @param  facebookID      Facebook unique identifier
 *  @param  accessToken     Facebook access token
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)loginWithFacebook:(NSString *)facebookID accessToken:(NSString *)accessToken;

/**
 *  Creates new request to logout the current user
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)logout;

///--------------------------------------
/// @name KuasarsNotifications Operations
///--------------------------------------

/**
 *  Creates new request for sending notifications to a list of users
 *
 *  @param message      Message to be sent
 *  @param users        List of users who will receive the notification
 *  @param category     Notification category
 *  @param customData   Additional data to be added
 *  @param badgeCounter Number to be shown on App's badge counter
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)sendNotificationMessage:(NSString *)message
                                    toUsers:(NSArray *)users
                                   category:(NSString *)category
                                 customData:(NSDictionary *)customData
                               badgeCounter:(int)badge;

///--------------------------------------
/// @name KuasarsEvents Operations
///--------------------------------------

/**
 *  Creates new request for registering events
 *
 *  @param eventType Event typename
 *  @param timestamp Timestamp of the event
 *  @param data      Custom data to store associated with the event
 *  @param userid    User ID that has triggered the event
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)createNewEvent:(NSString *)eventType
                         timestamp:(NSTimeInterval)timestamp
                        customData:(NSDictionary *)data
                            userid:(NSString *)userid;

/**
 *  Creates new request for registering multiple events
 *
 *  @param events   An array of events to store on Kuasars
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)createMultipleEvents:(NSArray *)events;

///--------------------------------------
/// @name KuasarsUsers Operations
///--------------------------------------

/**
 *  Registers new user by Facebook
 *
 *  @param facebookID   User's facebook ID
 *  @param accessToken  User's facebook access token
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)registerUserByFacebook:(NSString *)facebookID
                               accessToken:(NSString *)accessToken;

/**
 *  Registers new user by Email
 *
 *  @param email                User's email address
 *  @param userPassword         Users password
 *  @param verificationCode     Validation code provided by Kuasars
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)registerUserByEmail:(NSString *)email
                               password:(NSString *)userPassword
                       verificationCode:(NSString *)verificationCode;

/**
 *  Registers new user by Internal Token and Internal ID
 *
 *  @param accessToken  Internal access token for authentication
 *  @param internalID   Custom identifier for internal token sessions
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)registerUserByInternalToken:(NSString *)accessToken
                             internalIdentifier:(NSString *)internalID;

/**
 *  Registers new user by Internal Token
 *
 *  @param accessToken  Internal access token for authentication
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)registerUserByInternalToken:(NSString *)accessToken;

/**
 *  Saves new user on Kuasars
 *
 *  @param user User to be saved
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)saveNewUser:(KuasarsUser *)user;

/**
 *  Replaces user data
 *
 *  @param user User which data will be replaced
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)replaceExistingUser:(KuasarsUser *)user;

/**
 *  Replaces current user's email by given one
 *
 *  @param  newEmail            New user's email address to be used
 *  @param  userPassword        User's current password
 *  @param  verificationCode    Verification code sent to old user's email in order to be able to change that email
 *  @param  user                Instance of `KuasarsUser` with the user who will change its email
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)updateUserEmail:(NSString *)newEmail
                           password:(NSString *)userPassword
                   verificationCode:(NSString *)verificationCode
                            forUser:(KuasarsUser *)user;

/**
 *  Retrieves user specified by its ID
 *
 *  @param userID ID of the desired user
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)getUserWithID:(NSString *)userID;

/**
 *  Deletes user from Kuasars
 *
 *  @param user User to be deleted
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)deleteUser:(KuasarsUser *)user;

/**
 * Performs a mongoDB query for searching specified users by email authenticator.
 *
 * @param query               Constructed and configured `KuasarsQuery` object
 *
 * @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)queryUserByEmail:(KuasarsQuery *)query;

/**
 * Performs a mongoDB query for searching specified users by facebook authenticator.
 *
 * @param query               Constructed and configured `KuasarsQuery` object
 *
 * @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)queryUserByFacebook:(KuasarsQuery *)query;

///--------------------------------------
/// @name KuasarsDevices Operations
///--------------------------------------

/**
 *  Saves new device for current application on Kuasars
 *
 *  @param device Device object to be saved
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)saveNewDevice:(KuasarsDevice *)device;

/**
 *  Returns `KuasarsDevice`object with specified device ID
 *
 *  @param deviceID Device ID to be retrieved
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)getDeviceWithID:(NSString *)deviceID;

/**
 *  Deletes current device from Kuasars
 *
 *  @param device Device to be deleted
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)deleteDevice:(KuasarsDevice *)device;


///--------------------------------------
/// @name KuasarsEntities Operations
///--------------------------------------

/**
 *  Saves new entity objetct on Kuasars
 *
 *  @param entity Entity to be saved
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)saveNewEntity:(KuasarsEntity *)entity;

/**
 *  Replaces specified entity with its new content
 *
 *  @param entity Entity to be replaced
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)replaceExistingEntity:(KuasarsEntity *)entity;

/**
 *  Retrieves entity from Kuasars with specified ID and type
 *
 *  @param entityID   ID of the desired entity
 *  @param type       Entitie's type
 *  @param occEnabled Determines if it is an occ entity or not
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)getEntityWithID:(NSString *)entityID
                               type:(NSString *)type
                         occEnabled:(BOOL)occEnabled;

/**
 * Retruns how many entities matches the input query (must be a mongoDB expression) for specified type. If no query is provided, this method returns the amount of entities that belongs to the specified type
 * 
 * @param type          Entitie's type
 * @param query         MongoDB query
 * @param occEnabled    Determines if it is an occ entity or not
 *
 * @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)countEntitiesWithType:(NSString *)type
                               countQuery:(NSDictionary *)query
                               occEnabled:(BOOL)occEnabled;

/**
 *  Deletes actual entity from Kuasars
 *
 *  @param entity Entity to be deleted
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)deleteEntity:(KuasarsEntity *)entity;

/**
 *  Deletes some entities from Kuasars
 *
 *  @param type kind of entities to be deleted. At the moment, only non OCC types are accepted.
 *  @param ids identifiers of the entities to be deleted.
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)deleteEntitiesOfType:(NSString *)type ids:(NSArray *)ids;

/**
 *  Performs a query over all entity of the specified type
 *
 *  @param query      MongoDB query
 *  @param params     Filter parameters
 *  @param type       Entities type
 *  @param occEnabled Determines if it is an occ entity or not
 *
 *  @return Constructed request to be added to `KuasarsBatch` queue
 */
+ (KuasarsRequest *)queryEntities:(NSDictionary *)query
                      queryParams:(KuasarsQueryParams *)params
                             type:(NSString *)type
                       occEnabled:(BOOL)occEnabled __deprecated;

/**
 * Performs a query over all entities of the specific type, using new query method
 * 
 * @param query         A `KuasarsQuery` object
 * @param type          The type of the entity to be queried
 * @param occEnabled    Indicates if query should be performed on occ entities or not
 * @param completion Block with array of returned entities as KuasarsResponse content data
 */
+ (KuasarsRequest *)queryEntities:(KuasarsQuery *)params
                             type:(NSString *)type
                       occEnabled:(BOOL)occEnabled;

@end
