//
//  HXYClassInfo.m
//  HelloWorld
//
//  Created by zhangfeng on 2019/8/5.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import "HXYClassInfo.h"

HXYEncodingType HXYEncodingGetType(const char *typeEncoding) {
    char *type = (char *)typeEncoding;
    if (!type) {
        return HXYEncodingTypeUnknown;
    }
    size_t len = strlen(type);
    if (len == 0) {
        return HXYEncodingTypeUnknown;
    }

    HXYEncodingType qualifier = 0;
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case 'r': {
                qualifier |= HXYEncodingTypeQualifierConst;
                ++type;
            }
                break;
            case 'n': {
                qualifier |= HXYEncodingTypeQualifierIn;
                type++;
            }
                break;
            case 'N': {
                qualifier |= HXYEncodingTypeQualifierInout;
                type++;
            }
                break;
            case 'o': {
                qualifier |= HXYEncodingTypeQualifierOut;
                type++;
            }
                break;
            case 'O': {
                qualifier |= HXYEncodingTypeQualifierBycopy;
                type++;
            }
                break;
            case 'R': {
                qualifier |= HXYEncodingTypeQualifierByref;
                type++;
            }
                break;
            case 'V': {
                qualifier |= HXYEncodingTypeQualifierOneway;
                type++;
            }
                break;
            default: {
                prefix = false;
            }
                break;
        }
    }

    len = strlen(type);
    if (len == 0) {
        return HXYEncodingTypeUnknown | qualifier;
    }

    switch (*type) {
        case 'v':
            return HXYEncodingTypeVoid | qualifier;
        case 'B':
            return HXYEncodingTypeBool | qualifier;
        case 'c':
            return HXYEncodingTypeInt8 | qualifier;
        case 'C':
            return HXYEncodingTypeUInt8 | qualifier;
        case 's':
            return HXYEncodingTypeInt16 | qualifier;
        case 'S':
            return HXYEncodingTypeUInt16 | qualifier;
        case 'i':
            return HXYEncodingTypeInt32 | qualifier;
        case 'I':
            return HXYEncodingTypeUInt32 | qualifier;
        case 'l':
            return HXYEncodingTypeInt32 | qualifier;
        case 'L':
            return HXYEncodingTypeUInt32 | qualifier;
        case 'q':
            return HXYEncodingTypeInt64 | qualifier;
        case 'Q':
            return HXYEncodingTypeUInt64 | qualifier;
        case 'f':
            return HXYEncodingTypeFloat | qualifier;
        case 'd':
            return HXYEncodingTypeDouble | qualifier;
        case 'D':
            return HXYEncodingTypeLongDouble | qualifier;
        case '#':
            return HXYEncodingTypeClass | qualifier;
        case ':':
            return HXYEncodingTypeSEL | qualifier;
        case '*':
            return HXYEncodingTypeCString | qualifier;
        case '^':
            return HXYEncodingTypePointer | qualifier;
        case '[':
            return HXYEncodingTypeCArray | qualifier;
        case '(':
            return HXYEncodingTypeUnion | qualifier;
        case '{':
            return HXYEncodingTypeStruct | qualifier;
        case '@': {
            if (len == 2 && *(type + 1) == '?') {
                return HXYEncodingTypeBlock | qualifier;
            } else {
                return HXYEncodingTypeObject | qualifier;
            }
        }
        default:
            return HXYEncodingTypeUnknown | qualifier;
    }
}

@implementation HXYClassIvarInfo

- (instancetype)initWithIvar:(Ivar)ivar {
    if (!ivar) {
        return nil;
    }

    self = [super init];
    if (self) {
        _ivar = ivar;
        const char *name = ivar_getName(ivar);
        if (name) {
            _name = [NSString stringWithUTF8String:name];
        }
        _offset = ivar_getOffset(ivar);
        const char *typeEncoding = ivar_getTypeEncoding(ivar);
        if (typeEncoding) {
            _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
            _type = HXYEncodingGetType(typeEncoding);
        }
    }
    return self;
}

