//
//  KuasarsQuery.h
//  Kuasars
//
//  Created by Javier Cancio on 22/05/14.
//  Copyright (c) 2014 Glass. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Response ordering
 */
typedef enum {
    KuasarsQueryOrderASC,   //  Order results Ascending
    KuasarsQueryOrderDESC   //  Order results Descending
} KuasarsQueryOrder;

/**
 *  Query type. Find by default
 */
typedef enum {
    KuasarsQueryTypeFind,   // Performs a query looking for desired objects
    KuasarsQueryTypeCount   // Performs a query counting matches to given restrictions
} KuasarsQueryType;

@interface KuasarsQuery : NSObject

///------------------------------------------
/// @name Accessing KuasarsQuery properties
///------------------------------------------

/**
 *  A dictionary representation of the mongo db query
 */
@property (nonatomic, readonly) NSDictionary *query;

/**
 *  List of desired fields. If no fields are provided, the query will return entrie objects
 */
@property (nonatomic, readonly) NSArray *fields;

/**
 *  List of desired order fields and it's order direction
 */
@property (nonatomic, readonly) NSArray *order;

/**
 *  Index of the first result to retrieve. Default index is 0
 */
@property (nonatomic, readonly) NSInteger startingAt;

/**
 *  Number of total results to retrieve. Default is 20 entries
 */
@property (nonatomic, readonly) NSInteger limit;


///-----------------------------------------------
/// @name Creating and Initializing Query Objects
///-----------------------------------------------

/**
 *  Initializes a new `KuasarsQuery` object.
 *
 *  @param type Query type. Find and Count are available (Find is using by default). Find type will search for desired objects meanwhile count type will counting objects that matches to given restrictions.
 *
 *  @return The newly-initialized Query object
 */
- (KS_INSTANCETYPE)initWithType:(KuasarsQueryType)type;


/**
 *  Initializes a new `KuasarsQuery` object.
 *
 *  @param query  MongoDB query
 *  @param fields Desired fields to retrieve from query. If no fields are provided, the query will retrieve whole entry
 *
 *  @return The newly-initialized Query object
 */
+ (KuasarsQuery *)query:(NSDictionary *)query retrievingFields:(NSArray *)fields;


///----------------------
/// @name Query settings
///----------------------


/**
 *  Sets the reveiving index as new startingAt value
 *
 *  @param index The index with which to replace the startingAt value
 */
- (void)setStartingIndex:(int)index;

/**
 *  Sets the max. number of results
 *
 *  @param limit The new max. number of results
 */
- (void)setResultsLimit:(int)limit;

/**
 *  Sets ASC ordering to given key
 *
 *  @param key Desired field to be ordered ascending
 */
- (void)orderByAscending:(NSString *)key;

/**
 *  Sets DESC ordering to given key
 *
 *  @param key Desired field to be ordered descending
 */
- (void)orderByDescending:(NSString *)key;

/**
 *  Add new field to be ascending ordered
 *
 *  @param key Desired field to be ordered ascending
 */
- (void)addAscendingOrder:(NSString *)key;

/**
 *  Add new field to be descending ordered
 *
 *  @param key Desired field to be ordered descending
 */
- (void)addDescendingOrder:(NSString *)key;

/**
 *  Sets MongoDB query expression
 *
 *  @param query MongoDB query
 */
- (void)where:(NSDictionary *)query;

/**
 *  Sets desired fields to be retrieved
 *
 *  @param fields Fields to be retrieved
 */
- (void)setFields:(NSArray *)fields;

/**
 *  Sets a list of authenticators. This works with `KuasarsUser` if you want to retrieve some users 
 *  known by their email addresses. You can set authenticators as a list of email addresses.
 *
 *  If you provide some authenticators, then MongoDB expression will be ignored
 *
 *  @param authenticators A list of authenticators to retrieve
 */
- (void)setAuthenticators:(NSArray *)authenticators;

/**
 *  Helper function to parse this query expression
 *
 *  @return Well-formed expression with Query settings
 */
- (NSDictionary *)parseQuery;

@end
