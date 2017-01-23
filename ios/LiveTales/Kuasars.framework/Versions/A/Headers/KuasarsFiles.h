//
//  KuasarsFiles.h
//  Kuasars
//
//  Created by Javier Cancio on 02/10/13.
//  Copyright (c) 2013 Glass. All rights reserved.
//

#import "KuasarsObject.h"
#import "KuasarsPermissions.h"

/**
 *  File objects are used to manage application files on Kuasars.
 */
@interface KuasarsFiles :KuasarsObject

///--------------------------------------
/// @name Creating App and Users Folders
///--------------------------------------

/**
 *  Creates new folder at specific path
 *
 *  @param path             Path where new folder will be created. If parent folders don't exist the will be created
 *  @param completion       Block with server response
 */
+ (void)createFolder:(NSString *)path completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;


/**
 *  Lists the content of a folder
 *
 *  @param path             Path which you want to get the content
 *  @param completion       Block with server response
 */
+ (void)readFolder:(NSString *)path completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;


/**
 *  Uploads data file to remote path
 *
 *  @param file             File to be uploaded
 *  @param path             Remote path where file will be uploaded. This will be the container folder, do not include filename
 *  @param fileName         Name of the file to be stored (with file extension)
 *  @param mimeType         Mimetype of the file. Use `mimeTypeForFileAtPath:` to retrieve the correct mimetype
 *  @param completion       Block with server response
 */
+ (void)uploadFile:(NSData *)file path:(NSString *)path fileName:(NSString *)fileName mimeType:(NSString *)mimeType completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;


/**
 *  Deletes file or folder
 *
 *  @param path             Full path file or folder to be removed. If folder is specified, all of its content will be removed as well
 *  @param completion       Block with server response
 */
+ (void)deleteAtPath:(NSString *)path completion:(KResponseBlock)completion;

/**
 *  Downloads a file
 *
 *  @param path             Full path to file, including it's extension
 *  @param completion       Block with server response. The `file` NSData object contains downloaded file
 */
+ (void)downloadFile:(NSString *)path completion:(void(^)(NSData* file, KuasarsError* error))completion;

/**
 *  Retrieves the ACL's premissions for the given folder or file
 *
 *  @param path             Path to folder or file
 *  @param completion       Block with server response
 */
+ (void)getACL:(NSString *)path completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;

/**
 *  Updates the ACL permissions for given path or file
 *
 *  @param newPermissions   `KuasarsPermissions` object to replace the current permissions at given path
 *  @param path             Path to folder or file which permissions will be updated
 *  @param completion       Block with server response. This response contains the current updated permissions for given path
 */
+ (void)updatePermissions:(KuasarsPermissions *)newPermissions path:(NSString *)path completion:(void(^)(KuasarsResponse *object, KuasarsError *error))completion;


///------------------------------
/// @name Getting Files mimetype
///------------------------------

/**
 Returns the mimetype of the specified file.
 
 @param path Path to file, it must contain absolute path and filename at the end. This must to be a LOCAL path.
*/
+ (NSString*)mimeTypeForFileAtPath:(NSString *)path;

@end