//
//  KUser.h
//  KuasarsUsers
//
//  Created by Matteo Novelli on 24/05/13.
//  Copyright (c) 2013 Glass. All rights reserved.
//

#import "KuasarsObject.h"

extern NSString * const kRegisterNewMailAuth;
extern NSString * const kResetPassword;
extern NSString * const kEmailAuthenticator;
extern NSString * const kChangeEmail;
extern NSString * const kFacebookAuthenticator;
extern NSString * const kInternalTokenAuthtenticator;

typedef enum {
    KuasarsVerificationCodeTypeRegister,
    KuasarsVerificationCodeTypeUpdateMail,
    KuasarsVerificationCodeTypeResetPassword
} KuasarsVerificationCodeType;

@class KuasarsQueryParams;
@class KuasarsQuery;

/**
 KuasarsUser class is a local representation of a Kuasar user with all its properties. Also provides all methods needed to manage users of your Kuasars applications.
 */

@interface KuasarsUser : KuasarsObject

/** @name User attributes */

/** Unique user framework identifier */
@property (nonatomic, readonly) NSString *ID;

/** Users full name */
@property (nonatomic) NSString *fullName;

/** Users avatar URL */
@property (nonatomic) NSString *avatarUrl;

/** Wildcard field, that could be used by the developer to internal process */
@property (nonatomic) NSMutableDictionary *custom;

/** Object that store application metaData information. Ex appURLs, logoURL...etc */
@property (nonatomic) NSMutableDictionary *metadata;

/** Dictionary which stores all users authenticators */
@property (nonatomic, readonly) NSDictionary *authentication;

/** Access identifier for internal token sessions */
@property (nonatomic, readonly) NSString *internalID;

/** @name Constructors */

/**
 Returns an KuasarsUser object initialized by the JSON object returned by the server.
 
 @param response            Dictionary returned by the server
 @return                    New instance of KuasarsUser
 */
- (KS_INSTANCETYPE)initWithServerResponse:(NSDictionary *)response;

/**
 Returns an KuasarsUser object initialized by email, password and validation code.
 
 @param email               Users email
 @param password            Users password
 @param verificationCode    Validation code provided by Kuasars
 @return                    New instance of KuasarsUser
 
 @discussion                This constructor is used to register a new user by email and password. In order to register an user by email first you have to obtain a validation code using requestVerificationCodeWithEmail:type:completion: method described below. You should have also be taken in consideration that the application allows email athentication.
 */
- (KS_INSTANCETYPE)initWithEmail:(NSString *)email password:(NSString *)password verificationCode:(NSString *)verificationCode;

/**
 Returns an KuasarsUser object initialized by Facebook uid and access token.
 
 @param facebookUID         Users Facebook uid
 @param accessToken         Users Facebook access token
 @return                    New instance of KuasarsUser
 
 @discussion                This constructor is used to register a new user by its own Facebook identifier. In order to register an user by Facebook you should have to be taken into consideration that the application allows Facebook authentication.
 */
- (KS_INSTANCETYPE)initWithFacebookAccount:(NSString *)facebookUID accessToken:(NSString *)accessToken;

/**
 Returns an KuasarsUser object initialized by an internal access token of your application.
 
 @param accessToken         Internal access token for authentication
 @return                    New instance of KuasarsUser
 
 @discussion                This constructor is used to register a new user by your own access token. In order to register an user by access token you should have to be taken into consideration that the application allows internal access token authentication.
 */
- (KS_INSTANCETYPE)initWithInternalToken:(NSString *)accessToken;

/**
 Returns an KuasarsUser object initialized by an internal access token of your application.
 
 @param accessToken         Internal access token for authentication
 @param internalID          Custom identifier for internal token sessions
 @return                    New instance of KuasarsUser
 
 @discussion                This constructor is used to register a new user by your own access token. In order to register an user by access token you should have to be taken into consideration that the application allows internal access token authentication.
 */
- (KS_INSTANCETYPE)initWithInternalToken:(NSString *)accessToken andInternalIdentifier:(NSString *)internalID;

/**
 @name Getting, creating, updating and deleting
 */

/**
 Returns advanced information about a given user
 
 @param userID              User identifier
 @param completion          Handler with server response
 */
+ (void)getUserWithID:(NSString *)userID completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 Registers a new user into current application.
 
 @param completion          Handler with server response

 @discussion                In order to register new user into current application first you must create an instance of KuasarsUser classusing the correct constructor depending on the allowed authenticators of each application. There are three constructors availables for easy one step initialization:
    - initWithEmailAuth:password:validationCode:
    - initWithFacebookAuth:accessToken:
    - initWithInternalTokenAuth:
 */
