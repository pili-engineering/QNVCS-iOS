#import <UIKit/UIKit.h>

@class QNVCListViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    UINavigationController* navController;

    QNVCListViewController* listController;
}

@property(strong, nonatomic) UIWindow* window;

@end
