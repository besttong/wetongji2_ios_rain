//
//  TextViewTableCell.m
//  WeTongji
//
//  Created by Wu Ziqi on 12-11-4.
//
//

#import "TextViewTableCell.h"

@implementation TextViewTableCell
@synthesize textView = _textView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
