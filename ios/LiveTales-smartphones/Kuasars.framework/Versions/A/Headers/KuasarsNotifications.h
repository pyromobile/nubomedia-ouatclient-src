//
//  KuasarsNotifications.h
//  Kuasars
//
//  Created by Javier Cancio on 21/11/13.
//  Copyright (c) 2013 Glass. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 
 `KuasarsNotifications` class is used to send notification messages.
 
 In order to get Notifications working properly, you must upload your .p12 exported file to Kuasars servers, using Kuasars console tool, and provide the password you used at exporting file.
 */

@interface KuasarsNotifications : NSObject

///-------------------------------------------------
/// @name Accessing Kuasars Notifications properties
///-------------------------------------------------


/**
 *  Message to be sent. This message will be shown as notification message
 */
@property NSString *message;

/**
 * List of users that will recive this notification
 */
@property (readonly) NSMutableArray *users;

/**
 * List of notification reports. When new notification is sent, a report ID is sent back on block code. With this report, you can
 * check on Kuasars console if notification sents without any error. Each report register has a report ID, message sent, list of
 * users and a timestamp.
 */
@property (readonly) NSMutableArray *reports;

/**
 * iOS >= 8 Feature. This will include custom string as notification category. 
 * See also: https://developer.apple.com/library/mac/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/IPhoneOSClientImp.html#//apple_ref/doc/uid/TP40008194-CH103-SW26
 */
@property (readonly) NSString *category;

/**
 * Additional data to be added to this notification. 
 */
@property (readonly) NSDictionary *customData;

/**
 * Number to be shown as badge counter on app's icon
 */
@property (readonly) int badgeCounter;


///------------------------------------------------------
/// @name Creating and Initializing Notifications Objects
///------------------------------------------------------

/**
 *  Creates and returns a notification object containing the specified message and specified list of users
 *
 *  Usage example:
 *
 *  @param message Message to send
 *  @param users   List of users that will receive the notification
 *
 *  @return A notification containing the message and the list of users
 */
+ (KS_INSTANCETYPE)notificationWithMessage:(NSString *)message users:(NSArray *)users;


/**
 *  Initializes a newly allocated notification with the specified message and sepcified list of users
 *
 *  @param message Message to send
 *  @param users   List of users that will receive the notification
 *
 *  @return A notification initialized to contain the specified message and the list of users
 */
- (KS_INSTANCETYPE)initWithMessage:(NSString *)message toUsers:(NSArray *)users;


/**
 *  Initializes a newly allocated notification with the specified message and sepcified list of users
 *
 *  @param message Message to send
 *  @param users        List of users that will receive the notification
 *  @param category     iOS >= 8 Feature. This will include custom string as notification category.
 *  @param custom       Additional data to be added to this notification
 *  @param badge        Number to be shown as badge counter on app's icon
 *
 *  @return A notification initialized to contain the specified message and the list of users
 */
- (KS_INSTANCETYPE)initWithMessage:(NSString *)message
                           toUsers:(NSArray *)users
                          category:(NSString *)category
                        customData:(NSDictionary *)custom
                      badgeCounter:(int)badge;
/**
 *  Inserts a given user at the end of users list
 *
 *  @param user The user to add to the end of users list
 */
- (void)addUser:(NSString *)user;


/**
 *  Removes the given user from the users list
 *
 *  @param user The user to be removed
 *
 *  @return Returns YES if given user exists on users list and is removed, returns NO otherwise
 */
- (BOOL)removeUser:(NSString *)user;


///------------------------------------
/// @name Sending Notification Messages
///------------------------------------

/**
 *  Sends the notification
 *
 *  @param completion Block response with reportId value on `KuasarsResponse` object and error info
 *  <pre><code>
 *  KuasarsNotifications *notifications = [KuasarsNotifications notificationWithMessage@"Just for testing" users:@[@"1234"]];
 *
 *      [notifications send:^(KuasarsResponse *object, KuasarsError *error) {
 *       ...
 *      }];
 *  </code></pre>
 *
 */
- (void)send:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;


@end
