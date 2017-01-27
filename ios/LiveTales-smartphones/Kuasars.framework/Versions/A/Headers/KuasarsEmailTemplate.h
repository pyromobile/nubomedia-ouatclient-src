//
//  KuasarsEmailTemplate.h
//  Kuasars
//
//  Created by Javier Cancio on 24/10/13.
//  Copyright (c) 2013 Glass. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Email template used to send emails
 */
@interface KuasarsEmailTemplate : NSObject

///-------------------------------------------
/// @name Accessing Email Templates properties
///-------------------------------------------

/** Email template type, a short description name */
@property (nonatomic, strong, readonly) NSString *type;

/** A list of available languages to use on this template */
@property (nonatomic, strong, readonly) NSArray *languages;


///----------------------------------------------------
/// @name Creating and Initializing new Email Templates
///----------------------------------------------------


/**
 Initializes an existing template with its type and its available languages. Email templates must be created via web, through Kuasars Console. This class is used only to retrieve existing templates from Kuasars servers. Do not use it directly.
 
 @param templateType Template's name
 @param templateLanguages List of available languages on current template
 */
- (KS_INSTANCETYPE)initWithType:(NSString *)templateType andLanguages:(NSArray *)templateLanguages;

@end
