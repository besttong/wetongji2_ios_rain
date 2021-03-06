//
//  SchoolNewsViewController.m
//  WeTongji
//
//  Created by Ziqi on 12-10-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SchoolNewsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Macro.h"
#import "TextViewTableCell.h"
#import "WUTapImageView.h"
#import "WUTableHeaderView.h"
#import "WUPageControlViewController.h"
#import "TransparentTableHeaderView.h"
#import "SchoolNewsContactCell.h"
#import "SchoolNewsLocationCell.h"
#import "SchoolNewsTicketCell.h"
#import <WeTongjiSDK/WeTongjiSDK.h>
#import "NSDictionary+Addition.h"
#import "UIApplication+nj_SmartStatusBar.h"
#import "UIPhoneCallActionSheet.h"
#import "UIMapApplicationSheet.h"

#define kContentOffset 50
#define kStateY -150
#define kRowHeight 44
#define kOrigin 2
#define kCurrent 6
#define noPic @"missing.png"

@interface SchoolNewsViewController () <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    BOOL _isBackGroundHide;
    BOOL _haveImages;
    CGPoint originNewsTableViewCenter;
    CGPoint originPageViewCenter;
}
- (void)renderShadow:(UIView *)view;
- (void)configureTableView;
- (void)renderBorder:(UIView *)view;
@property (weak, nonatomic) IBOutlet UIImageView *buttonBackImageView;
@property (nonatomic, strong) WUTableHeaderView *headerView;
@property (nonatomic, strong) WUPageControlViewController *pageViewController;
@property (nonatomic, assign) BOOL isAnimationFinished;
@property (nonatomic, strong) TextViewTableCell* currentCell;
@property (nonatomic, strong) TransparentTableHeaderView * transparentHeaderView;
@property (nonatomic, strong) NSDictionary * imageDict;
@end

@implementation SchoolNewsViewController
@synthesize newsTableView;
@synthesize backButton;

@synthesize pageViewController = _pageViewController;
@synthesize headerView = _headerView;
@synthesize isAnimationFinished = _isAnimationFinished;
@synthesize currentCell = _currentCell;
@synthesize transparentHeaderView = _transparentHeaderView;
#pragma mark - Private Method
- (void)renderShadow:(UIView *)view
{
}

- (void)autolayout
{
//    CGRect frame = self.pageViewController.view.frame;
//    frame.size.height = [[UIScreen mainScreen] bounds].size.height;
//    [self.pageViewController.view setFrame:frame];
}

- (void)configureTableView
{
    [self.newsTableView registerNib:[UINib nibWithNibName:@"TextViewTableCell" bundle:nil] forCellReuseIdentifier:kTextViewTableCell];
    self.newsTableView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:self.pageViewController.view belowSubview:self.newsTableView];
    self.newsTableView.frame = CGRectMake(0, 0, 320, self.newsTableView.frame.size.height + (self.headerView.bounds.size.height - kContentOffset));
    originNewsTableViewCenter = [self.newsTableView center];
}

- (void)renderBorder:(UIView *)view
{
    view.layer.borderWidth = 1.0f;
    view.layer.borderColor = [UIColor colorWithRed:157 green:157 blue:157 alpha:1.0].CGColor;
}
#pragma mark - Tap

