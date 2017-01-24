//
//  KuasarsPermissions.h
//  Kuasars
//
//  Created by Javier Cancio on 15/10/13.
//  Copyright (c) 2013 Glass. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Read Permissions
 */
typedef enum {
    KuasarsReadPermissionNONE,      // No one has permissions
    KuasarsReadPermissionALL,       // All users can access
    KuasarsReadPermissionANONYMOUS, // Unregistered users access ?
    KuasarsReadPermissionLIST       // Only users which are in the specified list can access
} KuasarsUserReadPermission;

/**
 *  Read/Write Permissions
 */
typedef enum {
    KuasarsWritePermissionNONE,      // No one has permissions
    KuasarsWritePermissionALL,       // All users can access
    KuasarsWritePermissionLIST       // Only users which are in the specified list can access
} KuasarsUserWritePermission;

@interface KuasarsPermissions : NSObject

@property (nonatomic, strong, readonly) NSDictionary *ACL; // Access Control List. It contains all permissions for read, write and admin roles.

/**
 *  Creates new instance from servers response
 *
 *  @param response Kuasars server response
 *
 *  @return New instance of `KuasarsPermissions`
 */
- (KS_INSTANCETYPE)initFromResponse:(NSDictionary *)response;

/**
 *  Sets desired permissions as readable permissions
 *
 *  @param userPermission   Desired readable permissions
 *  @param usersList        List of users to which apply the permissions
 *  @param groups           Group of users to which apply the permissions
 */
- (void)setReadPermissions:(KuasarsUserReadPermission)userPermission usersList:(NSArray *)usersList groupList:(NSArray *)groups;

/**
 *  Sets desired permissions as writable permissions
 *
 *  @param userPermission   Desired writable permissions
 *  @param usersList        List of users to which apply the permissions
 *  @param groups           Group of users to which apply the permissions
 */
- (void)setReadWritePermissions:(KuasarsUserWritePermission)userPermission usersList:(NSArray *)usersList groupList:(NSArray *)groups;

/**
 *  Sets admin permissions to desired users
 *
 *  @param usersList        List of users to which apply admin permissions
 *  @param groups           Group of users to which apply admin permissions
 */
- (void)setAdminPermissionsForUsers:(NSArray *)usersList groupList:(NSArray *)groups;

@end
