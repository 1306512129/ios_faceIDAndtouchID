//
//  FaceIDVC.m
//  FaceIDTest
//
//  Created by 税鸽飞腾 on 2018/11/5.
//  Copyright © 2018 LWJ. All rights reserved.
//

#import "FaceIDVC.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface FaceIDVC ()

@end

@implementation FaceIDVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 100, 50);
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"验证" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(faceIDLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
}
- (void)faceIDLogin{
        if (@available(iOS 8.0, *)) {
            LAContext *context = [[LAContext alloc]init];
    
            NSError *error = nil;
            //在进行身份验证之前 通过调用 canEvaluatePolicy: error: method 此方法已验证是否可以进行此操作
            //        [self.context canEvaluatePolicy:(LAPolicy) error:<#(NSError * _Nullable __autoreleasing * _Nullable)#>];
            /*
             第一个参数 LAPolicy 是个枚举 里面有两个可选项:
             1.LAPolicyDeviceOwnerAuthentication 当生物识别技术失效或不可用时，允许恢复到密码
             2.LAPolicyDeviceOwnerAuthenticationWithBiometrics 该策略不允许恢复到设备密码。
             */
            //        LAPolicy
    BOOL isCanEvaluatePolicy = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error];
            
    NSLog(@"判断————策略%d",isCanEvaluatePolicy);
#pragma mark - 判断是否支持生物识别
        if (isCanEvaluatePolicy) {
                [self startLocalAuthentication:context];
        }else{
            NSLog(@"设备不支持指纹");
            NSLog(@"%ld", (long)error.code);
            switch (error.code)
            {
                case LAErrorTouchIDNotEnrolled:
                {
                    NSLog(@"Authentication could not start, because Touch ID has no enrolled fingers");
                    break;
                }
                case LAErrorPasscodeNotSet:
                {
                    NSLog(@"Authentication could not start, because passcode is not set on the device");
                    break;
                }
                default:
                {
                    NSLog(@"TouchID not available");
                    break;
                }
            }
        }
    }

    
}
- (void)startLocalAuthentication:(LAContext *)context{
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"测试验证" reply:^(BOOL success, NSError * _Nullable error) {
    
                        if (success) {
                              NSLog(@"验证成功");
                            [self showAlertView:@"验证成功"];
                        }else{
                            
                            NSLog(@"指纹认证失败，%@",error.description);
                            
                            NSLog(@"%ld", (long)error.code); // 错误码 error.code
                            switch (error.code)
                            {
                                case LAErrorAuthenticationFailed: // Authentication was not successful, because user failed to provide valid credentials
                                {
                                    NSLog(@"授权失败"); // -1 连续三次指纹识别错误
                                }
                                    break;
                                case LAErrorUserCancel: // Authentication was canceled by user (e.g. tapped Cancel button)
                                {
                                    NSLog(@"用户取消验证Touch ID"); // -2 在TouchID对话框中点击了取消按钮
                                    
                                }
                                    break;
                                case LAErrorUserFallback: // Authentication was canceled, because the user tapped the fallback button (Enter Password)
                                {
                                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                        NSLog(@"用户选择输入密码，切换主线程处理"); // -3 在TouchID对话框中点击了输入密码按钮
                                    }];
                                    
                                }
                                    break;
                                case LAErrorSystemCancel: // Authentication was canceled by system (e.g. another application went to foreground)
                                {
                                    NSLog(@"取消授权，如其他应用切入，用户自主"); // -4 TouchID对话框被系统取消，例如按下Home或者电源键
                                }
                                    break;
                                case LAErrorPasscodeNotSet: // Authentication could not start, because passcode is not set on the device.
                                    
                                {
                                    NSLog(@"设备系统未设置密码"); // -5
                                }
                                    break;
                                case LAErrorTouchIDNotAvailable: // Authentication could not start, because Touch ID is not available on the device
                                {
                                    NSLog(@"设备未设置Touch ID"); // -6
                                }
                                    break;
                                case LAErrorTouchIDNotEnrolled: // Authentication could not start, because Touch ID has no enrolled fingers
                                {
                                    NSLog(@"用户未录入指纹"); // -7
                                }
                                    break;
                                    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
                                case LAErrorTouchIDLockout: //Authentication was not successful, because there were too many failed Touch ID attempts and Touch ID is now locked. Passcode is required to unlock Touch ID, e.g. evaluating LAPolicyDeviceOwnerAuthenticationWithBiometrics will ask for passcode as a prerequisite 用户连续多次进行Touch ID验证失败，Touch ID被锁，需要用户输入密码解锁，先Touch ID验证密码
                                {
                                    NSLog(@"Touch ID被锁，需要用户输入密码解锁"); // -8 连续五次指纹识别错误，TouchID功能被锁定，下一次需要输入系统密码
                                }
                                    break;
                                case LAErrorAppCancel: // Authentication was canceled by application (e.g. invalidate was called while authentication was in progress) 如突然来了电话，电话应用进入前台，APP被挂起啦");
                                {
                                    NSLog(@"用户不能控制情况下APP被挂起"); // -9
                                }
                                    break;
                                case LAErrorInvalidContext: // LAContext passed to this call has been previously invalidated.
                                {
                                    NSLog(@"LAContext传递给这个调用之前已经失效"); // -10
                                }
                                    break;
#else
#endif
                                default:
                                {
                                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                        NSLog(@"其他情况，切换主线程处理");
                                    }];
                                    break;
                                }
                            }
                        }
    
        }];

}

- (void)showAlertView:(NSString *)title{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
     [self presentViewController:alertController animated:YES completion:nil];
    
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
