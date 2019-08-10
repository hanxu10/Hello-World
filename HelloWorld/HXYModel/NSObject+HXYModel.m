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

static force_inline BOOL HXYEncodingTypeIsCNumber(HXYEncodingType type) {
    switch (type & HXYEncodingTypeMask) {
        case HXYEncodingTypeBool:
        case HXYEncodingTypeInt8:
        case HXYEncodingTypeUInt8:
        case HXYEncodingTypeInt16:
        case HXYEncodingTypeUInt16:
        case HXYEncodingTypeInt32:
        case HXYEncodingTypeUInt32:
        case HXYEncodingTypeInt64:
        case HXYEncodingTypeUInt64:
        case HXYEncodingTypeFloat:
        case HXYEncodingTypeDouble:
        case HXYEncodingTypeLongDouble:
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
    typedef NSDate *(^HXYNSDateParseBlock)(NSString *string);
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
            blocks[10] = ^(NSString *string) {
                return [formatter dateFromString:string];
            };
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

            blocks[20] = ^(NSString *string) {
                return [formatter dateFromString:string];
            };
            blocks[24] = ^(NSString *string) {
                return [formatter dateFromString:string] ?: [formatter2 dateFromString:string];
            };
            blocks[25] = ^(NSString *string) {
                return [formatter dateFromString:string];
            };
            blocks[28] = ^(NSString *string) {
                return [formatter2 dateFromString:string];
            };
            blocks[29] = ^(NSString *string) {
                return [formatter2 dateFromString:string];
            };
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

            blocks[30] = ^(NSString *string) {
                return [formatter dateFromString:string];
            };
            blocks[34] = ^(NSString *string) {
                return [formatter2 dateFromString:string];
            };
        }
    });
    if (!string) {
        return nil;
    }
    if (string.length > kParserNum) {
        return nil;
    }
    HXYNSDateParseBlock parser = blocks[string.length];
    if (!parser) {
        return nil;
    }
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

static force_inline id HXYValueForKeyPath(NSDictionary *dic, NSArray *keyPaths) {
    id value = nil;
    for (NSUInteger i = 0, max = keyPaths.count; i < max; ++i) {
        value = dic[keyPaths[i]];
        if (i + 1 < max) {
            if ([value isKindOfClass:[NSDictionary class]]) {
                dic = value;
            } else {
                return nil;
            }
        }
    }
    return value;
}

static force_inline id HXYValueForMultiKeys(NSDictionary *dic, NSArray *multiKeys) {
    id value = nil;
    for (id key in multiKeys) {
        if ([key isKindOfClass:[NSString class]]) {
            value = dic[key];
            if (value) {
                break;
            }
        } else {
            value = HXYValueForKeyPath(dic, (NSArray *)key);
            if (value) {
                break;
            }
        }
    }
    return value;
}

@interface _HXYModelPropertyMeta : NSObject {
@package
    HXYEncodingType _type;
    HXYEncodingNSType _nsType;
    BOOL _isCNumber;
    Class _cls;
    Class _genericCls;
    SEL _getter;
    SEL _setter;
    BOOL _isKVCCompatible;
    BOOL _isStructAvailableForKeyedArchiver;
    BOOL _hasCustomClassFromDictionary;

    NSString *_mappedToKey;
    NSArray *_mappedToKeyPath;
    NSArray *_mappedToKeyArray;
    HXYClassPropertyInfo *_info;
    _HXYModelPropertyMeta *_next;
    NSString *_name;
}
@end

@implementation _HXYModelPropertyMeta

