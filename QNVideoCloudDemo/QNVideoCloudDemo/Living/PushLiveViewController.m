//
//  PushLiveViewController.m
//  NiuLiving
//
//  Created by 何昊宇 on 2018/3/16.
//  Copyright © 2018年 PILI. All rights reserved.
//

#import "PushLiveViewController.h"
#import <PLMediaStreamingKit/PLMediaStreamingKit.h>
#import "UIAlertView+BlocksKit.h"
#import "QRDPublicHeader.h"
#import <Masonry.h>

#import "BEModernStickerPickerView.h"
#import "BEModernEffectPickerView.h"
#import "BETextSliderView.h"

@interface PushLiveViewController ()<PLMediaStreamingSessionDelegate>

@property (nonatomic, strong) PLMediaStreamingSession * session;
@property (nonatomic, strong) NSDictionary * settingDic;
@property (nonatomic, strong) NSURL * pushURL;
@property(nonatomic, strong) NSString* pullUrl;

@property (nonatomic, strong) BEModernStickerPickerView *stickerListView;
@property (nonatomic, strong) BEModernEffectPickerView *effectListView;
@property (nonatomic, strong) PLSEffectDataManager *effectDataManager;
@property (nonatomic, strong) PLSEffectManager *effectManager;

@property (nonatomic, strong) UIButton *effectButton;
@property (nonatomic, strong) UIButton *stickerButton;

@end

@implementation PushLiveViewController

- (instancetype)initWithRoomName:(NSString *)roomName {
    if ([super init]) {
        _roomName = roomName;
    }
    return self;
}

- (void)dealloc {
    [PLSEffectManager releaseManager];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_effectManager updateSticker: self.stickerListView.selectedSticker];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUI];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"settingDic"]) {
        self.settingDic =@{@"isQuic":@(YES),
                           @"isAVFoundation":@(NO),
                           @"isVideoQualityPreinstall":@(YES),
                           @"isEncodePreinstall":@(YES),
                           @"isQualityFirst":@(YES),
                           @"isAdaptiveBitrate":@(YES),
                           @"isDebug":@(YES),
                           @"videoQualityPreinstall":@(5),
                           @"encodeSizePreinstall":@(1)};
    }else {
        self.settingDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"settingDic"];
    }
    [self initPLSession];
    [self setupEffect];
}

#pragma mark - efeect

- (void)setupEffect {
    // PLSEffect
    NSString *rootPath = [[NSBundle mainBundle] resourcePath];
    rootPath = [NSString pathWithComponents:@[rootPath, @"BundleResource"]];
    PLSEffectConfiguration *effectConfiguration = [PLSEffectConfiguration new];
    effectConfiguration.modelFileDirPath = [NSString pathWithComponents:@[rootPath, @"ModelResource.bundle"]];
    effectConfiguration.licenseFilePath = [NSString pathWithComponents:@[rootPath, @"LicenseBag.bundle", @"qiniu_20200214_20210213_com.qiniu.QNVideoCloudDemo_qiniu_v3.9.0.licbag"]];
    _effectDataManager = [[PLSEffectDataManager alloc] initWithRootPath:rootPath];
    
    self.effectManager = [PLSEffectManager sharedWith:[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] configuration:effectConfiguration];
    self.effectListView.effectManager = self.effectManager;
    
    self.effectListView.dataManager = _effectDataManager;
    [self.effectListView loadData];
    
    self.effectButton = [[UIButton alloc] init];
    [self.effectButton setImage:[UIImage imageNamed:@"effect-open"] forState:(UIControlStateSelected)];
    [self.effectButton setBackgroundColor:QRD_COLOR_RGBA(0,0,0,0.3)];
    [self.effectButton setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [self.effectButton setImage:[UIImage imageNamed:@"effect-close"] forState:(UIControlStateNormal)];
    self.effectButton.layer.cornerRadius = 20;
    self.effectButton.clipsToBounds = YES;
    [self.effectButton addTarget:self action:@selector(effectButtonDidClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:_effectButton];
    [self.effectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view).offset(-12);
        make.size.equalTo(CGSizeMake(40, 40));
        make.top.mas_equalTo(self.view.centerY);
    }];
    
    self.stickerButton = [[UIButton alloc] init];
    [self.stickerButton setImage:[UIImage imageNamed:@"sticker-open"] forState:(UIControlStateSelected)];
    [self.stickerButton setBackgroundColor:QRD_COLOR_RGBA(0,0,0,0.3)];
    [self.stickerButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self.stickerButton setImage:[UIImage imageNamed:@"sticker-close"] forState:(UIControlStateNormal)];
    self.stickerButton.layer.cornerRadius = 20;
    self.stickerButton.clipsToBounds = YES;
    [self.stickerButton addTarget:self action:@selector(stickerButtonDidClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:_stickerButton];
    [self.stickerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view).offset(-12);
        make.size.equalTo(CGSizeMake(40, 40));
        make.top.mas_equalTo(self.effectButton).offset(60);
    }];
}

