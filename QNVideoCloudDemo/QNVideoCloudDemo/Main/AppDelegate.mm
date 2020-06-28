#import "AppDelegate.h"

#import "QNVCListViewController.h"
#import <PLMediaStreamingKit/PLMediaStreamingKit.h>

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    [PLStreamingEnv initEnv];

    navController = [[UINavigationController alloc] init];
    [navController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    listController = [[QNVCListViewController alloc] initWithNibName:nil bundle:nil];
    [navController pushViewController:listController animated:NO];

    [self.window setRootViewController:navController];
    [self.window makeKeyAndVisible];

    return YES;
}

@end