+ (instancetype)metaWithClassInfo:(HXYClassInfo *)classInfo propertyInfo:(HXYClassPropertyInfo *)propertyInfo generic:(Class)generic {
    if (!generic && propertyInfo.protocols) {
        for (NSString *protocol in propertyInfo.protocols) {
            Class cls = objc_getClass(protocol.UTF8String);
            if (cls) {
                generic = cls;
                break;
            }
        }
    }

    _HXYModelPropertyMeta *meta = [[self alloc] init];
    meta->_name = propertyInfo.name;
    meta->_type = propertyInfo.type;
    meta->_info = propertyInfo;
    meta->_genericCls = generic;

    if ((meta->_type & HXYEncodingTypeMask) == HXYEncodingTypeObject) {
        meta->_nsType = HXYClassGetNSType(propertyInfo.cls);
    } else {
        meta->_isCNumber = HXYEncodingTypeIsCNumber(meta->_type);
    }

    if ((meta->_type & HXYEncodingTypeMask) == HXYEncodingTypeStruct) {
        static NSSet *types = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSMutableSet *set = [NSMutableSet set];
            [set addObject:@"{CGSize=ff}"];
            [set addObject:@"{CGPoint=ff}"];
            [set addObject:@"{CGRect={CGPoint=ff}{CGSize=ff}"];
            [set addObject:@"{CGAffineTransform=ffffff}"];
            [set addObject:@"{UIEdgeInsets=ffff}"];
            [set addObject:@"{UIOffset=ff}"];

            [set addObject:@"{CGSize=dd}"];
            [set addObject:@"{CGPoint=dd}"];
            [set addObject:@"{CGRect={CGPoint=dd}{CGSize=dd}}"];
            [set addObject:@"{CGAffineTransform=dddddd}"];
            [set addObject:@"{UIEdgeInsets=dddd}"];
            [set addObject:@"{UIOffset=dd}"];

            types = set;
        });
        if ([types containsObject:propertyInfo.typeEncoding]) {
            meta->_isStructAvailableForKeyedArchiver = YES;
        }
    }
    meta->_cls = propertyInfo.cls;

    if (generic) {
        meta->_hasCustomClassFromDictionary = [generic respondsToSelector:@selector(modelCustomClassForDictionary:)];
    } else if (meta->_cls && meta->_nsType == HXYEncodingTypeNSUnknown) {
        meta->_hasCustomClassFromDictionary = [meta->_cls respondsToSelector:@selector(modelCustomClassForDictionary:)];
    }

    if (propertyInfo.getter) {
        if ([classInfo.cls instancesRespondToSelector:propertyInfo.getter]) {
            meta->_getter = propertyInfo.getter;
        }
    }
    if (propertyInfo.setter) {
        if ([classInfo.cls instancesRespondToSelector:propertyInfo.setter]) {
            meta->_setter = propertyInfo.setter;
        }
    }

    if (meta->_getter && meta->_setter) {
        switch (meta->_type & HXYEncodingTypeMask) {
            case HXYEncodingTypeBool:
            case HXYEncodingTypeInt8:
            case HXYEncodingTypeUInt8:
            case HXYEncodingTypeInt16:
            case HXYEncodingTypeUInt16:
            case HXYEncodingTypeInt32:
            case HXYEncodingTypeUInt32:
            case HXYEncodingTypeInt64:
            case HXYEncodingTypeUInt64:
            case HXYEncodingTypeFloat:
            case HXYEncodingTypeDouble:
            case HXYEncodingTypeObject:
            case HXYEncodingTypeClass:
            case HXYEncodingTypeBlock:
            case HXYEncodingTypeStruct:
            case HXYEncodingTypeUnion: {
                meta->_isKVCCompatible = YES;
            }
                break;
            default:
                break;
        }
    }

    return meta;
}
@end

@interface _HXYModelMeta : NSObject {
    HXYClassInfo *_classInfo;
    NSDictionary *_mapper;
    NSArray *_allPropertyMetas;
    NSArray *_keyPathPropertyMetas;
    NSArray *_multiKeysPropertyMetas;
    NSUInteger _keyMappedCount;
    HXYEncodingNSType _nsType;

    BOOL _hasCustomWillTransformFromDictionary;
    BOOL _hasCustomTransformFromDictionary;
    BOOL _hasCustomTransformToDictionary;
    BOOL _hasCustomClassFromDictionary;
}