-(void)showScheduleTable
{
    [self.newsTableView scrollRectToVisible:self.view.frame animated:NO];
    [[UIApplication sharedApplication] nj_setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [UIView animateWithDuration:0.55f animations:^{
        [self.view setFrame: [self.view bounds]];
        [self.newsTableView setCenter:originNewsTableViewCenter];
        [self.backButton setAlpha:1.0];
        [self.buttonBackImageView setAlpha:1.0];
    } completion:^(BOOL finished) {}];
    
    [UIView animateWithDuration:0.8f animations:^{
        [self.pageViewController.view setCenter:originPageViewCenter];
    } completion:^(BOOL finished) {
        self.isAnimationFinished = false;
        self.pageViewController.view.userInteractionEnabled = NO;
        self.newsTableView.userInteractionEnabled = YES;}];
}

- (void)didTap:(UITapGestureRecognizer *)recognizer
{
    [self showScheduleTable];
}

- (void)didSwipe:(UISwipeGestureRecognizer *)recognizer
{
    [self showScheduleTable];
}

#pragma mark - Setter & Getter
- (WUPageControlViewController *)pageViewController
{
    if (_pageViewController == nil) {
        _pageViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:kWUPageControlViewController];
        UISwipeGestureRecognizer *upSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
        upSwipe.direction = UISwipeGestureRecognizerDirectionUp;
        [_pageViewController.view addGestureRecognizer:upSwipe];
        float rate = (self.newsTableView.contentOffset.y + kContentOffset) / -kRowHeight;
        CGRect frame = _pageViewController.view.frame;
        frame.origin.y =  kStateY + 15 * rate;
        [_pageViewController.view setFrame:frame];
        _pageViewController.view.userInteractionEnabled = NO;
        _haveImages = [self.imageDict allKeys].count ? YES : NO;
        for ( NSString * link in [self.imageDict allKeysInStringOrder] )
        {
            UIImageView * view = [[UIImageView alloc] init];
            [view setImageWithURL:[NSURL URLWithString:link] placeholderImage:[UIImage imageNamed:@"default_pic_loading"]];
            [_pageViewController addPicture:view withDescription:self.imageDict[link]];
        }
        if ( [self.imageDict allKeys].count == 0)
        {
            UIImageView * view = [[UIImageView alloc] init];
            [view setImage:[UIImage imageNamed:@"default_pic"]];
            [_pageViewController addPicture:view withDescription:[NSNull null]];
        }
        originPageViewCenter = [_pageViewController.view center];
    }
    
    return _pageViewController;
}

-(TextViewTableCell *) currentCell
{
    if (_currentCell == nil)
    {
        _currentCell = [self.newsTableView dequeueReusableCellWithIdentifier:kTextViewTableCell];
        if ( _currentCell == nil )
        _currentCell = [[TextViewTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTextViewTableCell];
    }
    return _currentCell;
}

- (WUTableHeaderView *)headerView
{
    if (_headerView == nil) {
        
    }
    return _headerView;
}

- (TransparentTableHeaderView *) transparentHeaderView
{
    if ( !_transparentHeaderView )
    {
        _transparentHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"TransparentTableHeaderView" owner:self options:nil] objectAtIndex:0];  
    }
    return  _transparentHeaderView;
}

-(void) configureCurrentCell
{
    [self.currentCell setFrame:CGRectMake(0, 0,self.currentCell.frame.size.width,MAX(self.currentCell.textView.contentSize.height,self.view.bounds.size.height-kContentOffset-20))];
    self.currentCell.contentView.backgroundColor = self.currentCell.textView.backgroundColor;
    CGRect frame = self.currentCell.textView.frame;
    frame.size.height = self.currentCell.frame.size.height;
    self.currentCell.textView.frame = frame;
}

-(void) setEvent:(Event *)event
{
    self.headerView =  [[[NSBundle mainBundle] loadNibNamed:@"WUTableHeaderView" owner:self options:nil] objectAtIndex:0];
    [self renderShadow:self.headerView];
    [self.headerView setEvent:event];
    [self.transparentHeaderView setHideBoard:NO];
    [self.transparentHeaderView setEvent:event];
    NSLog(@"%@",event.imageLink);
    if ( ![event.imageLink hasSuffix:noPic] )
        self.imageDict = [NSDictionary dictionaryWithObject:[NSNull null] forKey:event.imageLink];
    _event = event;
}

