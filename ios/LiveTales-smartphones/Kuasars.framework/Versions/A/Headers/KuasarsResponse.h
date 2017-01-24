//
//  KResponse.h
//  KuasarsCore
//
//  Created by Matteo Novelli on 23/05/13.
//  Copyright (c) 2013 Glass. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KuasarsObject.h"

@interface KuasarsResponse : NSObject

/**
 The status code returned by server
 */
@property (nonatomic, readonly) NSInteger statusCode;

/**
 The list of response objects
 */
@property (nonatomic, readonly, strong) NSArray *contentObjects;

/**
 Initializes an `KResponse` object with the specified status code.
 
 @param code The staus code returned by server.
 
 @return The new instance of KResponse
 */
-(id)initWithCode:(NSInteger)code;

/**
 Initializes an `KResponse` object with the specified status code and returned objects.
 
 @param url The status code returned by server.
 
 @param contentObjects List of objects returned by server.
 
 @return The new instance of KResponse
 */
-(id)initWithCode:(NSInteger)code
       andObjects:(NSArray *)objects;


@end