@end

@implementation _HXYModelMeta

- (instancetype)initWithClass:(Class)cls {
    HXYClassInfo *classInfo = [HXYClassInfo classInfoWithClass:cls];
    if (!classInfo) {
        return nil;
    }
    self = [super init];

    NSSet *blackList = nil;
    if ([cls respondsToSelector:@selector(modelPropertyBlacklist)]) {
        NSArray *properties = [(id <HXYModel>)cls modelPropertyBlacklist];
        if (properties) {
            blackList = [NSSet setWithArray:properties];
        }
    }

    NSSet *whiteList = nil;
    if ([cls respondsToSelector:@selector(modelPropertyWhiteList)]) {
        NSArray *properties = [(id <HXYModel>)cls modelPropertyWhiteList];
        if (properties) {
            whiteList = [NSSet setWithArray:properties];
        }
    }

    NSDictionary *genericMapper = nil;
    if ([cls respondsToSelector:@selector(modelContainerPropertyGenericClass)]) {
        genericMapper = [(id <HXYModel>)cls modelContainerPropertyGenericClass];
        if (genericMapper) {
            NSMutableDictionary *tmp = [NSMutableDictionary dictionary];
            [genericMapper enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if (![key isKindOfClass:[NSString class]]) {
                    return;
                }
                Class meta = object_getClass(obj);
                if (!meta) {
                    return;
                }
                if (class_isMetaClass(meta)) {
                    tmp[key] = obj;
                } else if ([obj isKindOfClass:[NSString class]]) {
                    Class cls = NSClassFromString(obj);
                    if (cls) {
                        tmp[key] = cls;
                    }
                }
            }];
            genericMapper = tmp;
        }
    }

    NSMutableDictionary *allPropertyMetas = [NSMutableDictionary dictionary];
    HXYClassInfo *curClassInfo = classInfo;
    while (curClassInfo && curClassInfo.superCls != nil) {
        for (HXYClassPropertyInfo *propertyInfo in curClassInfo.propertyInfos.allValues) {
            if (!propertyInfo.name) {
                continue;
            }
            if (blackList && [blackList containsObject:propertyInfo.name]) {
                continue;
            }
            if (whiteList && ![whiteList containsObject:propertyInfo.name]) {
                continue;
            }

            _HXYModelPropertyMeta *meta = [_HXYModelPropertyMeta metaWithClassInfo:classInfo propertyInfo:propertyInfo generic:genericMapper[propertyInfo.name]];
            if (!meta || !meta->_name) {
                continue;
            }
            if (!meta->_getter || !meta->_setter) {
                continue;
            }
            if (allPropertyMetas[meta->_name]) {
                continue;
            }
            allPropertyMetas[meta->_name] = meta;
        }
        curClassInfo = curClassInfo.superClassInfo;
    }
    if (allPropertyMetas.count) {
        _allPropertyMetas = allPropertyMetas.allValues.copy;
    }

    NSMutableDictionary *mapper = [NSMutableDictionary dictionary];
    NSMutableArray *keyPathPropertyMetas = [NSMutableArray array];
    NSMutableArray *multiKeysPropertyMetas = [NSMutableArray array];

    if ([cls respondsToSelector:@selector(modelCustomPropertyMapper)]) {
        NSDictionary *customMapper = [(id <HXYModel>)cls modelCustomPropertyMapper];
        [customMapper enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, NSString *mappedToKey, BOOL *stop) {
            _HXYModelPropertyMeta *propertyMeta = allPropertyMetas[propertyName];
            if (!propertyMeta) {
                return;
            }
            [allPropertyMetas removeObjectForKey:propertyName];

            if ([mappedToKey isKindOfClass:[NSString class]]) {
                if (mappedToKey.length == 0) {
                    return;
                }
                propertyMeta->_mappedToKey = mappedToKey;
                NSArray *keyPath = [mappedToKey componentsSeparatedByString:@"."];
                for (NSString *onePath in keyPath) {
                    if (onePath.length == 0) {
                        NSMutableArray *tmp = keyPath.mutableCopy;
                        [tmp removeObject:@""];
                        keyPath = tmp;
                        break;
                    }
                }
                if (keyPath.count > 1) {
                    propertyMeta->_mappedToKeyPath = keyPath;
                    [keyPathPropertyMetas addObject:propertyMeta];
                }
                propertyMeta->_next = mapper[mappedToKey] ?: nil;
                mapper[mappedToKey] = propertyMeta;
            } else if ([mappedToKey isKindOfClass:[NSArray class]]) {
                NSMutableArray *mappedToKeyArray = [NSMutableArray array];
                for (NSString *oneKey in (NSArray *)mappedToKey) {
                    if (![oneKey isKindOfClass:[NSString class]]) {
                        continue;
                    }
                    if (oneKey.length == 0) {
                        continue;
                    }

                    NSArray *keyPath = [oneKey componentsSeparatedByString:@"."];
                    if (keyPath.count) {
                        [mappedToKeyArray addObject:keyPath];
                    } else {
                        [mappedToKeyArray addObject:oneKey];
                    }

                    if (!propertyMeta->_mappedToKey) {
                        propertyMeta->_mappedToKey = oneKey;
                        propertyMeta->_mappedToKeyPath = keyPath.count > 1 ? keyPath : nil;
                    }
                }
                if (!propertyMeta->_mappedToKey) {
                    return;
                }

                propertyMeta->_mappedToKeyArray = mappedToKeyArray;
                [multiKeysPropertyMetas addObject:propertyMeta];

                propertyMeta->_next = mapper[mappedToKey] ?: nil;
                mapper[mappedToKey] = propertyMeta;
            }
        }];
    }

    [allPropertyMetas enumerateKeysAndObjectsUsingBlock:^(NSString *name, _HXYModelPropertyMeta *propertyMeta, BOOL *stop) {
        propertyMeta->_mappedToKey = name;
        propertyMeta->_next = mapper[name] ?: nil;
        mapper[name] = propertyMeta;
    }];

    if (mapper.count) {
        _mapper = mapper;
    }

    if (keyPathPropertyMetas) {
        _keyPathPropertyMetas = keyPathPropertyMetas;
    }

    if (multiKeysPropertyMetas) {
        _multiKeysPropertyMetas = multiKeysPropertyMetas;
    }

    _classInfo = classInfo;
    _keyMappedCount = _allPropertyMetas.count;
    _nsType = HXYClassGetNSType(cls);
    _hasCustomWillTransformFromDictionary = ([cls instancesRespondToSelector:@selector(modelCustomWillTransformFromDictionary:)]);
    _hasCustomTransformFromDictionary = ([cls instancesRespondToSelector:@selector(modelCustomTransformFromDictionary:)]);
    _hasCustomTransformToDictionary = ([cls instancesRespondToSelector:@selector(modelCustomTransformToDictionary:)]);
    _hasCustomClassFromDictionary = ([cls respondsToSelector:@selector(modelCustomClassForDictionary:)]);

    return self;
}

