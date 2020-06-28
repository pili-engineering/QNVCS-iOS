#import "QNVCListViewController.h"

#import "QNVCListCell.h"
#import "QNVCListModel.h"

#import "QRDLoginViewController.h"
#import "GoingRoomViewController.h"
#import "HomeViewController.h"

@interface QNVCListViewController ()

@property(nonatomic, strong) NSArray<QNVCListModel*>* dataSource;

@end

@implementation QNVCListViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"QNVideoCloud";
    self.dataSource = [NSMutableArray new];

    [self.tableView registerClass:[QNVCListCell class] forCellReuseIdentifier:@"AEPListCell"];

    self.dataSource = @[
        [[QNVCListModel alloc] initWith:[QRDLoginViewController class] title:@"实时音视频"],
        [[QNVCListModel alloc] initWith:[HomeViewController class] title:@"直播推流"],
        [[QNVCListModel alloc] initWith:[GoingRoomViewController class] title:@"播放器"],
    ];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    // Disable the last filter (Core Image face detection) if running on iOS 4.0
    return self.dataSource.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    NSInteger index = [indexPath row];
    NSString* title = self.dataSource[index].title;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"AEPListCell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = title;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    QNVCListModel* model = self.dataSource[indexPath.row];
    UIViewController* vc = [[model.cls alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
