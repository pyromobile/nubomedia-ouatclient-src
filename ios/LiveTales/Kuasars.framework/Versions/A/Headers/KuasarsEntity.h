//
//  KEntity.h
//  KuasarsEntities
//
//  Created by Matteo Novelli on 13/05/13.
//  Copyright (c) 2013 Glass. All rights reserved.
//

#import "KuasarsObject.h"
#import "KuasarsQueryParams.h" // TODO: Remove this import
#import "KuasarsQuery.h"
#import "KuasarsPermissions.h"

/**
 Entities are the main system for storing application-specific information in Kuasars.
 
 An entity is essentially a JSON-style object with a few pre-defined fields and an arbitrary number and type of application-supplied fields.
 */

@interface KuasarsEntity : KuasarsObject

///------------------------------------------
/// @name Accessing Kuasars Entity properties
///------------------------------------------


/** Entity unique identificator */
@property (nonatomic, strong) NSString *ID;

/** The type of the entity */
@property (nonatomic, strong) NSString *type;

/** The entity's object data */
@property (nonatomic, strong) NSMutableDictionary *customData;

/** The entity's ACL (Access Control List) */
@property (nonatomic, readonly) KuasarsPermissions *permissions;

/** Indicates whether optimistic concurrency control mode is enabled or not */
@property (nonatomic, readonly) BOOL occ;

/** Version number used by optimistic concurrency control */
@property (atomic, readonly) int version;

/** Expiration date (timestamp) */
@property (nonatomic, readwrite) NSTimeInterval expireAt;


///-----------------------------------------------
/// @name Creating and Initializing Entity Objects
///-----------------------------------------------

/** 
 Initializes an Entity object for specified type and specified data as content
 
 @param type The type of the entity which this object belongs to
 @param customData The entity's content data
 @param expirationDate Entity expiration date (timestamp format)
 @param occEnabled Boolean indicating if new entity uses optimistic concurrency control
 
 */
- (KS_INSTANCETYPE)initWithType:(NSString *)type customData:(NSDictionary *)customData expirationDate:(NSTimeInterval)expirationDate occEnabled:(BOOL)occEnabled;


///-----------------------------------------------------
/// @name Storing, updating and deleting Entity objects
///-----------------------------------------------------

/**
 Stores actual entity object on Kuasars servers. Once it is saved, this method updates entity ID and customData fields with Kuasars response, to identify it among all entities of the same type.
 
 @param completion Block with server response. It will have either Kuasars response and Kuasars error (if something was wrong). Kuasars response will be a KuasarsResponse instance with response code and one-element array with entity's data.
 */
- (void)save:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 Replaces Kuasars info for this entity with the actual contentData info.
 
 @param completion Block with server response. It will have either Kuasars response, with the response status code and new entity data, and Kuasars error if something was wrong.
 */
- (void)replace:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 Deletes entity from Kuasars server.
 
 @param completion Block with server response containing the entity that has been deleted.
 */
- (void)delete:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 Sets new permisions (ACL) to the current entity
 
 @param permissions KuasarsPermissions object to be setted as new ACL
 */
- (void)setPermissions:(KuasarsPermissions *)permissions;

/**
 Retrieves permission list (ACL) of the current entity from server
 
 @param completion Block with entity permissions. This permissions will be on object value, under contentObjects as an one-element array.
 */
- (void)getPermissions:(void(^)(KuasarsResponse *object, KuasarsError *error)) completion;

/**
 Updates permissions (ACL) to the current entity
 
 @param newPermissions KuasarsPermissions object with desired permisses.
 
 @param completion Block with server response. This response will be a KuasarsPermission instance with current permissions.
 */
- (void)updatePermissions:(KuasarsPermissions *)newPermissions completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

///------------------------------
/// @name Managing entity objects
///------------------------------


/**
 Delete some entities from server by using their identifiers.
 
 @param type kind of entities to be deleted. At the moment, only non OCC types are accepted.
 @param ids identifiers of the entities to be deleted.
 
 @param completion Block with returned entity as KuasarsResponse content value
 */
+ (void)deleteEntitiesOfType:(NSString *)type withIds:(NSArray *)ids completion:(KResponseBlock)completion;

/**
 Retrieves an entity object. To get an entity you must to know both its type and its id. You can obtain the id value by saving new entity object, or perfoming a query.
 
 @param type The entity type
 @param entityID The entity id
 @param occ Boolean indicating entities with occ enabled or not
 @param completion Block with returned entity as KuasarsResponse content value
 */
+ (void)getWithType:(NSString *)type entityID:(NSString *)entityID occEnabled:(BOOL)occ completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 Returns all entities for specified type
 
 @param type The type of which we want to get the entities from
 @param occ Boolean indicating entities with occ enabled or not
 @param completion Block with an array of entities as KuasarsResponse content
 */
+ (void)getEntitiesWithType:(NSString *)type occEnabled:(BOOL)occ completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 Returns the amount of entities that belongs to specified type that matches query expression. This query must be a mongoDB expression.
 @param query MongoDB expression to filter entities of specified type
 @param type The type of the entities
 @param occ Boolean indicating entities with occ enabled or not
 @param completion Block with entities count that matches input query
 */
+ (void)countWithQuery:(NSDictionary *)query entityType:(NSString *)type occEnabled:(BOOL)occ completion:(void(^)(NSUInteger count, KuasarsError *error))completion;

/**
 Performs a mongoDB query for specified type.
 
 @param query MongoDB expression
 @param params Parameters for pagination and order filters
 @param type The type of the entities
 @param occ Boolean indicating entities with occ enabled or not
 @param completion Block with array of returned entities as KuasarsResponse content data
 */
+ (void)query:(NSDictionary *)query queryParams:(KuasarsQueryParams *)params entityType:(NSString *)type occEnabled:(BOOL)occ completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion __deprecated;


/**
 Performs a mongoDB query for specified type.
 
 @param params Constructed `KuasarsQuery` object
 @param type The type of the entities
 @param occ Boolean indicating entities with occ enabled or not
 @param completion Block with array of returned entities as KuasarsResponse content data
 */
+ (void)query:(KuasarsQuery *)params entityType:(NSString *)type occEnabled:(BOOL)occ completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

@end
