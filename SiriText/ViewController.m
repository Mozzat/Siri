//
//  ViewController.m
//  SiriText
//
//  Created by 上海荣豫资产 on 2018/5/17.
//  Copyright © 2018年 上海荣豫资产. All rights reserved.
//

#import "ViewController.h"
#import<Speech/Speech.h>

@interface ViewController ()<SFSpeechRecognitionTaskDelegate>

@property (nonatomic, strong) AVAudioEngine *audioEngine;                        // 声音处理器
@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;              // 语音识别器
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *speechRequest; // 语音请求对象
@property (nonatomic, strong) SFSpeechRecognitionTask *currentSpeechTask;        // 当前语音识别进程
@property (nonatomic, strong) UILabel *showLb;    // 用于展现的label
@property (nonatomic, strong) UIButton *startBtn;   // 启动按钮

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.showLb];
    [self.view addSubview:self.startBtn];
    
   ///初始化
    self.audioEngine = [[AVAudioEngine alloc]init];
    //需要先设置一个avaudioengine和一个语音识别请求对象 SFSpeechAudioBufferRecognitionRequest
    self.speechRecognizer = [[SFSpeechRecognizer alloc]init];
//    self.startBtn.enabled = NO;
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
       
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
//                isButtonEnabled = true;
                NSLog(@"可以语音识别");
                break;
            case SFSpeechRecognizerAuthorizationStatusDenied:
//                isButtonEnabled = false;
                NSLog(@"用户被拒绝访问语音识别");
                break;
            case SFSpeechRecognizerAuthorizationStatusRestricted:
//                isButtonEnabled = false;
                NSLog(@"不能在该设备上进行语音识别");
                break;
            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
//                isButtonEnabled = false;
                NSLog(@"没有授权语音识别");
                break;
            default:
                break;
        }
        
    }];
    
    ///初始化语音处理器的输入模式
    [self.audioEngine.inputNode installTapOnBus:0 bufferSize:1024 format:[self.audioEngine.inputNode outputFormatForBus:0] block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
       
        //为语音识别请求一个AudioPCMBuffer，来获取声音数据
        [self.speechRequest appendAudioPCMBuffer:buffer];
        
        ///语音处理器准备就绪
        [self.audioEngine prepare];
        
//        self.startBtn.enabled = YES;
        
    }];
    
}

- (void)onStartBtnClicked{
    
    if (self.currentSpeechTask.state == SFSpeechRecognitionTaskStateRunning) {
        
        ///如果当前进程状态是进行中，
        [self.startBtn setTitle:@"开始录制" forState:UIControlStateNormal];
        ///停止语音识别
        [self stopDictating];
        
    } else {
        
        ///进程状态不是进行中
        [self.startBtn setTitle:@"停止录制" forState:UIControlStateNormal];
        self.showLb.text = @"等待";
        ///开启语音识别
        [self startDictationg];
        
    }
    
}

- (void)startDictationg{
    
    NSError *error = nil;
    ///启动声音处理器
    [self.audioEngine startAndReturnError:&error];
    
    ///初始化
    self.speechRequest = [[SFSpeechAudioBufferRecognitionRequest alloc]init];
    
    //使用speechrequest请求进行识别
    self.currentSpeechTask = [self.speechRecognizer recognitionTaskWithRequest:self.speechRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
       
        ///识别结果，识别后的操作
        
        if (result == NULL) {
            return ;
            
        }
        
        self.showLb.text = result.bestTranscription.formattedString;
        
    }];
    
}


- (void)stopDictating{
    
    ///停止声音处理器，停止语音识别请求进程
    
    [self.audioEngine stop];
    [self.speechRequest endAudio];
    
}

- (UILabel *)showLb {
    
    if (!_showLb) {
        
        _showLb = [[UILabel alloc] initWithFrame:CGRectMake(50, 180, self.view.bounds.size.width - 100, 100)];
        _showLb.numberOfLines = 0;
        _showLb.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _showLb.text = @"等待中...";
        _showLb.adjustsFontForContentSizeCategory = YES;
        _showLb.textColor = [UIColor orangeColor];
        
        
    }
    
    return _showLb;
    
}

- (UIButton *)startBtn {
    
    if (!_startBtn) {
        
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _startBtn.frame = CGRectMake(50, 80, 80, 80);
        [_startBtn addTarget:self action:@selector(onStartBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [_startBtn setBackgroundColor:[UIColor redColor]];
        [_startBtn setTitle:@"录音" forState:UIControlStateNormal];
        [_startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        
    }
    
    return _startBtn;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