-(void) setInformation:(Information *)information
{
    if ( [information.category isEqualToString:GetInformationTypeForStaff] ){
        self.headerView =  [[[NSBundle mainBundle] loadNibNamed:@"SchoolNewsHeaderView" owner:self options:nil] objectAtIndex:0];
        [self renderShadow:self.headerView];
        [self.headerView  setInformation:information];
        [self.transparentHeaderView setHideBoard:YES];
    } else if ( [information.category isEqualToString:GetInformationTypeClubNews] ){
        self.headerView =  [[[NSBundle mainBundle] loadNibNamed:@"GroupNewsHeaderView" owner:self options:nil] objectAtIndex:0];
        [self renderShadow:self.headerView];
        [self.headerView  setInformation:information];
        [self.transparentHeaderView setHideBoard:NO];
        [self.transparentHeaderView setInformation:information];
    } else if ( [information.category isEqualToString:GetInformationTypeSchoolNews] ){
        self.headerView =  [[[NSBundle mainBundle] loadNibNamed:@"ActionNewsHeaderView" owner:self options:nil] objectAtIndex:0];
        [self renderShadow:self.headerView];
        [self.headerView  setInformation:information];
        [self.transparentHeaderView setHideBoard:YES];
    } else if ( [information.category isEqualToString:GetInformationTypeAround] ){
        self.headerView =  [[[NSBundle mainBundle] loadNibNamed:@"RecommendNewsHeaderView" owner:self options:nil] objectAtIndex:0];
        [self renderShadow:self.headerView];
        [self.headerView  setInformation:information];
        [self.transparentHeaderView setHideBoard:YES];
    }

    self.imageDict = [NSDictionary getImageLinkDictInJsonString:information.images];
    _information = information;
}

-(void) setStar:(Star *)star
{
    self.headerView =  [[[NSBundle mainBundle] loadNibNamed:@"StarHeaderView" owner:self options:nil] objectAtIndex:0];
    [self renderShadow:self.headerView];
    [self.headerView setStar:star];
    [self.transparentHeaderView setHideBoard:YES];
    self.imageDict = [NSDictionary getImageLinkDictInJsonString:star.images];
    _star = star;
}

