//
//  FilesHandler.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/13/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilesHandler : NSObject

+ (void)clearFilesInDirectoryPath:(NSString*)path;
+ (void)createDirectoryForPathIfNeeded:(NSString*)path;
+ (void)writeString:(NSString *)contentString toFilePath:(NSString *)filePath;

@end
