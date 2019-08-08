//
// Created by xuxune on 2019-08-08.
// Copyright (c) 2019 hxy-tech.com. All rights reserved.
//

#import "NSObject+HXYModel.h"
#import "HXYClassInfo.h"
#import <objc/message.h>

#ifndef force_inline
#define force_inline __inline__ __attribute__((always_inline))
#endif

typedef NS_ENUM(NSUInteger, HXYEncodingNSType) {
    HXYEncodingTypeNSUnknown = 0,
    HXYEncodingTypeNSString,
    HXYEncodingTypeNSMutableString,
    HXYEncodingTypeNSValue,
    HXYEncodingTypeNSNumber,
    HXYEncodingTypeNSDecimalNumber,
    HXYEncodingTypeNSData,
    HXYEncodingTypeNSMutableData,
    HXYEncodingTypeNSDate,
    HXYEncodingTypeNSURL,
    HXYEncodingTypeNSArray,
    HXYEncodingTypeNSMutableArray,
    HXYEncodingTypeNSDictionary,
    HXYEncodingTypeNSMutableDictionary,
    HXYEncodingTypeNSSet,
    HXYEncodingTypeNSMutableSet,
};

static force_inline HXYEncodingNSType HXYClassGetNSType(Class cls) {
    if (!cls) {
        return HXYEncodingTypeNSUnknown;
    }
    if ([cls isSubclassOfClass:[NSMutableString class]]) {
        return HXYEncodingTypeNSMutableString;
    }
    if ([cls isSubclassOfClass:[NSString class]]) {
        return HXYEncodingTypeNSString;
    }
    if ([cls isSubclassOfClass:[NSDecimalNumber class]]) {
        return HXYEncodingTypeNSDecimalNumber;
    }
    if ([cls isSubclassOfClass:[NSNumber class]]) {
        return HXYEncodingTypeNSNumber;
    }
    if ([cls isSubclassOfClass:[NSValue class]]) {
        return HXYEncodingTypeNSValue;
    }
    if ([cls isSubclassOfClass:[NSMutableData class]]) {
        return HXYEncodingTypeNSMutableData;
    }
    if ([cls isSubclassOfClass:[NSData class]]) {
        return HXYEncodingTypeNSData;
    }
    if ([cls isSubclassOfClass:[NSDate class]]) {
        return HXYEncodingTypeNSDate;
    }
    if ([cls isSubclassOfClass:[NSURL class]]) {
        return HXYEncodingTypeNSURL;
    }
    if ([cls isSubclassOfClass:[NSMutableArray class]]) {
        return HXYEncodingTypeNSMutableArray;
    }
    if ([cls isSubclassOfClass:[NSArray class]]) {
        return HXYEncodingTypeNSArray;
    }
    if ([cls isSubclassOfClass:[NSMutableDictionary class]]) {
        return HXYEncodingTypeNSMutableDictionary;
    }
    if ([cls isSubclassOfClass:[NSDictionary class]]) {
        return HXYEncodingTypeNSDictionary;
    }
    if ([cls isSubclassOfClass:[NSMutableSet class]]) {
        return HXYEncodingTypeNSMutableSet;
    }
    if ([cls isSubclassOfClass:[NSSet class]]) {
        return HXYEncodingTypeNSSet;
    }
    return HXYEncodingTypeNSUnknown;
}

static force_inline BOOL HXYEncodingTypeIsCNumber(YYEncodingType type) {
    switch (type & YYEncodingTypeMask) {
        case YYEncodingTypeBool:
        case YYEncodingTypeInt8:
        case YYEncodingTypeUInt8:
        case YYEncodingTypeInt16:
        case YYEncodingTypeUInt16:
        case YYEncodingTypeInt32:
        case YYEncodingTypeUInt32:
        case YYEncodingTypeInt64:
        case YYEncodingTypeUInt64:
        case YYEncodingTypeFloat:
        case YYEncodingTypeDouble:
        case YYEncodingTypeLongDouble:
            return YES;
        default:
            return NO;
    }
}