#pragma mark - LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self autolayout];
    [self configureTableView];
    UISwipeGestureRecognizer *leftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goBack:)];
    leftGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:leftGesture];
    if ( self.event ) {
        self.currentCell.textView.text = self.event.detail;
        [self configureCurrentCell];
    } else if ( self.information ) {
        self.currentCell.textView.text = self.information.context;
        [self configureCurrentCell];
    } else if ( self.star ) {
        self.currentCell.textView.text = self.star.detail;
        [self configureCurrentCell];
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidUnload
{
    [self setBackButton:nil];
    [self setNewsTableView:nil];
    [self setButtonBackImageView:nil];
    [self setBackButton:nil];
    [super viewDidUnload];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - IBAction
- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    static int velocity = 15;
    
    float rate = (scrollView.contentOffset.y + kContentOffset) / -kRowHeight;
    
    if ( rate < -3 && !_isBackGroundHide && !self.isAnimationFinished )
    {
        _isBackGroundHide = YES;
        [UIView animateWithDuration:0.25f animations:^
        {
            [self.buttonBackImageView setAlpha:0.0f];
            CGPoint center = [self.newsTableView center];
            center.y = center.y - (self.headerView.bounds.size.height - kContentOffset);
            [self.newsTableView setCenter:center];
            
            CGRect buttonFrame = self.backButton.frame;
            buttonFrame.origin.x = kCurrent;
            buttonFrame.origin.y = kCurrent;
            self.backButton.frame = buttonFrame;
            
            [self.headerView changeButtonPositionToLeft];
        }
        completion:^(BOOL isFinished){}];
        
        return ;
    }
    if ( rate > -3 && rate < 1 && _isBackGroundHide && !self.isAnimationFinished )
    {
        _isBackGroundHide = NO;
        [UIView animateWithDuration:0.25f animations:^
        {
            [self.buttonBackImageView setAlpha:1.0f];
            CGPoint center = [self.newsTableView center];
            center.y = center.y + (self.headerView.bounds.size.height - kContentOffset);
            [self.newsTableView setCenter:center];
            
            CGRect buttonFrame = self.backButton.frame;
            buttonFrame.origin.x = kOrigin;
            buttonFrame.origin.y = kOrigin;
            self.backButton.frame = buttonFrame;
            
            [self.headerView resetButtonPosition];
        }
        completion:^(BOOL isFinished){}];
    }
    if (rate > 1 && _haveImages) {
        self.isAnimationFinished = true;
        self.newsTableView.userInteractionEnabled = NO;
        [[UIApplication sharedApplication] nj_setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        [UIView animateWithDuration:0.25f animations:^{
            [self.view setFrame: [[UIScreen mainScreen] bounds]];
            self.newsTableView.frame = CGRectMake(0, self.view.frame.size.height, self.newsTableView.frame.size.width, self.newsTableView.frame.size.height);
            self.pageViewController.view.frame = CGRectMake(0,0, self.pageViewController.view.frame.size.width, self.pageViewController.view.frame.size.height);
            [self.backButton setAlpha:0.0];
            [self.buttonBackImageView setAlpha:0.0];
        } completion:^(BOOL finished) {
            self.pageViewController.view.userInteractionEnabled = YES;
        }];
    }
    else
    if (self.isAnimationFinished == false)
    {
        self.pageViewController.view.frame = CGRectMake(0, kStateY + velocity * rate, self.pageViewController.view.frame.size.width, self.pageViewController.view.frame.size.height);
    }
}



#pragma mark - UITableViewDataSource

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ( section == 1 ) return self.headerView.bounds.size.height;
    if ( section == 0 ) return self.transparentHeaderView.bounds.size.height;
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ( section == 1 ) return self.headerView;
    if ( section == 0 ) return self.transparentHeaderView;
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1 )
    {
        if ( self.information && [self.information.category isEqualToString:GetInformationTypeAround])
            return 4;
        return 1;
    }
    return 0;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == 1 )
    {
        if ( self.information && [self.information.category isEqualToString:GetInformationTypeAround] &&indexPath.row == 0 )
        {
            if ([self.information.location isEqualToString:[NSString stringWithFormat:@"%@",[NSNull null]]])
                return 0;
            return 60;
        }
        if ( self.information && [self.information.category isEqualToString:GetInformationTypeAround] &&indexPath.row == 1 )
        {
            if ([self.information.contact isEqualToString:[NSString stringWithFormat:@"%@",[NSNull null]]])
                return 0;
            return 40;
        }
        if ( self.information && [self.information.category isEqualToString:GetInformationTypeAround] &&indexPath.row == 2 )
        {
            if ([self.information.ticketService isEqualToString:[NSString stringWithFormat:@"%@",[NSNull null]]])
                return 0;
            return 60;
        }
        return self.currentCell.frame.size.height;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( self.information && [self.information.category isEqualToString:GetInformationTypeAround])
        if ( indexPath.section == 1 && indexPath.row < 3 )
        {
            UITableViewCell * cell;
            switch (indexPath.row) {
                case 0:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"SchoolNewsLocationCell"];
                    if ( cell == nil )
                        cell = [[SchoolNewsLocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SchoolNewsLocationCell"];
                    ((SchoolNewsLocationCell *)cell).location.text = self.information.location;
                    if ( [self.information.location isEqualToString:[NSString stringWithFormat:@"%@",[NSNull null]]])
                        [cell setHidden:YES];
                    break;
                case 1:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"SchoolNewsContactCell"];
                    if ( cell == nil )
                        cell = [[SchoolNewsContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SchoolNewsContactCell"];
                    ((SchoolNewsContactCell *)cell).contact.text = self.information.contact;
                    if ( [self.information.contact isEqualToString:[NSString stringWithFormat:@"%@",[NSNull null]]])
                        [cell setHidden:YES];
                    break;
                case 2:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"SchoolNewsTicketCell"];
                    if ( cell == nil )
                        cell = [[SchoolNewsTicketCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SchoolNewsTicketCell"];
                    ((SchoolNewsTicketCell *)cell).ticket.text = self.information.ticketService;
                    if ( [self.information.ticketService isEqualToString:[NSString stringWithFormat:@"%@",[NSNull null]]])
                        [cell setHidden:YES];
                    break;
                default:
                    break;
            }
            return cell;
        }
    return self.currentCell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ( indexPath.section == 1 && self.information && [self.information.category isEqualToString:GetInformationTypeAround] )
    {
        switch (indexPath.row)
        {
            case 0:
                [self showLocation:self.information.location];
                break;
            case 1:
                [self makeCall:self.information.contact];
                break;
            case 2:
                break;
            default:
                break;
        }
    }
}

-(void) showLocation:(NSString *) location
{
    UIMapApplicationSheet * actionSheet = [[UIMapApplicationSheet alloc] initWithLocation:location];
    [actionSheet showInView:self.view];
}

-(void) makeCall:(NSString *)phoneNumber
{
    UIPhoneCallActionSheet * actionSheet = [[UIPhoneCallActionSheet alloc] initWithPhoneNumber:phoneNumber];
    [actionSheet showInView:self.view];
}

@end
