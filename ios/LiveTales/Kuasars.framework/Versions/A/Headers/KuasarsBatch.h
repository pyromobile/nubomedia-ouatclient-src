//
//  KuasarsBatch.h
//  Kuasars
//
//  Created by Matteo Novelli on 08/10/13.
//  Copyright (c) 2013 Glass. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KuasarsRequest;

/**
 KuasarsBatch class provides a simple way to perform batch requests.
 */

@interface KuasarsBatch : NSObject

/**
 The array containing all KuasarsRequest objects to be performed.
 */
@property (readonly) NSArray *requests;

/**
 Insert a given KuasarsRequest object at the end of the requests array.
 @param request KuasarsRequest object.
 */
- (void)addRequest:(KuasarsRequest *)request;

/**
 Removes the KuasarsRequest object at given index
 @param index The index from which to remove the object in the array. The value must not exceed the bounds of the array.
 */
- (void)removeRequestAtIndex:(NSUInteger)index;

/**
 Empties the requests array.
 */
- (void)removeAllRequests;

/**
 Perfomrs the requests contained in the requests array.
 @param completion Handler with server response. 
 */
- (void)performRequests:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

@end