static force_inline NSNumber *HXYNSNumberCreateFromID(id value) {
    static NSCharacterSet *dot;
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
        dic = @{
                @"TRUE" : @(YES),
                @"True" : @(YES),
                @"true" : @(YES),
                @"FALSE" : @(NO),
                @"False" : @(NO),
                @"false" : @(NO),
                @"YES" : @(YES),
                @"Yes" : @(YES),
                @"yes" : @(YES),
                @"NO" : @(NO),
                @"No" : @(NO),
                @"no" : @(NO),
                @"NIL" : (id)kCFNull,
                @"Nil" : (id)kCFNull,
                @"nil" : (id)kCFNull,
                @"NULL" : (id)kCFNull,
                @"Null" : (id)kCFNull,
                @"null" : (id)kCFNull,
                @"(NULL)" : (id)kCFNull,
                @"(Null)" : (id)kCFNull,
                @"(null)" : (id)kCFNull,
                @"<NULL>" : (id)kCFNull,
                @"<Null>" : (id)kCFNull,
                @"<null>" : (id)kCFNull
        };
    });
    if (!value || value == (id)kCFNull) {
        return nil;
    }

    if ([value isKindOfClass:[NSNumber class]]) {
        return value;
    }

    if ([value isKindOfClass:[NSString class]]) {
        NSNumber *num = dic[value];
        if (num) {
            if (num == (id)kCFNull) {
                return nil;
            }
            return num;
        }
        if ([(NSString *)value rangeOfCharacterFromSet:dot].location != NSNotFound) {
            const char *cstring = ((NSString *)value).UTF8String;
            if (!cstring) {
                return nil;
            }
            double num = atof(cstring);
            if (isnan(num) || isinf(num)) {
                return nil;
            }
            return @(num);
        } else {
            const char *cstring = ((NSString *)value).UTF8String;
            if (!cstring) {
                return nil;
            }
            return @(atoll(cstring));
        }

    }
    return nil;
}

static force_inline NSDate *HXYNSDateFromString(NSString *string) {
    typedef NSDate* (^HXYNSDateParseBlock)(NSString *string);
#define kParserNum 34
    static HXYNSDateParseBlock blocks[kParserNum + 1] = {0};
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        {
            /*
             2014-01-20  // Google
             */
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter.dateFormat = @"yyyy-MM-dd";
            blocks[10] = ^(NSString *string) { return [formatter dateFromString:string]; };
        }

        {
            /*
             2014-01-20 12:24:48
             2014-01-20T12:24:48   // Google
             2014-01-20 12:24:48.000
             2014-01-20T12:24:48.000
             */
            NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
            formatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter1.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter1.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";

            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter2.dateFormat = @"yyyy-MM-dd HH:mm:ss";

            NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
            formatter3.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter3.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter3.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS";

            NSDateFormatter *formatter4 = [[NSDateFormatter alloc] init];
            formatter4.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter4.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter4.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";

            blocks[19] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter1 dateFromString:string];
                } else {
                    return [formatter2 dateFromString:string];
                }
            };

            blocks[23] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter3 dateFromString:string];
                } else {
                    return [formatter4 dateFromString:string];
                }
            };
        }

        {
            /*
             2014-01-20T12:24:48Z        // Github, Apple
             2014-01-20T12:24:48+0800    // Facebook
             2014-01-20T12:24:48+12:00   // Google
             2014-01-20T12:24:48.000Z
             2014-01-20T12:24:48.000+0800
             2014-01-20T12:24:48.000+12:00
             */
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";

            NSDateFormatter *formatter2 = [NSDateFormatter new];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";

            blocks[20] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[24] = ^(NSString *string) { return [formatter dateFromString:string]?: [formatter2 dateFromString:string]; };
            blocks[25] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[28] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
            blocks[29] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
        }

        {
            /*
             Fri Sep 04 00:12:21 +0800 2015 // Weibo, Twitter
             Fri Sep 04 00:12:21.000 +0800 2015
             */
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";

            NSDateFormatter *formatter2 = [NSDateFormatter new];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.dateFormat = @"EEE MMM dd HH:mm:ss.SSS Z yyyy";

            blocks[30] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[34] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
        }
    });
    if (!string) return nil;
    if (string.length > kParserNum) return nil;
    HXYNSDateParseBlock parser = blocks[string.length];
    if (!parser) return nil;
    return parser(string);
#undef kParserNum
}

static force_inline Class HXYNSBlockClass() {
    static Class cls;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void (^block)(void) = ^{
        };
        cls = [(NSObject *)block class];
        while (class_getSuperclass(cls) != [NSObject class]) {
            cls = class_getSuperclass(cls);
        }
    });
    return cls;
}

static force_inline NSDateFormatter *HXYISODateFormatter() {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    });
    return formatter;
}



@implementation NSObject(HXYModel)


@end