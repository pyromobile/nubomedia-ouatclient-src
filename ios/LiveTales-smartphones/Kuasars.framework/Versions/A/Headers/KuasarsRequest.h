//
//  KuasarsRequest.h
//  Kuasars
//
//  Created by Matteo Novelli on 08/10/13.
//  Copyright (c) 2013 Glass. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KuasarsRequest : NSObject

@property (nonatomic) RequestMethod method;
@property (nonatomic) NSString *endPoint;
@property (nonatomic) NSDictionary *body;
@property (nonatomic) NSMutableDictionary *headers;

+ (KuasarsRequest *)requestWithMethod:(RequestMethod)method endPoint:(NSString *)endPoint body:(NSDictionary *)body;

- (id)initWithMethod:(RequestMethod)method endPoint:(NSString *)endPoint body:(NSDictionary *)body;

+ (NSString *)methodToString:(RequestMethod)method;

@end
