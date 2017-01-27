//
//  KObject.h
//  KuasarsCore
//
//  Created by Matteo Novelli on 13/05/13.
//  Copyright (c) 2013 Glass. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KuasarsObject : NSObject

/** Creation date */
@property (nonatomic, readonly) NSTimeInterval createdAt;

/** Last change date */
@property (nonatomic, readonly) NSTimeInterval updatedAt;

/** JSON representation for the application object */
@property (nonatomic, strong, readonly) NSDictionary *info;

@end
