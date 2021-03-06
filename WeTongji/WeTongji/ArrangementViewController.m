//
//  ArrangementViewController.m
//  WeTongji
//
//  Created by Wu Ziqi on 12-11-5.
//
//

#import "ArrangementViewController.h"
#import "ArrangementCell.h"
#import "Macro.h"
#import "WUArrangementSectionHeaderView.h"
#import <CoreData/CoreData.h>
#import <WeTongjiSDK/WeTongjiSDK.h>
#import "NSString+Addition.h"
#import "AbstractActivity+Addition.h"
#import "Event+Addition.h"
#import "Exam+Addition.h"
#import "Course+Addition.h"
#import "ClassViewController.h"

#define DAY_TIME_INTERVAL (60 * 60 * 24)
#define kXPos 278
#define kYPos 69
#define kOffSet 6
#define kMaxFrameWidth 182

@interface ArrangementViewController () <UITableViewDataSource, UITableViewDelegate>
{
    BOOL _didReachSemesterBegin;
    BOOL _didReachSemeserEnd;
}
@property (weak, nonatomic) IBOutlet UITableView *sectionTableView;
@property (strong, nonatomic) NSMutableArray * arrangeList;
@property (strong, nonatomic) NSMutableArray * sectionList;
@property (strong, nonatomic) NSDate * beginDate;
@property (strong, nonatomic) NSDate * endDate;
@property (strong, nonatomic) NSIndexPath *todayIndexPath;
@property (strong, nonatomic) NSIndexPath *selectedCourse;
- (void)configureTableView;
@end

@implementation ArrangementViewController
@synthesize arrangementTableView;
@synthesize endDate=_endDate;
@synthesize beginDate=_beginDate;
@synthesize selectedCourse = _selectedCourse;

-(NSMutableArray *) arrangeList
{
    if ( !_arrangeList )
    {
        self.beginDate = nil;
        _arrangeList = [[NSMutableArray alloc] init];
        NSArray * tempList = [self getCellsData];
        if ( ![tempList count] ) return _arrangeList;
        NSInteger index = 0;
        NSDate * now = [NSDate dateWithTimeIntervalSinceNow:8*60*60];
        while ( [self.endDate compare:[NSUserDefaults getCurrentSemesterEndDate]] <= 0 )
        {
            AbstractActivity * thing = tempList[index];
            if ( [self.beginDate compare:thing.begin_time] > 0 )
            {
                if ( index < [tempList count] - 1 )
                    index++;
                else break;
            } else if ( [self.endDate compare:thing.begin_time] <= 0 ) {
                if ( [now timeIntervalSinceDate:self.beginDate] >= 0 &&
                    [now timeIntervalSinceDate:self.endDate] < 0 )
                {
                    NSLog(@"%@",now);
                    self.todayIndexPath = [NSIndexPath indexPathForRow:0 inSection:[self.sectionList count]];
                    [_arrangeList addObject:[[NSArray alloc] initWithObjects:[AbstractActivity emptyActivityInManagedObjectContext:self.managedObjectContext], nil]];
                    [self.sectionList addObject:self.beginDate];
                }
                self.beginDate = [self.beginDate dateByAddingTimeInterval:DAY_TIME_INTERVAL];
            } else {
                NSMutableArray * rowList = [[NSMutableArray alloc] init];
                while ( [thing.begin_time compare:self.endDate] < 0 )
                {
                    [rowList addObject:thing];
                    if ( index < [tempList count] - 1 )
                        index++;
                    else break;
                    thing = tempList[index];
                }
                if ( [rowList count] )
                {
                    [_arrangeList addObject:rowList];
                    [self.sectionList addObject:self.beginDate];
                    if ( [now timeIntervalSinceDate:self.beginDate] >= 0 &&
                        [now timeIntervalSinceDate:self.beginDate] < DAY_TIME_INTERVAL )
                    {
                        self.todayIndexPath = [NSIndexPath indexPathForRow:0 inSection:[self.sectionList count]-1];
                    }
                }
                self.beginDate = [self.beginDate dateByAddingTimeInterval:DAY_TIME_INTERVAL];
            }
        }
    }
    return _arrangeList;
}

