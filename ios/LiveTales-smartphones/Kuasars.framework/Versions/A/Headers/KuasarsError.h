//
//  KError.h
//  KuasarsCore
//
//  Created by Matteo Novelli on 13/05/13.
//  Copyright (c) 2013 Glass. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KuasarsError : NSError

/**
 HTTP status code
 */
@property (nonatomic, readonly) int statusCode;

/**
 Error reason
 */
@property (nonatomic, readonly, strong) NSString *statusReason;

/** 
 Error exception raised
 */
@property (nonatomic, readonly, strong) NSString *exception;

/**
 Error full description
 */
@property (nonatomic, readonly, strong) NSString *errorDescription;

/**
 Constructor
 */
-(KS_INSTANCETYPE)initWithErrorCode:(int)code
            statusCode:(int)statusCode
          statusReason:(NSString *)reason
             exception:(NSString *)statusException
   andErrorDescription:(NSString *)description;

/**
 Constructor
 */
-(KS_INSTANCETYPE)initWithErrorCode:(int)code
            statusCode:(int)statusCode
   andErrorDescription:(NSString *)description;

/**
 This constructor parses server response and assing values from it
 */
-(KS_INSTANCETYPE)initWithServerResponse:(NSDictionary *)serverResponse;

/**
 Init with standard NSError
 */
-(KS_INSTANCETYPE)initWithError:(NSError *)error;

@end
