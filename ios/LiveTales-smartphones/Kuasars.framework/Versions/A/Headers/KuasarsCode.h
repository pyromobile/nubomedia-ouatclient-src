//
//  KuasarsCode.h
//  Kuasars
//
//  Created by Javier Cancio on 02/04/14.
//  Copyright (c) 2014 Glass. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KuasarsCode : NSObject

/**
 Makes a GET request in order to executes a function remotely
 @param function Name of the remote function to be executed
 @param paramsList Array with function parameters (if needed)
 @param wait Indicates if the server has to wait until the process is complete. Recommended only for 'hard' operations
 @param completion Block handler with server response
 */
+(void)executeGetFunction:(NSString *)function
                params:(NSArray *)paramsList
           needsToWait:(BOOL)wait
            completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;


/**
 Makes a POST request in order to executes a function remotely
 @param function Name of the remote function to be executed
 @param paramsList Array with function parameters (if needed)
 @param wait Indicates if the server has to wait until the process is complete. Recommended only for 'hard' operations
 @param completion Block handler with server response
 */
+(void)executePostFunction:(NSString *)function
                   params:(NSArray *)paramsList
              needsToWait:(BOOL)wait
               completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

@end
