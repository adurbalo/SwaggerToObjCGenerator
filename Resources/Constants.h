//
//  Constants.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/6/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define CLASS_IMPORT_MARKER @"<import_marker>"
#define CLASS_DERECTIVE_DECLARATION_MARKER @"<class_derective_declaration_marker>"
#define CLASS_NAME_MARKER @"<class_name_marker>"
#define SUPERCLASS_NAME_MARKER @"<superclass_name_marker>"
#define CLASS_DECLARATION_MARKER @"<class_declaration_marker>"
#define CLASS_IMPLEMENTATION_MARKER @"<class_implementation_marker>"
#define ABSTRACT_SERVER_API_NAME_MARKER @"<abstract_server_class_name>"



static inline NSString* objC_classNameFromSwaggerType(NSString *swaggerType)
{
    NSString *objCNameClass = nil;
    if ([swaggerType isEqualToString:@"string"]) {
        objCNameClass = @"NSString";
    } else if ([swaggerType isEqualToString:@"array"]) {
        objCNameClass = @"NSArray";
    } else if ([swaggerType isEqualToString:@"object"]) {
        objCNameClass = @"NSDictionary";
    } else if ([swaggerType isEqualToString:@"integer"] || [swaggerType isEqualToString:@"number"] || [swaggerType isEqualToString:@"boolean"]) {
        objCNameClass = @"NSNumber";
    } else {
        NSLog(@"Custom type: %@ ?", swaggerType);
        objCNameClass = swaggerType;
    }
    return objCNameClass;
}

static inline BOOL isCustomClassType(NSString *className)
{
    if (!className) {
        return NO;
    }
    return ![className hasPrefix:@"NS"] && ![className isEqualToString:@"id"];
 }


#endif /* Constants_h */
