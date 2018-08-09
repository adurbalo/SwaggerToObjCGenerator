//
//  FilesHandler.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/13/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "FilesHandler.h"
#import "NSError+Extension.h"
#import "Constants.h"

@implementation FilesHandler

+ (void)clearFilesInDirectoryPath:(NSString*)path
{
    NSDirectoryEnumerator* en = [[NSFileManager defaultManager] enumeratorAtPath:path];
    NSError* err = nil;
    BOOL res = NO;
    
    NSString* file;
    while (file = [en nextObject]) {
        res = [[NSFileManager defaultManager] removeItemAtPath:[path stringByAppendingPathComponent:file] error:&err];
        if (!res && err) {
            [err terminate];
        }
    }
}

+ (void)createDirectoryForPathIfNeeded:(NSString*)path
{
    BOOL isDirectory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
        NSError* error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            [error terminate];
        }
    }
}

+ (void)writeString:(NSString *)contentString toFilePath:(NSString *)filePath
{
    if (!contentString) {
        return;
    }
    
    NSError *error = nil;
    [contentString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        [error terminate];
    } else {
        NSString *message = [NSString stringWithFormat:@"%@ generated ✅", [filePath lastPathComponent]];
        notifyLog(message);
        NSLog(@"%@", message);
    };
}

@end
