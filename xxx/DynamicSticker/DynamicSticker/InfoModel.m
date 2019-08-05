#import "InfoModel.h"

@implementation FrameJson
@end

@implementation SpritesourcesizeJson
@end

@implementation SourcesizeJson
@end

@implementation FramesJson
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{ @"spritesourcesize" : @"spriteSourceSize", @"sourcesize" : @"sourceSize",};
}
@end

@implementation FramerateJson
@end

@implementation SizeJson
@end

@implementation ShapesJson
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{ @"resourcewidth" : @"resourceWidth", @"resourceheight" : @"resourceHeight", @"framerate" : @"frameRate", @"imagename" : @"imageName", @"dynamicstickermediatype" : @"dynamicStickerMediaType", @"firstframeimagename" : @"firstFrameImageName",};
}
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{ @"frames" : [FramesJson class],};
}
@end

@implementation InfoModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{ @"disabletextinput" : @"disableTextInput",};
}
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{ @"shapes" : [ShapesJson class],};
}
@end