-(NSMutableArray *) sectionList
{
    
    if ( !_sectionList )
    {
        _sectionList = [[NSMutableArray alloc] init];
    }
    return _sectionList;
}

- (void)resizeCell:(ArrangementCell *)cell
{
    [cell.locationLabel sizeToFit];
    CGRect oldFrame = cell.locationLabel.frame;
    float maxLength = oldFrame.size.width > kMaxFrameWidth ? kMaxFrameWidth : oldFrame.size.width;
    oldFrame.size.width = maxLength;
    oldFrame.origin.x = kXPos - maxLength;
    oldFrame.origin.y = kYPos;
    cell.locationLabel.frame = oldFrame;
    CGRect iconFrame = cell.locationIcon.frame;
    iconFrame.origin.x = oldFrame.origin.x - kOffSet - cell.locationIcon.frame.size.width;
    cell.locationIcon.frame = iconFrame;
}

-(NSDate *) endDate
{
    _endDate = [NSDate dateWithTimeInterval:DAY_TIME_INTERVAL sinceDate:self.beginDate];
    return _endDate;
}

-(NSDate *) beginDate
{
    if ( !_beginDate )
    {
        _beginDate = [NSUserDefaults getCurrentSemesterBeginDate];
        NSInteger interval = [_beginDate timeIntervalSince1970] / DAY_TIME_INTERVAL;
        _beginDate = [NSDate dateWithTimeIntervalSince1970:(interval * DAY_TIME_INTERVAL)];
        NSLog(@"%@",_beginDate);
    }
    return _beginDate;
}

#pragma mark - Private Method
- (void)configureTableView
{
    [self.arrangementTableView registerNib:[UINib nibWithNibName:@"ArrangementCell" bundle:nil] forCellReuseIdentifier:kArrangementCell];
    [self.arrangementTableView registerNib:[UINib nibWithNibName:@"ArrangementNothingCell" bundle:nil] forCellReuseIdentifier:kArrangementNothingCell];
    self.arrangementTableView.backgroundColor = [UIColor clearColor];
    
    if ([[NSDate date] compare:[NSUserDefaults getCurrentSemesterEndDate]] < 0) {
        self.arrangementTableView.tableFooterView = [[[NSBundle mainBundle] loadNibNamed:@"WinterVacationFooterView" owner:self options:nil] objectAtIndex:0];
        [self.arrangementTableView.tableHeaderView setBackgroundColor:[UIColor clearColor]];
    }
    
    [self.arrangementTableView reloadData];
}

#pragma mark - Life Cycle