- (BEModernStickerPickerView *)stickerListView {
    if (!_stickerListView) {
        CGRect frame = self.view.bounds;
        _stickerListView = [[BEModernStickerPickerView alloc] initWithFrame:frame];
        _stickerListView.delegate = self;
        PLSEffectModel *clear = [[PLSEffectModel alloc] init];
        clear.displayName = @"无";
        clear.iconImage = [UIImage imageNamed:@"iconCloseButtonNormal"];
        NSMutableArray *stickers = [[NSMutableArray alloc] initWithObjects:clear, nil];
        [stickers addObjectsFromArray:[_effectDataManager fetchEffectListWithType:PLSEffectTypeSticker]];
        [_stickerListView refreshWithStickers:stickers];
    }
    return _stickerListView;
}

- (BEModernEffectPickerView *)effectListView {
    if (!_effectListView) {
        _effectListView = [[BEModernEffectPickerView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    }
    return _effectListView;
}

- (void)effectButtonDidClick:(UIButton *)sender {
    [_effectListView showInView:self.view];
}

- (void)stickerButtonDidClick:(UIButton *)sender {
    [_stickerListView showInView:self.view];
}

#pragma mark - effect picker delegate

- (void)stickerPicker:(BEModernStickerPickerView *)pickerView didSelectSticker:(PLSEffectModel *)sticker {
    [self.effectManager updateSticker:sticker];
}

#pragma mark efeect end
#pragma mark -

- (void)initPLSession {
    if ([self.settingDic[@"isDebug"] boolValue]) {
        [PLStreamingEnv setLogLevel:PLStreamLogLevelDebug];
        [PLStreamingEnv enableFileLogging];
    }
    NSArray *encodeSize = @[@"240",@"424",@"480",@"848",@"544",@"960",@"720",@"1080",@"1088",@"1920"];
    PLVideoStreamingConfiguration *streamingConfig;
    if ([self.settingDic[@"isVideoQualityPreinstall"] boolValue]) {
        NSString * videoQuality = nil;
        switch ([self.settingDic[@"videoQualityPreinstall"] integerValue]) {
            case 0:
               videoQuality = kPLVideoStreamingQualityLow1;
                break;
            case 1:
                videoQuality = kPLVideoStreamingQualityLow2;
                break;
            case 2:
                videoQuality = kPLVideoStreamingQualityLow3;
                break;
            case 3:
                videoQuality = kPLVideoStreamingQualityMedium1;
                break;
            case 4:
                videoQuality = kPLVideoStreamingQualityMedium2;
                break;
            case 5:
                videoQuality = kPLVideoStreamingQualityMedium3;
                break;
            case 6:
                videoQuality = kPLVideoStreamingQualityHigh1;
                break;
            case 7:
                videoQuality = kPLVideoStreamingQualityHigh2;
                break;
            case 8:
                videoQuality = kPLVideoStreamingQualityHigh3;
                break;
                
            default:
                videoQuality = kPLVideoStreamingQualityMedium3;
                break;
        }
        streamingConfig = [PLVideoStreamingConfiguration configurationWithVideoQuality:videoQuality];
        streamingConfig.videoEncoderType = ![self.settingDic[@"isAVFoundation"] boolValue];
    }else {
        streamingConfig = [[PLVideoStreamingConfiguration alloc] initWithVideoSize:CGSizeMake(480, 848) expectedSourceVideoFrameRate:[self.settingDic[@"fps"] intValue]videoMaxKeyframeInterval:[self.settingDic[@"maxKeyframe"] intValue] averageVideoBitRate:([self.settingDic[@"bitrate"] floatValue] * 1024) videoProfileLevel:AVVideoProfileLevelH264HighAutoLevel videoEncoderType:![self.settingDic[@"isAVFoundation"] boolValue]];
    }
    
    if ([self.settingDic[@"isEncodePreinstall"] boolValue]) {
        int encodeSizeNumber= [self.settingDic[@"encodeSizePreinstall"] intValue];
        streamingConfig.videoSize = CGSizeMake( [[encodeSize objectAtIndex:encodeSizeNumber * 2] floatValue], [[encodeSize objectAtIndex:encodeSizeNumber * 2 + 1] floatValue]);
    }else {
        streamingConfig.videoSize = CGSizeMake([self.settingDic[@"width"] floatValue], [self.settingDic[@"height"] floatValue]);
    }
    self.session = [[PLMediaStreamingSession alloc] initWithVideoCaptureConfiguration:[PLVideoCaptureConfiguration defaultConfiguration] audioCaptureConfiguration:[PLAudioCaptureConfiguration defaultConfiguration] videoStreamingConfiguration:streamingConfig audioStreamingConfiguration:[PLAudioStreamingConfiguration defaultConfiguration] stream:nil];
    self.session.previewView.frame = [UIScreen mainScreen].bounds;
    self.session.delegate = self;
    [self.view insertSubview:self.session.previewView atIndex:0];
    [self.session setBeautifyModeOn:YES];
    [self.session setQuicEnable:[self.settingDic[@"isQuic"] boolValue]];
    if ([self.settingDic[@"isQuic"] boolValue]) {
        self.pushTypeLabel.text = @"推流协议：QUIC/RTMP";
    }else {
        self.pushTypeLabel.text = @"推流协议：TCP/RTMP";
    }
    self.beautyButton.selected = YES;
    [PLMediaStreamingSession requestMicrophoneAccessWithCompletionHandler:^(BOOL granted) {
        if (!granted) {
            [self showAlertWithMessage:@"获取麦克风权限失败,请去设置开启" completion:^{
                [self closeAction:nil];
            }];
        }
    }];
    [PLMediaStreamingSession requestCameraAccessWithCompletionHandler:^(BOOL granted) {
        if (granted) {
            if ([self.settingDic[@"isAdaptiveBitrate"] boolValue]) {
                [self.session enableAdaptiveBitrateControlWithMinVideoBitRate : 100*1024];
            }
            [self requestStreamURLWithCompleted:^(NSError *error, NSString *urlString) {
                if (urlString) {
                    self.pushURL = [NSURL URLWithString:urlString];
                    [self.session startStreamingWithPushURL:self.pushURL feedback:^(PLStreamStartStateFeedback feedback) {
                        if (feedback != PLStreamStartStateSuccess) {
                            [self showAlertWithMessage:@"推流失败，请重试" completion:^{
                                [self closeAction:nil];
                            }];
                        }
                    }];
                }else {
                    [self showAlertWithMessage:@"获取推流 URL 失败，请重试" completion:^{
                        [self closeAction:nil];
                    }];
                }
            }];
        }else {
            [self showAlertWithMessage:@"获取相机权限失败,请去设置开启" completion:^{
                [self closeAction:nil];
            }];
        }
    }];
    
}

- (void)setupUI {
    self.infoView.hidden = NO;
    self.messageView.alpha = 0;
    self.messageLabel.text = [NSString stringWithFormat:@"播放地址： %@ 已复制到剪贴板",self.pullUrl];
    
    [self.lightButton setImage:[UIImage imageNamed:@"light_on"] forState:UIControlStateNormal];
    [self.lightButton setImage:[UIImage imageNamed:@"light_off"] forState:UIControlStateSelected];
    self.lightButton.selected = NO;
}

#pragma mark - 请求数据

- (void)requestStreamURLWithCompleted:(void (^)(NSError *error, NSString *urlString))handler
{
    if ([[NSURL URLWithString:self.roomName].scheme isEqualToString:@"rtmp"]) {
        NSString *streamString = self.roomName;
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(nil, streamString);
        });
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/v1/live/stream/%@",PLDomain, self.roomName]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 10;
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(error, nil);
            });
            return;
        }
        
        NSString *streamString = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(nil, streamString);
        });
        
    }];
    [task resume];
}

