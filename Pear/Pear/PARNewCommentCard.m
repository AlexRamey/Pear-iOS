//
//  PARNewCommentCard.m
//  Pear
//
//  Created by Alex Ramey on 3/11/15.
//  Copyright (c) 2015 Pear. All rights reserved.
//

#import "PARNewCommentCard.h"

@implementation PARNewCommentCard

- (id)initWithFrame:(CGRect)frame atIndex:(int)index withAuthorName:(NSString *)authorName commentText:(NSString *)commentText
{
    self = [super initWithFrame:frame];
    
    NSArray *backgroundReds = @[@0xEF, @0xD2, @0x66, @0x41, @0x87, @0xE8,
                                @0xBE, @0x81, @0x87, @0xF4, @0xE0];
    
    NSArray *backgroundGreens = @[@0x48, @0x52, @0x33, @0x83, @0xD3, @0x7E,
                                  @0x90, @0xCF, @0xD3, @0xD0, @0x82];
    
    NSArray *backgroundBlues = @[@0x36, @0x7F, @0x99, @0xD7, @0x7C, @0x04,
                                 @0xD4, @0xE0, @0x7C, @0x3F, @0x83];
    
    int i = index % 2;
    
    float initialsDimension = self.frame.size.height;
    
    if (i == 0)
    {
        self.backgroundColor = [UIColor colorWithRed:0xf9 / 255.0 green:0xf9 / 255.0 blue:0xf9 / 255.0 alpha:1.0];
    }
    else
    {
        self.backgroundColor = [UIColor colorWithRed:0xfd / 255.0 green:0xfd / 255.0 blue:0xfd / 255.0 alpha:1.0];
    }
    
    UILabel *initialsLabel = [[UILabel alloc] initWithFrame:CGRectMake(i * (self.frame.size.width - initialsDimension), 0.0, initialsDimension, initialsDimension)];
    [initialsLabel setTextAlignment:NSTextAlignmentCenter];
    [initialsLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:22.0]];
    NSUInteger r = arc4random_uniform(2);
    if (r == 0)
    {
        [initialsLabel setTextColor:[UIColor whiteColor]];
        NSUInteger bc = arc4random_uniform(6);
        [initialsLabel setBackgroundColor:[UIColor colorWithRed:[backgroundReds[bc] intValue] / 255.0 green:[backgroundGreens[bc] intValue] / 255.0 blue:[backgroundBlues[bc] intValue] / 255.0 alpha:1.0]];
    }
    else
    {
        [initialsLabel setTextColor:[UIColor blackColor]];
        NSUInteger bc = arc4random_uniform(5) + 6;
        [initialsLabel setBackgroundColor:[UIColor colorWithRed:[backgroundReds[bc] intValue] / 255.0 green:[backgroundGreens[bc] intValue] / 255.0 blue:[backgroundBlues[bc] intValue] / 255.0 alpha:1.0]];
    }
    
    NSRange spaceRange = [authorName rangeOfString:@" " options:NSBackwardsSearch];
    
    if (spaceRange.location != NSNotFound && authorName.length > spaceRange.location + 1)
    {
        [initialsLabel setText:[[NSString stringWithFormat:@"%@%@", [authorName substringToIndex:1], [authorName substringWithRange:NSMakeRange(spaceRange.location + 1, 1)]] uppercaseString]];
    }
    else
    {
        [initialsLabel setText:[[authorName substringToIndex:1] uppercaseString]];
    }
    
    UITextView *textContainer = [[UITextView alloc] initWithFrame:CGRectMake(((i + 1)%2) * initialsDimension, 0.0, self.frame.size.width - initialsDimension, initialsDimension)];
    [textContainer setEditable:NO];
    [textContainer setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
    [textContainer setTextColor:[UIColor blackColor]];
    [textContainer setText:commentText];
    [textContainer setSelectable:NO];
    [textContainer setBackgroundColor:[UIColor clearColor]];
    
    [self addSubview:initialsLabel];
    [self addSubview:textContainer];
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