@end

@implementation HXYClassMethodInfo

- (instancetype)initWithMethod:(Method)method {
    if (!method) {
        return nil;
    }
    self = [super init];
    if (self) {
        _method = method;
        _sel = method_getName(method);
        _imp = method_getImplementation(method);
        const char *name = sel_getName(_sel);
        if (name) {
            _name = [NSString stringWithUTF8String:name];
        }
        const char *typeEncoding = method_getTypeEncoding(method);
        if (typeEncoding) {
            _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
        }
        char *returnType = method_copyReturnType(method);
        if (returnType) {
            _returnTypeEncoding = [NSString stringWithUTF8String:returnType];
            free(returnType);
        }
        unsigned int argumentCount = method_getNumberOfArguments(method);
        if (argumentCount > 0) {
            NSMutableArray *argumentTypes = [@[] mutableCopy];
            for (unsigned int i = 0; i < argumentCount; i++) {
                char *argumentType = method_copyArgumentType(method, i);
                NSString *type = argumentType ? [NSString stringWithUTF8String:argumentType] : nil;
                [argumentTypes addObject:(type ?: @"")];
                if (argumentType) {
                    free(argumentType);
                }
            }
            _argumentTypeEncodings = argumentTypes;
        }
    }
    return self;
}

@end

@implementation HXYClassPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property {
    if (!property) {
        return nil;
    }

    self = [super init];
    if (self) {
        _property = property;
        const char *name = property_getName(property);
        if (name) {
            _name = [NSString stringWithUTF8String:name];
        }

        HXYEncodingType type = 0;
        unsigned int attrCount;
        objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
        for (unsigned int i = 0; i < attrCount; i++) {
            switch (attrs[i].name[0]) {
                case 'T': {
                    if (attrs[i].value) {
                        _typeEncoding = [NSString stringWithUTF8String:attrs[i].value];
                        type = HXYEncodingGetType(attrs[i].value);

                        if ((type & HXYEncodingTypeMask) == HXYEncodingTypeObject && _typeEncoding.length) {
                            NSScanner *scanner = [NSScanner scannerWithString:_typeEncoding];
                            if (![scanner scanString:@"@\"" intoString:NULL]) {
                                continue;
                            }

                            NSString *clsName = nil;
                            if ([scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&clsName]) {
                                if (clsName.length) {
                                    _cls = objc_getClass(clsName.UTF8String);
                                }
                            }

                            NSMutableArray *protocols = nil;
                            while ([scanner scanString:@"<" intoString:NULL]) {
                                NSString *protocol = nil;
                                if ([scanner scanUpToString:@">" intoString:&protocol]) {
                                    if (protocol.length) {
                                        if (!protocols) {
                                            protocols = [@[] mutableCopy];
                                        }
                                        [protocols addObject:protocol];
                                    }
                                }
                                [scanner scanString:@">" intoString:NULL];
                            }
                            _protocols = protocols;
                        }
                    }
                }
                    break;
                case 'V': {
                    if (attrs[i].value) {
                        _ivarName = [NSString stringWithUTF8String:attrs[i].value];
                    }
                }
                    break;
                case 'R': {
                    type |= HXYEncodingTypePropertyReadonly;
                }
                    break;
                case 'C': {
                    type |= HXYEncodingTypePropertyCopy;
                }
                    break;
                case '&': {
                    type |= HXYEncodingTypePropertyRetain;
                }
                    break;
                case 'N': {
                    type |= HXYEncodingTypePropertyNonatomic;
                }
                    break;
                case 'D': {
                    type |= HXYEncodingTypePropertyDynamic;
                }
                    break;
                case 'W': {
                    type |= HXYEncodingTypePropertyWeak;
                }
                    break;
                case 'G': {
                    type |= HXYEncodingTypePropertyCustomGetter;
                    if (attrs[i].value) {
                        _getter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                    }
                }
                    break;
                case 'S': {
                    type |= HXYEncodingTypePropertyCustomSetter;
                    if (attrs[i].value) {
                        _setter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                    }
                }
                    break;
                default:
                    break;
            }
        }
        if (attrs) {
            free(attrs);
            attrs = NULL;
        }

        _type = type;
        if (_name.length) {
            if (!_getter) {
                _getter = NSSelectorFromString(_name);
            }
            if (!_setter) {
                _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [_name substringToIndex:1].uppercaseString, [_name substringFromIndex:1]]);
            }
        }
    }
    return self;
}