- (IBAction)infoAction:(id)sender {
    self.infoButton.selected = !self.infoButton.isSelected;
    if (!self.infoButton.isSelected) {
        self.infoView.hidden = NO;
    }else {
        self.infoView.hidden = YES;
    }
}
- (IBAction)urlCopyAction:(id)sender {
    if (self.pullUrl.length == 0) {
        self.pullUrl = @"-";
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/v1/live/play/%@/rtmp",PLDomain, self.roomName]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        request.HTTPMethod = @"GET";
        request.timeoutInterval = 10;
        
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.pullUrl = @"";
                    [self showMessage:@"未获取到播放地址"];
                });
                return;
            }
            
            self.pullUrl = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = self.pullUrl;
                [self showMessage:[NSString stringWithFormat:@"播放地址：%@ 已复制到剪贴板", self.pullUrl]];
            });
        }];
        [task resume];
    } else if (self.pullUrl.length > 5) {
        [self showMessage:[NSString stringWithFormat:@"播放地址：%@ 已复制到剪贴板", self.pullUrl]];
    }
}

- (void)showMessage:(NSString*)message {
    self.messageLabel.text = message;
    [UIView animateWithDuration:1.0 animations:^{ // 执行动画
        self.messageView.alpha = 1.f;
    } completion:^(BOOL finished) { // 完成
        [UIView animateWithDuration:2.0 delay:1.0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.messageView.alpha = 0;
        } completion:nil];
    }];
}

