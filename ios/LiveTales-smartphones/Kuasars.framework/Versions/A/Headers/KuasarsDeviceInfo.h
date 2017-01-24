//
//  KuasarsDeviceInfo.h
//  Kuasars
//
//  Created by Javier Cancio on 23/2/15.
//  Copyright (c) 2015 Glass. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KuasarsDeviceInfo : NSObject

+ (NSString *)getCarrierName;

+ (NSString *)getISOCountryCode;

+ (NSString *)getMccMnc;

+ (NSString *)getConnectionType;

+ (NSString *)getNetworkType;

@end
