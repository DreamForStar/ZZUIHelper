//
//  ZZElementAreaViewController.m
//  ZZUIHelper
//
//  Created by 李伯坤 on 2017/2/20.
//  Copyright © 2017年 李伯坤. All rights reserved.
//

#import "ZZElementAreaViewController.h"
#import "ZZElementCell.h"

@interface ZZElementAreaViewController () <NSTableViewDataSource, NSTableViewDelegate, ZZElementCellDelegate>

@property (weak) IBOutlet NSTableView *tableView;

@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation ZZElementAreaViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self reloadData];
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:NOTI_CLASS_PROPERTY_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:NOTI_NEW_PROJECT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deselectAllCells) name:NOTI_NEW_PROPERTY_VC_CLOSE object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadData
{
    self.data = [ZZClassHelper sharedInstance].properties.mutableCopy;
    [self.tableView reloadData];
}

#pragma mark - # Delegate
//MARK: NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.data.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    ZZNSObject *object = self.data[row];
    ZZElementCell *cell = [tableView makeViewWithIdentifier:@"ZZElementCell" owner:tableView];
    [cell setObject:object];
    [cell setDelegate:self];
    return cell;
}

//MARK: NSTableViewDelegate
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSInteger row = [notification.object selectedRow];
    if (row >= 0 && row < self.data.count) {
        ZZNSObject *object = self.data[row];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_CLASS_PROPERTY_SELECTED object:object];
    }
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 70;
}

//MARK: ZZElementCellDelegate
- (void)elementCellDeleteButtonClick:(ZZNSObject *)object
{
    if (object) {
        if ([[ZZClassHelper sharedInstance].curClass.interfaceProperties containsObject:object]) {
            [[ZZClassHelper sharedInstance].curClass removePublicProperty:object];
        }
        else if ([[ZZClassHelper sharedInstance].curClass.extensionProperties containsObject:object]) {
            [[ZZClassHelper sharedInstance].curClass removePrivateProperty:object];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_CLASS_PROPERTY_CHANGED object:nil];
    }
}

#pragma mark - # Event Response
- (void)deselectAllCells
{
    [self.tableView deselectRow:self.tableView.selectedRow];
}

@end