- (IBAction)closeAction:(id)sender {
    [self.session destroy];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)toggleCameraAction:(id)sender {
    self.toggleCameraButton.selected = !self.toggleCameraButton.isSelected;
    self.lightButton.hidden = self.toggleCameraButton.isSelected;
    [self.session toggleCamera];
        if (!self.toggleCameraButton.isSelected){
            if (self.lightButton.isSelected) { //打开闪光灯
                AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
                NSError *error = nil;
                
                if ([captureDevice hasTorch]) {
                    BOOL locked = [captureDevice lockForConfiguration:&error];
                    if (locked) {
                        captureDevice.torchMode = AVCaptureTorchModeOn;
                        [captureDevice unlockForConfiguration];
                    }
                }
            }else{//关闭闪光灯
                AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
                if ([device hasTorch]) {
                    [device lockForConfiguration:nil];
                    [device setTorchMode: AVCaptureTorchModeOff];
                    [device unlockForConfiguration];
                }
            }
        }
}

- (IBAction)lightAction:(id)sender {
    self.lightButton.selected = !self.lightButton.isSelected;
        if (!self.toggleCameraButton.isSelected){
            if (self.lightButton.isSelected) { //打开闪光灯
                AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
                NSError *error = nil;
                
                if ([captureDevice hasTorch]) {
                    BOOL locked = [captureDevice lockForConfiguration:&error];
                    if (locked) {
                        captureDevice.torchMode = AVCaptureTorchModeOn;
                        [captureDevice unlockForConfiguration];
                    }
                }
            }else{//关闭闪光灯
                AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
                if ([device hasTorch]) {
                    [device lockForConfiguration:nil];
                    [device setTorchMode: AVCaptureTorchModeOff];
                    [device unlockForConfiguration];
                }
            }
        }
}

- (IBAction)beautyAction:(id)sender {
    self.beautyButton.selected = !self.beautyButton.isSelected;
    [self.session setBeautify:self.beautyButton.isSelected];
    if (self.beautyButton.isSelected) {
        self.beautyButton.alpha = 1;
    }else {
        self.beautyButton.alpha = 0.4;
    }
}

- (void)showAlertWithMessage:(NSString *)message completion:(void (^)(void))completion
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        UIAlertView *alertView = [UIAlertView bk_showAlertViewWithTitle:@"错误" message:message cancelButtonTitle:@"确定" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (completion) {
                completion();
            }
        }];
        [alertView show];
    }
    else {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"错误" message:message preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (completion) {
                completion();
            }
        }]];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark PLMediaStreamingSessionDelegate

- (void)mediaStreamingSession:(PLMediaStreamingSession *)session streamStatusDidUpdate:(PLStreamStatus *)status {
    self.resolutionLabel.text = [NSString stringWithFormat:@"分辨率：%.f * %.f",self.session.videoStreamingConfiguration.videoSize.width,self.session.videoStreamingConfiguration.videoSize.height];
    self.fpsLabel.text = [NSString stringWithFormat:@"视频帧率：%.2f ",status.videoFPS];
    self.audioFpsLabel.text = [NSString stringWithFormat:@"音频帧率：%.2f ",status.audioFPS];
    self.bitrateLabel.text = [NSString stringWithFormat:@"码率：%.2f kbps",status.totalBitrate/1000.0];
    
}

- (CVPixelBufferRef)mediaStreamingSession:(PLMediaStreamingSession *)session cameraSourceDidGetPixelBuffer:(CVPixelBufferRef _Nonnull)pixelBuffer timingInfo:(CMSampleTimingInfo)timingInfo {
    if (self.effectManager) {
        double timestamp = timingInfo.presentationTimeStamp.value/timingInfo.presentationTimeStamp.timescale;
        [self.effectManager processBuffer:pixelBuffer withTimestamp:timestamp videoOrientation:AVCaptureVideoOrientationPortrait deviceOrientation:AVCaptureVideoOrientationPortrait];
    }
    return pixelBuffer;
}

- (void)mediaStreamingSession:(PLMediaStreamingSession *)session streamStateDidChange:(PLStreamState)state {
    
}

- (void)mediaStreamingSession:(PLMediaStreamingSession *)session didDisconnectWithError:(NSError *)error {
    NSLog(@"error: %@", error);
    [self showAlertWithMessage:@"推流出错: 请重新推流" completion:^{
        [self closeAction:nil];
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