- (void)save:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 Signs up and makes a login request for actual user.
 
 @param completion          Handler with server response
 
 @discussion                In order to register new user into current application first you must create an instance of KuasarsUser classusing the correct constructor depending on the allowed authenticators of each application. There are three constructors availables for easy one step initialization:
 - initWithEmailAuth:password:validationCode:
 - initWithFacebookAuth:accessToken:
 - initWithInternalTokenAuth:
 */
- (void)saveAndLogin:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 Replaces user's advanced information.
 
 @param completion          Handler with server response
 
 @discussion                In order to update existing users first you must get it from the server using methods described in this document.
 */
- (void)replace:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 Updates user's data to the latest available info
 
 @param completion          Handler with server response
 */
- (void)refreshUserData:(NSString *)userid completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 Removes user from Kuasars server.
 
 @param completion          Block with server response
 
 @discussion                In order to remove existing users first you must get it from the server using methods described in this document.
 */
- (void)delete:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 @name Updating authentication detains
 */

/**
 Replaces users Facebook authentication details.
 
 @param facebookUID         Users Facebook uid
 @param accessToken         Users Facebook access token
 @param completion          Block with server response
 */
- (void)updateFacebookAccount:(NSString *)facebookUID accessToken:(NSString *)accessToken completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 Replaces users email authentication details.
 
 @param email               Users email
 @param password            Users password
 @param verificationCode    Verification code provided by Kuasars
 @param completion          Block with server response
 */
- (void)updateEmail:(NSString *)email password:(NSString *)password verificationCode:(NSString *)verificationCode completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 Changes users password for email authentication.
 
 @param newPassword         Users new password
 @param oldPassword         Users old password
 @param completion          Block with server response
 */
- (void)changePassword:(NSString *)newPassword oldPassword:(NSString *)oldPassword completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 Replaces users internal token authentication details.
 
 @param accessToken         Internal access token for authentication
 @param internalID          Custom identifier for internal token sessions
 @param completion          Block with server response
 */
- (void)updateInternalToken:(NSString *)accessToken internalTokenID:(NSString *)internalID completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;



/**
 Get the internal token two of the current user.
 
 @param completion          Block with server response
 */
- (void)getIntenalTokenTwo:(KResponseBlock)completion;


/**
 Get the internal token two of the current user.
 
 @param completion          Block with server response
 */
+ (void)getInternalTokenTwoForUser:(NSString *)userid completion:(KResponseBlock)completion;

/**
 Resets users password for email authentication in case that he forget it.
 
 @param newPassword         Users new password
 @param email               Users email
 @param verificationCode    Verification code provided by Kuasars
 @param completion          Block with server response
 */
+ (void)resetPassword:(NSString *)newPassword email:(NSString *)email verificationCode:(NSString *)verificationCode completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 @name Helpers
 */

/**
 Sends an email containing the verification code needed for registry and password reset.
 
 @param email               Users email
 @param type                Type of verification code requested
 @param completion          Block with server response

 @discussion                Verification code types are enumerated and the available option are:
    Register new email (KuasarsVerificationCodeTypeRegister)
    Reset password (KuasarsVerificationCodeTypeResetPassword)
 */
+ (void)requestVerificationCodeWithEmail:(NSString *)email type:(KuasarsVerificationCodeType)type completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;


/**
 Performs a mongoDB query for searching specified users by email authenticator.
 
 @param query               MongoDB expression
 @param params              Parameters for pagination and order filters
 @param completion          Block with array of returned users as KuasarsResponse content data
 */
+ (void)queryByEmail:(NSDictionary *)query queryParams:(KuasarsQueryParams *)params completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion __deprecated;

/**
 Performs a mongoDB query for searching specified users by facebook authenticator.
 
 @param query               MongoDB expression
 @param params              Parameters for pagination and order filters
 @param completion          Block with array of returned users as KuasarsResponse content data
 */
+ (void)queryByFacebook:(NSDictionary *)query queryParams:(KuasarsQueryParams *)params completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion __deprecated;


/**
 Performs a mongoDB query for searching specified users by email authenticator.
 
 @param query               Constructed and configured `KuasarsQuery` object
 @param completion          Block with array of returned users as KuasarsResponse content data
 */
+ (void)queryByEmail:(KuasarsQuery *)query completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;


/**
 Performs a mongoDB query for searching specified users by facebook authenticator.
 
 @param query               Constructed and configured `KuasarsQuery` object
 @param completion          Block with array of returned users as KuasarsResponse content data
 */
+ (void)queryByFacebook:(KuasarsQuery *)query completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;


@end