+ (instancetype)metaWithClass:(Class)cls {
    if (!cls) {
        return nil;
    }
    static CFMutableDictionaryRef cache;
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        cache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    _HXYModelMeta *meta = CFDictionaryGetValue(cache, (__bridge const void *)(cls));
    dispatch_semaphore_signal(lock);
    if (!meta || meta->_classInfo.needUpdate) {
        meta = [[_HXYModelMeta alloc] initWithClass:cls];
        if (meta) {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(cache, (__bridge const void *)(cls), (__bridge const void *)(meta));
            dispatch_semaphore_signal(lock);
        }
    }
    return meta;
}

@end

static force_inline NSNumber *ModelCreateNumberFromProperty(id model, _HXYModelPropertyMeta *meta) {
    switch (meta->_type & HXYEncodingTypeMask) {
        case HXYEncodingTypeBool: {
            return @(((bool (*)(id, SEL))(void *)objc_msgSend)((id)model, meta->_getter));
        }
        case HXYEncodingTypeInt8: {
            return @(((int8_t (*)(id, SEL))(void *)objc_msgSend)((id)model, meta->_getter));
        }
        case HXYEncodingTypeUInt8: {
            return @(((uint8_t (*)(id, SEL))(void *)objc_msgSend)((id)model, meta->_getter));
        }
        case HXYEncodingTypeInt16: {
            return @(((int16_t (*)(id, SEL))(void *)objc_msgSend)((id)model, meta->_getter));
        }
        case HXYEncodingTypeUInt16: {
            return @(((uint16_t (*)(id, SEL))(void *)objc_msgSend)((id)model, meta->_getter));
        }
        case HXYEncodingTypeInt32: {
            return @(((int32_t (*)(id, SEL))(void *)objc_msgSend)((id)model, meta->_getter));
        }
        case HXYEncodingTypeUInt32: {
            return @(((uint32_t (*)(id, SEL))(void *)objc_msgSend)((id)model, meta->_getter));
        }
        case HXYEncodingTypeInt64: {
            return @(((int64_t (*)(id, SEL))(void *)objc_msgSend)((id)model, meta->_getter));
        }
        case HXYEncodingTypeUInt64: {
            return @(((uint64_t (*)(id, SEL))(void *)objc_msgSend)((id)model, meta->_getter));
        }
        case HXYEncodingTypeFloat: {
            float num = ((float (*)(id, SEL))(void *)objc_msgSend)((id)model, meta->_getter);
            if (isnan(num) || isinf(num)) {
                return nil;
            }
            return @(num);
        }
        case HXYEncodingTypeDouble: {
            double num = ((double (*)(id, SEL))(void *)objc_msgSend)((id)model, meta->_getter);
            if (isnan(num) || isinf(num)) {
                return nil;
            }
            return @(num);
        }
        case HXYEncodingTypeLongDouble: {
            double num = ((long double (*)(id, SEL))(void *)objc_msgSend)((id)model, meta->_getter);
            if (isnan(num) || isinf(num)) {
                return nil;
            }
            return @(num);
        }
        default:
            return nil;
    }
}