- (void)autolayout
{
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    if ((screenWidth==568)||(screenHeight==568)) {
        [imageView setImage:[UIImage imageNamed:@"arrange_remind_bg-568h"]];
    } else {
        [imageView setImage:[UIImage imageNamed:@"arrange_remind_bg"]];
    }
    [self.view insertSubview:imageView belowSubview:self.arrangementTableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self autolayout];
    [self configureTableView];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.arrangementTableView scrollToRowAtIndexPath:self.todayIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [self setArrangementTableView:nil];
    [self setSectionTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedCourse = indexPath;
    id activity = self.arrangeList[indexPath.section][indexPath.row];
    if ([activity isKindOfClass:[Event class]]) {
        [self performSegueWithIdentifier:kArrangeToDetailSegue sender:self];
    } else if ([activity isKindOfClass:[Course class]]){
        [self performSegueWithIdentifier:kClassViewControllerSegue sender:self];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UITableViewDataSource
- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.arrangeList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( tableView == self.sectionTableView ) return [self.arrangeList[section] count]-1;
    return [self.arrangeList[section] count];
}

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ( tableView == self.sectionTableView ) return 90;
    return 0;
}

-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    WUArrangementSectionHeaderView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"WUArrangementSectionHeaderView" owner:self options:nil] objectAtIndex:0];
    [headerView setDate:self.sectionList[section]];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if ( tableView == self.sectionTableView )
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"transparentTableCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"transparentTableCell"];
        }
    }
    else
    {
        id activity = self.arrangeList[indexPath.section][indexPath.row];
        NSString * identifier;
        if ( [activity isKindOfClass:[Event class]] ||
             [activity isKindOfClass:[Exam class]] ||
            [activity isKindOfClass:[Course class]]) {
            identifier = kArrangementCell;
        } else {
            identifier = kArrangementNothingCell;
        }
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[ArrangementCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];}
        if ( [identifier isEqualToString:kArrangementCell] )
        {
            AbstractActivity * activity = self.arrangeList[indexPath.section][indexPath.row];
            ((ArrangementCell *)cell).timeLabel.text = [NSString timeConvertFromBeginDate:activity.begin_time endDate:activity.end_time];
            ((ArrangementCell *)cell).titleLabel.text = activity.what;
            ((ArrangementCell *)cell).locationLabel.text = activity.where;
            
            [self resizeCell:((ArrangementCell *)cell)];
                        
            if ( [activity isKindOfClass:[Event class]] )
            {
                [((ArrangementCell *)cell).colorBall setImage:[UIImage imageNamed:@"dot_yellow"]];
            }
            else if ( [activity isKindOfClass:[Course class]] )
            {
                if ( [((Course *)activity).require_type isEqualToString:@"必修"] )
                    [((ArrangementCell *)cell).colorBall setImage:[UIImage imageNamed:@"dot_blue"]];
                else
                    [((ArrangementCell *)cell).colorBall setImage:[UIImage imageNamed:@"dot_green"]];
            }
            else if ( [activity isKindOfClass:[Exam class]] )
            {
                [((ArrangementCell *)cell).colorBall setImage:[UIImage imageNamed:@"dot_red"]];
            }
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

-(UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ( scrollView == self.arrangementTableView )
    {
        self.sectionTableView.contentOffset = self.arrangementTableView.contentOffset;
    }
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kArrangeToDetailSegue]) {
        UIViewController *controller = segue.destinationViewController;
        if ([controller respondsToSelector:@selector(setEvent:)]) {
            [controller performSelector:@selector(setEvent:) withObject:self.arrangeList[self.selectedCourse.section][self.selectedCourse.row]];
        }
    }
    ClassViewController * controller = segue.destinationViewController;
    id activity = self.arrangeList[self.selectedCourse.section][self.selectedCourse.row];
    if ([activity isKindOfClass:[Course class]]) {
        controller.course = activity;
        int i = 0;
        while (i < [self.arrangeList count]) {
            BOOL isFound = NO;
            for (id ex in self.arrangeList[i]) {
                if ([ex isKindOfClass:[Exam class]]) {
                    if ( [((Exam *)ex).nO isEqualToString:((Course *)activity).course_id]) {
                        controller.exam = ex;
                        isFound = YES;
                        break;
                    }
                }
            }
            if (isFound) {
                break;
            }
            i++;
        }
    } else if ([activity isKindOfClass:[Exam class]]) {
        int i = 0;
        while (i < [self.arrangeList count]) {
            BOOL isFound = NO;
            for (id ex in self.arrangeList[i]) {
                if ([ex isKindOfClass:[Course class]]) {
                    if ( [((Course *)ex).course_id isEqualToString:((Exam *)activity).nO]) {
                        controller.course = ex;
                        isFound = YES;
                        break;
                    }
                }
            }
            if (isFound) {
                break;
            }
            i++;
        }
        controller.exam = activity;
    }
}

- (NSArray *)getCellsData
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"AbstractActivity" inManagedObjectContext:self.managedObjectContext]];
    NSDate *semesterBegin = [NSUserDefaults getCurrentSemesterBeginDate];
    NSDate *semesterEnd = [NSUserDefaults getCurrentSemesterEndDate];
    NSPredicate *beginPredicate = [NSPredicate predicateWithFormat:@"begin_time >= %@", semesterBegin];
    NSPredicate *endPredicate = [NSPredicate predicateWithFormat:@"begin_time < %@", semesterEnd];
    NSPredicate * schedule = [NSPredicate predicateWithFormat:@"canSchedule == %@",[NSNumber numberWithBool:NO]];
    [request setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects: beginPredicate, endPredicate, schedule, nil]]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"begin_time" ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObjects:sort, nil];
    [request setSortDescriptors:descriptors];
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:NULL];
    
    return result;
}

- (IBAction)todayClicked
{
    [self.arrangementTableView scrollToRowAtIndexPath:self.todayIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

@end