@end

@implementation HXYClassInfo {
    BOOL _needUpdate;
}

- (instancetype)initWithClass:(Class)cls {
    if (!cls) {
        return nil;
    }
    self = [super init];
    if (self) {
        _cls = cls;
        _superCls = class_getSuperclass(cls);
        _isMeta = class_isMetaClass(cls);
        if (!_isMeta) {
            _metaCls = objc_getMetaClass(class_getName(cls));
        }
        _name = NSStringFromClass(cls);
        [self _update];
        _superClassInfo = [self.class classInfoWithClass:_superCls];
    }
    return self;
}

- (void)_update {
    _ivarInfos = nil;
    _methodInfos = nil;
    _propertyInfos = nil;

    Class cls = self.cls;
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(cls, &methodCount);
    if (methods) {
        NSMutableDictionary *methodInfos = [NSMutableDictionary dictionary];
        _methodInfos = methodInfos;
        for (int i = 0; i < methodCount; ++i) {
            HXYClassMethodInfo *info = [[HXYClassMethodInfo alloc] initWithMethod:methods[i]];
            if (info.name) {
                methodInfos[info.name] = info;
            }
        }
        free(methods);
    }
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
    if (properties) {
        NSMutableDictionary *propertyInfos = [NSMutableDictionary new];
        _propertyInfos = propertyInfos;
        for (unsigned int i = 0; i < propertyCount; i++) {
            HXYClassPropertyInfo *info = [[HXYClassPropertyInfo alloc] initWithProperty:properties[i]];
            if (info.name) {
                propertyInfos[info.name] = info;
            }
        }
        free(properties);
    }

    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarCount);
    if (ivars) {
        NSMutableDictionary *ivarInfos = [NSMutableDictionary new];
        _ivarInfos = ivarInfos;
        for (unsigned int i = 0; i < ivarCount; i++) {
            HXYClassIvarInfo *info = [[HXYClassIvarInfo alloc] initWithIvar:ivars[i]];
            if (info.name) {
                ivarInfos[info.name] = info;
            }
        }
        free(ivars);
    }

    if (!_ivarInfos) {
        _ivarInfos = @{};
    }
    if (!_methodInfos) {
        _methodInfos = @{};
    }
    if (!_propertyInfos) {
        _propertyInfos = @{};
    }

    _needUpdate = NO;
}

- (void)setNeedUpdate {
    _needUpdate = YES;
}

- (BOOL)needUpdate {
    return _needUpdate;
}

+ (instancetype)classInfoWithClass:(Class)cls {
    if (!cls) {
        return nil;
    }
    static CFMutableDictionaryRef classCache;
    static CFMutableDictionaryRef metaCache;
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        metaCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    HXYClassInfo *info = (HXYClassInfo *)CFDictionaryGetValue(class_isMetaClass(cls) ? metaCache : classCache, (__bridge const void *)cls);
    if (info && info->_needUpdate) {
        [info _update];
    }
    dispatch_semaphore_signal(lock);
    if (!info) {
        info = [[HXYClassInfo alloc] initWithClass:cls];
        if (info) {
            dispatch_wait(lock, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(info.isMeta ? metaCache : classCache, (__bridge const void *)(cls), (__bridge const void *)(info));
            dispatch_semaphore_signal(lock);
        }
    }
    return info;
}

+ (instancetype)classInfoWithClassName:(NSString *)className {
    Class cls = NSClassFromString(className);
    return [self classInfoWithClass:cls];
}

@end
