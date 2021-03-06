//
//  ViewController.m
//  DynamicSticker
//
//  Created by xuxune on 2019/7/31.
//  Copyright © 2019 hxy-tech.com. All rights reserved.
//

#import "ViewController.h"
#import <BlocksKit/BlocksKit.h>
#import "XXImage.h"
#import "InfoModel.h"
#import <YYModel/YYModel.h>
#import <SSZipArchive/SSZipArchive.h>

@interface ViewController () <XXDragDropViewDelegate, NSTextFieldDelegate, NSTableViewDataSource, NSTableViewDelegate>
@property (strong) NSArray<NSImageView *> *framesImageView;
@property (assign) NSInteger colCount;
@property (assign) NSInteger frameRate;
@property (strong) NSImage *staticImage;
@property (strong) NSArray<NSImage *> *dynamicImages;
@property (strong) NSArray<NSString *> *dynamicImageNames;

@end

@implementation ViewController

- (void)awakeFromNib {
    [super awakeFromNib];
   
    self.colCount = 5;
    self.frameRate = 30;
    self.dragDropView.delegate = self;
    self.staticImageView.layer.cornerRadius = 20;
    self.staticImageView.layer.masksToBounds = YES;
    
    self.framesImageView = @[self.frameOneImageView, self.frameTwoImageView, self.frameThreeImageView];
    for (NSImageView *imageView in self.framesImageView) {
        imageView.layer.cornerRadius = 20;
        imageView.layer.masksToBounds = YES;
    }
    
    self.colCountTextField.delegate = self;
    self.frameRateTextField.delegate = self;
}

- (NSString *)currentTimeString {
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *current = [formatter stringFromDate:now];
    return current;
}

- (IBAction)clickExport:(id)sender {
  
    if (!self.staticImage) {
        return;
    }
    
    if (!self.dynamicImages.count) {
        return;
    }
    
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setMessage:@"保存zip包到哪个文件夹"];//提示文字
    [panel setDirectoryURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"]]];//设置默认打开路径
    
    NSString *nameFieldString = [NSString stringWithFormat:@"dynamicSticker-%@", [self currentTimeString]];
    [panel setNameFieldStringValue:nameFieldString];
    
    [panel setAllowsOtherFileTypes:YES];
    [panel setAllowedFileTypes:@[@"zip"]];
    [panel setExtensionHidden:NO];
    [panel setCanCreateDirectories:YES];
    
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result){
        if (result == NSModalResponseOK) {
            NSString *zipPath = [[panel URL] path];
            NSString *dirPath = [zipPath stringByDeletingLastPathComponent];
            NSString *tempDirPath = [dirPath stringByAppendingPathComponent:nameFieldString];
            [[NSFileManager defaultManager] createDirectoryAtPath:tempDirPath withIntermediateDirectories:YES attributes:nil error:nil];
            
            ShapesJson *shape = nil;
            NSImage *bigImage = [XXImage jointedImageWithImages:self.dynamicImages colCount:self.colCount shape:&shape];
            
            NSString *staticImageName = @"static.png";
            NSString *staticTempImageName = @"static_temp.png";
            
            NSString *bigImageName = @"big.png";
            NSString *bigTempImageName = @"big_temp.png";
            [XXImage saveImage:self.staticImage fileName:[tempDirPath stringByAppendingPathComponent:staticTempImageName]];
            //先存一个临时的大图
            [XXImage saveImage:bigImage fileName:[tempDirPath stringByAppendingPathComponent:bigTempImageName]];
            
            InfoModel *infoModel = [[InfoModel alloc] init];
            infoModel.disabletextinput = @"1";
            infoModel.scale = @"1x";
            shape.imagename = bigImageName;
            shape.firstframeimagename = staticImageName;
            shape.framerate.num = self.frameRate;
            
            infoModel.shapes = @[shape];
            [[infoModel yy_modelToJSONData] writeToFile:[tempDirPath stringByAppendingPathComponent:@"info.json"] atomically:YES];
            
            NSString *pngQuantPath = [[NSBundle mainBundle] pathForResource:@"pngquant" ofType:nil];
            NSMutableString *cmdString = [NSMutableString string];
            [cmdString appendFormat:@"cd \"%@\";", tempDirPath];
            [cmdString appendFormat:@"\"%@\" --quality=10-70 \"%@\" --output \"%@\";", pngQuantPath, bigTempImageName, bigImageName];
            [cmdString appendFormat:@"\"%@\" --quality=10-70 \"%@\" --output \"%@\"", pngQuantPath, staticTempImageName, staticImageName];
            
//            ./pngquant --quality=10-70 image.png
            
            [self cmd:cmdString completion:^(BOOL success) {
                if (success) {
                    [[NSFileManager defaultManager] removeItemAtPath:[tempDirPath stringByAppendingPathComponent:bigTempImageName] error:nil];
                    [[NSFileManager defaultManager] removeItemAtPath:[tempDirPath stringByAppendingPathComponent:staticTempImageName] error:nil];
                    [SSZipArchive createZipFileAtPath:zipPath withContentsOfDirectory:tempDirPath];
                    [[NSFileManager defaultManager] removeItemAtPath:tempDirPath error:nil];
                    
                    //此时zip生成成功了,再创建一个文件夹来装zip和150 * 150的拇指图
                    [[NSFileManager defaultManager] createDirectoryAtPath:tempDirPath withIntermediateDirectories:YES attributes:nil error:nil];
                    [[NSFileManager defaultManager] moveItemAtPath:zipPath toPath:[tempDirPath stringByAppendingPathComponent:zipPath.lastPathComponent] error:nil];

                    //貌似不用压缩
                    [XXImage saveImage:[XXImage fitResizeImage:self.staticImage toSize:CGSizeMake(150, 150)] fileName:[tempDirPath stringByAppendingPathComponent:staticImageName]];
                    NSMutableString *cmdString = [NSMutableString string];
                    [cmdString appendFormat:@"cd %@;", tempDirPath];
                    [cmdString appendFormat:@"%@ --quality=10-70 %@ --output %@", pngQuantPath, staticImageName, [tempDirPath stringByAppendingPathComponent:@"thumb.png"]];
                    
                    [self cmd:cmdString completion:^(BOOL success) {
                        [[NSFileManager defaultManager] removeItemAtPath:[tempDirPath stringByAppendingPathComponent:staticImageName] error:nil];
                        
                        self.staticImage = nil;
                        self.staticImageView.image = nil;
                        self.dynamicImages = nil;
                        self.dynamicImageNames = nil;
                        [self.tableView reloadData];
                        [self.framesImageView enumerateObjectsUsingBlock:^(NSImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            obj.image = nil;
                        }];
                        
                        [self showAlert:@"生成成功" buttonTitle:@"在finder中找到文件" completionHandler:^(BOOL ok){
                            if (ok) {
                                [[NSWorkspace sharedWorkspace] selectFile:tempDirPath inFileViewerRootedAtPath:@"xx"];
                            }
                        }];
                    }];
                } else {
                    [self showAlert:@"生成失败" buttonTitle:@"ok" completionHandler:nil];
                }
            }];
        }
    }];
}

