#import <Foundation/Foundation.h>

@interface FrameJson : NSObject
@property (nonatomic,assign) NSInteger y;
@property (nonatomic,assign) NSInteger w;
@property (nonatomic,assign) NSInteger x;
@property (nonatomic,assign) NSInteger h;
@end

@interface SpritesourcesizeJson : NSObject
@property (nonatomic,assign) NSInteger y;
@property (nonatomic,assign) NSInteger w;
@property (nonatomic,assign) NSInteger x;
@property (nonatomic,assign) NSInteger h;
@end

@interface SourcesizeJson : NSObject
@property (nonatomic,assign) NSInteger w;
@property (nonatomic,assign) NSInteger h;
@end

@interface FramesJson : NSObject
@property (nonatomic,strong) FrameJson *frame;
@property (nonatomic,copy  ) NSString *filename;
@property (nonatomic,strong) SpritesourcesizeJson *spritesourcesize;
@property (nonatomic,assign) NSNumber *rotated;
@property (nonatomic,assign) NSNumber *trimmed;
@property (nonatomic,strong) SourcesizeJson *sourcesize;
@end

@interface FramerateJson : NSObject
@property (nonatomic,assign) NSInteger num;
@property (nonatomic,assign) NSInteger den;
@end

@interface SizeJson : NSObject
@property (nonatomic,assign) NSInteger w;
@property (nonatomic,assign) NSInteger h;
@end

@interface ShapesJson : NSObject
@property (nonatomic,assign) NSInteger resourcewidth;
@property (nonatomic,assign) NSInteger resourceheight;
@property (nonatomic,strong) NSArray<FramesJson *> *frames;
@property (nonatomic,strong) FramerateJson *framerate;
@property (nonatomic,copy  ) NSString *imagename;
@property (nonatomic,assign) NSInteger dynamicstickermediatype;
@property (nonatomic,copy  ) NSString *firstframeimagename;
@end

@interface InfoModel : NSObject
@property (nonatomic,copy  ) NSString *disabletextinput;
@property (nonatomic,copy  ) NSString *scale;
@property (nonatomic,strong) NSArray<ShapesJson *> *shapes;
@end
