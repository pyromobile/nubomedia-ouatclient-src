//
//  KuasarsQueryParams.h
//  Kuasars
//
//  Created by Matteo Novelli on 24/09/13.
//  Copyright (c) 2013 Glass. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Response ordering
 */
typedef enum {
    KuasarsQueryOrderOldAscending,     //  Order results ascending
    KuasarsQueryOrderOldDescending,    //  Order results Descending
    KuasarsQueryOrderOldNone           //  No order particularly is used
} KuasarsQueryOrderOld;

@interface KuasarsQueryParams : NSObject

/**
 *  Index of results pages, start counting by 0
 */
@property (nonatomic, readonly) int pageIndex;

/**
 *  Number of entries to be shown on each page
 */
@property (nonatomic, readonly) int pageSize;

/**
 *  Field name to be used as ordering target
 */
@property (nonatomic, readonly) NSString *orderField;

/**
 *  Order to be used
 */
@property (nonatomic, readonly) KuasarsQueryOrderOld orderType;

/**
 @name Creating Queries
 */

/**
 *  Creates new query
 *
 *  @param pageIndex  Desired index of the query, start counting by 0
 *  @param pageSize   Entries to be shown on each page
 *  @param orderField Field to be used as ordering target
 *  @param type       Order to be used
 *
 *  @return KuasarsQueryParams instance to be passed with some specific requests
 */
- (KS_INSTANCETYPE)initWithPageIndex:(int)pageIndex
               pageSize:(int)pageSize
         withOrderField:(NSString *)orderField
                andType:(KuasarsQueryOrderOld)type;

/**
 *  Changes index and size of the current query instance. You can use this method to change pageIndex value in order to iterate over different pages.
 *
 *  @param pageIndex New page index value
 *  @param pageSize  New page size value
 */
- (void)setPaginationIndex:(int)pageIndex
             withSize:(int)pageSize;

/**
 *  Changes field name and order type
 *
 *  @param orderField New field name
 *  @param order      New order type
 */
- (void)setOrderField:(NSString *)orderField
         forType:(KuasarsQueryOrderOld)order;

/**
 *  Returns current query as string using matrix format
 *
 *  @return String representation of the query parameters
 */
- (NSString *)parseQueryParams;

@end
