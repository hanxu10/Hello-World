//
//  HXYClassInfo.h
//  HelloWorld
//
//  Created by zhangfeng on 2019/8/5.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, HXYEncodingType) {
    HXYEncodingTypeMask       = 0xFF, ///< mask of type value
    HXYEncodingTypeUnknown    = 0, ///< unknown
    HXYEncodingTypeVoid       = 1, ///< void
    HXYEncodingTypeBool       = 2, ///< bool
    HXYEncodingTypeInt8       = 3, ///< char / BOOL
    HXYEncodingTypeUInt8      = 4, ///< unsigned char
    HXYEncodingTypeInt16      = 5, ///< short
    HXYEncodingTypeUInt16     = 6, ///< unsigned short
    HXYEncodingTypeInt32      = 7, ///< int
    HXYEncodingTypeUInt32     = 8, ///< unsigned int
    HXYEncodingTypeInt64      = 9, ///< long long
    HXYEncodingTypeUInt64     = 10, ///< unsigned long long
    HXYEncodingTypeFloat      = 11, ///< float
    HXYEncodingTypeDouble     = 12, ///< double
    HXYEncodingTypeLongDouble = 13, ///< long double
    HXYEncodingTypeObject     = 14, ///< id
    HXYEncodingTypeClass      = 15, ///< Class
    HXYEncodingTypeSEL        = 16, ///< SEL
    HXYEncodingTypeBlock      = 17, ///< block
    HXYEncodingTypePointer    = 18, ///< void*
    HXYEncodingTypeStruct     = 19, ///< struct
    HXYEncodingTypeUnion      = 20, ///< union
    HXYEncodingTypeCString    = 21, ///< char*
    HXYEncodingTypeCArray     = 22, ///< char[10] (for example)
    
    HXYEncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    HXYEncodingTypeQualifierConst  = 1 << 8,  ///< const
    HXYEncodingTypeQualifierIn     = 1 << 9,  ///< in
    HXYEncodingTypeQualifierInout  = 1 << 10, ///< inout
    HXYEncodingTypeQualifierOut    = 1 << 11, ///< out
    HXYEncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
    HXYEncodingTypeQualifierByref  = 1 << 13, ///< byref
    HXYEncodingTypeQualifierOneway = 1 << 14, ///< oneway
    
    HXYEncodingTypePropertyMask         = 0xFF0000, ///< mask of property
    HXYEncodingTypePropertyReadonly     = 1 << 16, ///< readonly
    HXYEncodingTypePropertyCopy         = 1 << 17, ///< copy
    HXYEncodingTypePropertyRetain       = 1 << 18, ///< retain
    HXYEncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
    HXYEncodingTypePropertyWeak         = 1 << 20, ///< weak
    HXYEncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
    HXYEncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
    HXYEncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
};

HXYEncodingType HXYEncodingGetType(const char *typeEncoding);

@interface HXYClassIvarInfo : NSObject

@property (nonatomic, assign, readonly) Ivar ivar;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, assign, readonly) ptrdiff_t offset;
@property (nonatomic, strong, readonly) NSString *typeEncoding;
@property (nonatomic, assign, readonly) HXYEncodingType type;

- (instancetype)initWithIvar:(Ivar)ivar;

@end

@interface HXYClassMethodInfo : NSObject

@property (nonatomic, assign, readonly) Method method;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, assign, readonly) SEL sel;
@property (nonatomic, assign, readonly) IMP imp;
@property (nonatomic, strong, readonly) NSString *typeEncoding;
@property (nonatomic, strong, readonly) NSString *returnTypeEncoding;
@property (nonatomic, strong, readonly, nullable) NSArray<NSString *> *argumentTypeEncodings;

- (instancetype)initWithMethod:(Method)method;

@end

@interface HXYClassPropertyInfo : NSObject

@property (nonatomic, assign, readonly) objc_property_t property;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, assign, readonly) HXYEncodingType type;
@property (nonatomic, strong, readonly) NSString *typeEncoding;
@property (nonatomic, strong, readonly) NSString *ivarName;
@property (nonatomic, assign, readonly, nullable) Class cls;
@property (nonatomic, strong, readonly, nullable) NSArray<NSString *> *protocols;
@property (nonatomic, assign, readonly) SEL getter;
@property (nonatomic, assign, readonly) SEL setter;

- (instancetype)initWithProperty:(objc_property_t)property;

@end

@interface HXYClassInfo : NSObject

@property (nonatomic, assign, readonly) Class cls;
@property (nonatomic, assign, readonly) Class superCls;
@property (nonatomic, assign, readonly) Class metaCls;
@property (nonatomic, assign, readonly) BOOL isMeta;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) HXYClassInfo *superClassInfo;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, HXYClassIvarInfo *> *ivarInfos;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, HXYClassMethodInfo *> *methodInfos;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, HXYClassPropertyInfo *> *propertyInfos;

- (void)setNeedUpdate;

- (BOOL)needUpdate;

+ (nullable instancetype)classInfoWithClass:(Class)cls;

+ (nullable instancetype)classInfoWithClassName:(NSString *)className;

@end

NS_ASSUME_NONNULL_END
