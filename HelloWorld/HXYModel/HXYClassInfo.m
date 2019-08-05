//
//  HXYClassInfo.m
//  HelloWorld
//
//  Created by zhangfeng on 2019/8/5.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import "HXYClassInfo.h"

YYEncodingType HXYEncodingGetType(const char *typeEncoding) {
    char *type = (char *)typeEncoding;
    if (!type) {
        return YYEncodingTypeUnknown;
    }
    size_t len = strlen(type);
    if (len == 0) {
        return YYEncodingTypeUnknown;
    }
    
    YYEncodingType qualifier = 0;
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case 'r': {
                qualifier |= YYEncodingTypeQualifierConst;
                ++type;
            } break;
            case 'n': {
                qualifier |= YYEncodingTypeQualifierIn;
                type++;
            }
                break;
            case 'N': {
                qualifier |= YYEncodingTypeQualifierInout;
                type++;
            } break;
            case 'o': {
                qualifier |= YYEncodingTypeQualifierOut;
                type++;
            } break;
            case 'O': {
                qualifier |= YYEncodingTypeQualifierBycopy;
                type++;
            } break;
            case 'R': {
                qualifier |= YYEncodingTypeQualifierByref;
                type++;
            } break;
            case 'V': {
                qualifier |= YYEncodingTypeQualifierOneway;
                type++;
            } break;
            default: {
                prefix = false;
            }
                break;
        }
    }
    
    len = strlen(type);
    if (len == 0) return YYEncodingTypeUnknown | qualifier;
    
    switch (*type) {
        case 'v': return YYEncodingTypeVoid | qualifier;
        case 'B': return YYEncodingTypeBool | qualifier;
        case 'c': return YYEncodingTypeInt8 | qualifier;
        case 'C': return YYEncodingTypeUInt8 | qualifier;
        case 's': return YYEncodingTypeInt16 | qualifier;
        case 'S': return YYEncodingTypeUInt16 | qualifier;
        case 'i': return YYEncodingTypeInt32 | qualifier;
        case 'I': return YYEncodingTypeUInt32 | qualifier;
        case 'l': return YYEncodingTypeInt32 | qualifier;
        case 'L': return YYEncodingTypeUInt32 | qualifier;
        case 'q': return YYEncodingTypeInt64 | qualifier;
        case 'Q': return YYEncodingTypeUInt64 | qualifier;
        case 'f': return YYEncodingTypeFloat | qualifier;
        case 'd': return YYEncodingTypeDouble | qualifier;
        case 'D': return YYEncodingTypeLongDouble | qualifier;
        case '#': return YYEncodingTypeClass | qualifier;
        case ':': return YYEncodingTypeSEL | qualifier;
        case '*': return YYEncodingTypeCString | qualifier;
        case '^': return YYEncodingTypePointer | qualifier;
        case '[': return YYEncodingTypeCArray | qualifier;
        case '(': return YYEncodingTypeUnion | qualifier;
        case '{': return YYEncodingTypeStruct | qualifier;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return YYEncodingTypeBlock | qualifier;
            else
                return YYEncodingTypeObject | qualifier;
        }
        default: return YYEncodingTypeUnknown | qualifier;
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
        const char* typeEncoding = ivar_getTypeEncoding(ivar);
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
        
        YYEncodingType type = 0;
        unsigned int attrCount;
        objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
        for (unsigned int i = 0; i < attrCount; i++) {
            switch (attrs[i].name[0]) {
                case 'T': {
                    if (attrs[i].value) {
                        _typeEncoding = [NSString stringWithUTF8String:attrs[i].value];
                        type = HXYEncodingGetType(attrs[i].value);
                        
                        if ((type & YYEncodingTypeMask) == YYEncodingTypeObject && _typeEncoding.length) {
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
                    
                    
                    
                default:
                    break;
            }
        }
        
    }
    return self;
}

@end

@implementation HXYClassInfo

@end