- (void)showAlert:(NSString *)informativeText buttonTitle:(NSString *)buttonTitle completionHandler:(void (^)(BOOL ok))completionHandler {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"good"];
    [alert setInformativeText:informativeText];
    [alert addButtonWithTitle:buttonTitle];
    [alert addButtonWithTitle:@"Cancel"];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSAlertFirstButtonReturn){
            if (completionHandler) {
                completionHandler(YES);
            }
        }else if(returnCode == NSAlertSecondButtonReturn){
            if (completionHandler) {
                completionHandler(NO);
            }
        }
    }];
}

- (void)cmd:(NSString *)cmd completion:(void (^)(BOOL success))completion {
    // 初始化并设置shell路径
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/bash"];
    // -c 用来执行string-commands（命令字符串），也就说不管后面的字符串里是什么都会被当做shellcode来执行
    NSArray *arguments = [NSArray arrayWithObjects: @"-c", cmd, nil];
    [task setArguments: arguments];

    task.terminationHandler = ^(NSTask * task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion([task terminationStatus] == 0);
            }
        });
    };
    [task launch];
    [task waitUntilExit];
}


- (void)controlTextDidChange:(NSNotification *)noti {
    if (noti.object == self.colCountTextField) {
        self.colCount = [self.colCountTextField.stringValue integerValue];
    } else if (noti.object == self.frameRateTextField) {
        self.frameRate = [self.frameRateTextField.stringValue integerValue];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    [[NSApp mainWindow] makeFirstResponder:nil];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)dragDropFilePathList:(NSArray<NSString *> *)filePathList {
    if (filePathList.count == 1) {
        [self updateStaticImageInfoWithFile:filePathList.firstObject];
    } else if (filePathList.count > 1) {
        [self updateDynamicImageInfoWithFiles:filePathList];
    }
}

- (void)updateStaticImageInfoWithFile:(NSString *)filePath {
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:filePath];
    NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
    image.size = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
    self.staticImage = image;
    self.staticImageLabel.hidden = NO;
    self.staticImageView.image = image;
}

- (void)updateDynamicImageInfoWithFiles:(NSArray *)filePathList {
    self.dynamicImageNames = filePathList;
    
    NSArray<NSImage *> *images = [filePathList bk_map:^id(NSString *filePath) {
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:filePath];
        NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
        image.size = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
        return image;
    }];
    
    self.dynamicImages = images;
    
    [self.framesImageView enumerateObjectsUsingBlock:^(NSImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.image = nil;
    }];
    for (NSInteger i = 0; i < images.count; i++) {
        if (i < self.framesImageView.count) {
            self.framesImageView[i].image = images[i];
        } else {
            break;
        }
    }
    [self.tableView reloadData];
}

- (void)mouseDown:(NSEvent *)event{
    [[NSApp mainWindow] makeFirstResponder:nil];
}

#pragma mark -

//返回行数
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.dynamicImages.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [self.dynamicImageNames[row] lastPathComponent];
}

#pragma mark - 行高
-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 20;
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn {
    //按照名称排序
    if (!self.dynamicImageNames.count) {
        return;
    }
    NSArray *tempNames = [self.dynamicImageNames copy];
    static BOOL flag = NO;
    NSArray *sortedArray = [tempNames sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        NSComparisonResult ret = [obj1 compare:obj2 options:NSNumericSearch];
        return flag ? (ret > 0) : (ret < 0);
    }];
    flag = !flag;
    [self updateDynamicImageInfoWithFiles:sortedArray];
}

////选中的响应
-(void)tableViewSelectionDidChange:(nonnull NSNotification *)notification{

    NSTableView* tableView = notification.object;

    NSLog(@"didSelect：%@",notification);
}

@end
