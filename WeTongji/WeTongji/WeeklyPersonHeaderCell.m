//
//  WeeklyPersonHeaderCell.m
//  WeTongji
//
//  Created by tang zhixiong on 12-11-18.
//
//

#import "WeeklyPersonHeaderCell.h"
#import "NSDictionary+Addition.h"
#import <WeTongjiSDK/WeTongjiSDK.h>

@implementation WeeklyPersonHeaderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) setStar:(Star *)star
{
    [self.avatar setImageWithURL:[NSURL URLWithString:star.avatarLink]];
    self.name.text = star.title;
    self.title.text = star.jobTitle;
    self.summary.text = star.words;
    NSDictionary * imageDict = [NSDictionary getImageLinkDictInJsonString:star.images];
    id key = [imageDict allKeys][0];
    [self.image setImageWithURL:[NSURL URLWithString:imageDict[key]] placeholderImage:[UIImage imageNamed:@"defalut_pic"]];
    _star = star;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