static force_inline void ModelSetNumberToProperty(id model, NSNumber *num, _HXYModelPropertyMeta *meta) {
    switch (meta->_type & HXYEncodingTypeMask) {
        case HXYEncodingTypeBool: {
            ((void (*)(id, SEL, bool))(void *)objc_msgSend)((id)model, meta->_setter, num.boolValue);
        }
            break;
        case HXYEncodingTypeInt8: {
            ((void (*)(id, SEL, int8_t))(void *)objc_msgSend)((id)model, meta->_setter, (int8_t)num.charValue);
        }
            break;
        case HXYEncodingTypeUInt8: {
            ((void (*)(id, SEL, uint8_t))(void *)objc_msgSend)((id)model, meta->_setter, (uint8_t)num.unsignedCharValue);
        }
            break;
        case HXYEncodingTypeInt16: {
            ((void (*)(id, SEL, int16_t))(void *)objc_msgSend)((id)model, meta->_setter, (int16_t)num.shortValue);
        }
            break;
        case HXYEncodingTypeUInt16: {
            ((void (*)(id, SEL, uint16_t))(void *)objc_msgSend)((id)model, meta->_setter, (uint16_t)num.unsignedShortValue);
        }
            break;
        case HXYEncodingTypeInt32: {
            ((void (*)(id, SEL, int32_t))(void *)objc_msgSend)((id)model, meta->_setter, (int32_t)num.intValue);
        }
        case HXYEncodingTypeUInt32: {
            ((void (*)(id, SEL, uint32_t))(void *)objc_msgSend)((id)model, meta->_setter, (uint32_t)num.unsignedIntValue);
        }
            break;
        case HXYEncodingTypeInt64: {
            if ([num isKindOfClass:[NSDecimalNumber class]]) {
                ((void (*)(id, SEL, int64_t))(void *)objc_msgSend)((id)model, meta->_setter, (int64_t)num.stringValue.longLongValue);
            } else {
                ((void (*)(id, SEL, uint64_t))(void *)objc_msgSend)((id)model, meta->_setter, (uint64_t)num.longLongValue);
            }
        }
            break;
        case HXYEncodingTypeUInt64: {
            if ([num isKindOfClass:[NSDecimalNumber class]]) {
                ((void (*)(id, SEL, int64_t))(void *)objc_msgSend)((id)model, meta->_setter, (int64_t)num.stringValue.longLongValue);
            } else {
                ((void (*)(id, SEL, uint64_t))(void *)objc_msgSend)((id)model, meta->_setter, (uint64_t)num.unsignedLongLongValue);
            }
        }
            break;
        case HXYEncodingTypeFloat: {
            float f = num.floatValue;
            if (isnan(f) || isinf(f)) {
                f = 0;
            }
            ((void (*)(id, SEL, float))(void *)objc_msgSend)((id)model, meta->_setter, f);
        }
            break;
        case HXYEncodingTypeDouble: {
            double d = num.doubleValue;
            if (isnan(d) || isinf(d)) {
                d = 0;
            }
            ((void (*)(id, SEL, double))(void *)objc_msgSend)((id)model, meta->_setter, d);
        }
            break;
        case HXYEncodingTypeLongDouble: {
            long double d = num.doubleValue;
            if (isnan(d) || isinf(d)) {
                d = 0;
            }
            ((void (*)(id, SEL, long double))(void *)objc_msgSend)((id)model, meta->_setter, (long double)d);
        } // break; commented for code coverage in _next line
        default:
            break;
    }
}

