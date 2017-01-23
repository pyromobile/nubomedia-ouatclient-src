//
//  KuasarsEmails.h
//  Kuasars
//
//  Created by Javier Cancio on 22/10/13.
//  Copyright (c) 2013 Glass. All rights reserved.
//

#import "KuasarsObject.h"
#import "KuasarsEmailTemplate.h"

/**
 KuasarsEmails manages the Email system, to retrieve existing templates and send emails to mutiple users
 */
@interface KuasarsEmails : KuasarsObject

/**
 @name Retrieving templates
 */

/**
 Sends email to receivers using a template and language
 
 @param language Language of the template
 @param subject Email's subject
 @param message Email's body message
 @param templateType Template to use
 @param additionalData Dictionary with key-value pair to replace variables with other values
 @param receivers List of addresses you want to send the email
 @param completion Block with server response
 */
+ (void)sendMailWithLanguage:(NSString *)language
                     subject:(NSString *)subject
                     message:(NSString *)message
                templateType:(NSString *)templateType
              additionalData:(NSDictionary *)additionalData
                 toReceivers:(NSArray *)receivers
                  completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

@end
