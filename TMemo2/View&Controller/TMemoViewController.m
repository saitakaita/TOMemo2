//
//  TMemoViewController.m
//  TMemo2
//
//  Created by TomohikoYamada on 13/05/07.
//  Copyright (c) 2013年 yamada. All rights reserved.
//

#import "TMemoViewController.h"
#import "TDaoMemo.h"
#import "TMemo.h"

@interface TMemoViewController ()
@property (nonatomic, retain) TDaoMemo *deoMemo;
@property (nonatomic, retain) NSMutableArray *memos;
//@property (nonatomic, retain) NSMutableDictionary *memos;

- (void)addMemo:(id)sender;
- (void)addNewMemo:(TMemo *)newMemo;
//- (TMemo *)memoAtIndexPath:(NSInteger *)indexPath;
//- (void)removeMemo:(NSIndexPath *)indexPath;
//- (void)removeOldMemo:(TMemo *)oldMemo;

@end

@implementation TMemoViewController

#pragma mark - Lifecycle methods

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.deoMemo = [[[TDaoMemo alloc] init] autorelease];
//  self.memos = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
  self.memos = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
  
  NSArray *existMemo = [self.deoMemo memos];

  for (TMemo *memo in existMemo) {
    [self addNewMemo:memo];
  }
  self.title = NSLocalizedString(@"BOOK_LIST_TITLE", @"");
  
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
  
  //編集ボタン
  self.navigationItem.leftBarButtonItem = self.editButtonItem;
  //追加ボタン
  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMemo:)];
  self.navigationItem.rightBarButtonItem = addButton;
  [addButton release];
 
}

- (void)viewDidUnload {
  self.deoMemo = nil;
  self.memos = nil;

  [super dealloc];
}

- (void)dealloc {
  self.deoMemo = nil;
  self.memos = nil;
  
  [super dealloc];
}

#pragma mark - Table view data source

//セクション数　使わない
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//  return self.memos.count;
//}

//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.memos.count;
}
//セクションタイトル　使わない
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//  
//  NSString *title = [[NSString alloc] init];
//  
//  return [self.memos objectAtIndex:section];
//  
//}

//指定セルの取得
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  LOG(@"indexPath:%@",indexPath);
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  //cell.textLabel.text = [NSString stringWithFormat:@"項目 %d",indexPath.row];
  if (nil == cell) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  LOG(@"memo:%@",[self.memos objectAtIndex:indexPath.row]);
  cell.textLabel.text = [self.memos objectAtIndex:indexPath.row];
  return cell;
}

//セルの選択時の処理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  LOG(@"didSelectRow indexPath:%@",indexPath);
  TEditMemoViewController *editor2 = [[TEditMemoViewController alloc] init];
  editor2.delegate = self;
  editor2.memo = [self.memos objectAtIndex:indexPath.row];
  
  [self.navigationController pushViewController:editor2 animated:YES];
  [editor2 release];
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//  if (editingStyle == UITableViewCellEditingStyleDelete) {
//    [self removeMemo:indexPath];
//  }
//}

#pragma mark - EditMemoDelegate methods

- (void)addMemoDidFinish:(TMemo *)newMemo {
  LOG(@"newMemo:%@",newMemo);
  
  if (newMemo) {
    [self addNewMemo:newMemo];
    [self.deoMemo add:newMemo];
    [self.tableView reloadData];
  }
  [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)editMemoDidFinish:(TMemo *)oldMemo newMemo:(TMemo *)newMemo {
  LOG(@"editMemoDidFinidh:%@",newMemo);
  if ([oldMemo.note isEqualToString:newMemo.note]) {
    NSMutableArray *memoByList = [self.memos objectForKey:newMemo.note];
    for (TMemo *memo in memoByList) {
      if (memo.memoId == oldMemo.memoId) {
        memo.note = newMemo.note;
        // date
        [self.deoMemo update:newMemo];
        break;
      }
    }
  } else {
//    [self removeOldMemo:oldMemo];
    [self addNewMemo:newMemo];
    [self.deoMemo update:newMemo];
    
  }
  
  [self.tableView reloadData];
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private methods

- (void)addMemo:(id)sender {
  TEditMemoViewController *editor = [[TEditMemoViewController alloc] init];
  editor.delegate = self;
  editor.title = NSLocalizedString(@"MEMO_EDIT_NEW_TITLE", @"");
  
  UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:editor];
  [self.navigationController presentViewController:navi animated:YES completion:NULL];
  
  [editor release];
  [navi release];
}

- (void)addNewMemo:(TMemo *)newMemo {
  //LOG(@"addNewMemo:%@",newMemo);
  NSMutableArray *List = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
  [List addObject:newMemo];
  
  for (TMemo *memo in List) {
    LOG(@"addNewMemo>memo:%@",memo);
    [self.memos addObject:memo.note];
    
  }
}

//- (void)removeMemo:(NSIndexPath *)indexPath {
//  NSMutableArray *memosByList = [self.memos objectForKey:(id)];
//  
//  TMemo *memo = [memosByList objectAtIndex:indexPath.row];
//  [self.deoMemo remove:memo.memoId];
//  
//  [self.tableView beginUpdates];
//  
//  if (memosByList.count == 1) {
//    [self.memos removeObjectForKey:memo.note];
//    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
//  } else {
//    [memosByList removeObjectAtIndex:indexPath.row];
//    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//  }
//  [self.tableView endUpdates];
//}

//- (void)removeOldMemo:(TMemo *)oldMemo {
//  NSMutableArray *memosByList = [self.memos objectForKey:(id)];
//  for (TMemo memo in memosByList) {
//    if (memo.memoId == oldMemo.memoId) {
//      [memosByList removeObject:memo];
//      break;
//    }
//  }
//}

@end