static void ModelSetValueForProperty(id model, id value, _HXYModelPropertyMeta *meta) {
    if (meta->_isCNumber) {
        NSNumber *num = HXYNSNumberCreateFromID(value);
        ModelSetNumberToProperty(model, num, meta);
        if (num) {
            [num class];
        }
    } else if (meta->_nsType) {
        if (value == (id)kCFNull) {
            ((void (*)(id, SEL, id))objc_msgSend)((id)model, meta->_setter, (id)nil);
        } else {
            switch (meta->_nsType) {
                case HXYEncodingTypeNSString:
                case HXYEncodingTypeNSMutableString: {
                    if ([value isKindOfClass:[NSString class]]) {
                        if (meta->_nsType == HXYEncodingTypeNSString) {
                            ((void (*)(id, SEL, id))objc_msgSend)((id)model, meta->_setter, value);
                        } else {
                            ((void (*)(id, SEL, id))objc_msgSend)((id)model, meta->_setter, ((NSString *)value).mutableCopy);
                        }
                    } else if ([value isKindOfClass:[NSNumber class]]) {
                        ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model,
                                meta->_setter,
                                (meta->_nsType == HXYEncodingTypeNSString) ?
                                        ((NSNumber *)value).stringValue :
                                        ((NSNumber *)value).stringValue.mutableCopy);
                    } else if ([value isKindOfClass:[NSData class]]) {
                        NSMutableString *string = [[NSMutableString alloc] initWithData:value encoding:NSUTF8StringEncoding];
                        ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, string);
                    } else if ([value isKindOfClass:[NSURL class]]) {
                        ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model,
                                meta->_setter,
                                (meta->_nsType == HXYEncodingTypeNSString) ?
                                        ((NSURL *)value).absoluteString :
                                        ((NSURL *)value).absoluteString.mutableCopy);
                    } else if ([value isKindOfClass:[NSAttributedString class]]) {
                        ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model,
                                meta->_setter,
                                (meta->_nsType == HXYEncodingTypeNSString) ?
                                        ((NSAttributedString *)value).string :
                                        ((NSAttributedString *)value).string.mutableCopy);
                    }
                }
                    break;

            }
        }
    }

}

@implementation NSObject(HXYModel)


@end






















