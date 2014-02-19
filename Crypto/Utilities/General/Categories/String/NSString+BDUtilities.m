//
//  Created by Patrick Hogan/Manuel Zamora 2012
//


////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////
#import "NSString+BDUtilities.h"


////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NSString (BDUtilities)


+ (BOOL)isEmpty:(NSString *)string
{
    return (!string || [string isEqualToString:@""]);
}


+ (NSString *)randomStringWithLength:(NSInteger)length
{
    NSString *alphaLowerCase = @"abcdefghijklmnopqrstuvwxyz";
    NSString *alphaUpperCase = [alphaLowerCase uppercaseString];
    NSString *numbers = @"0123456789";
    
    NSString *selectedSet = [NSString stringWithFormat:@"%@%@%@",alphaLowerCase, alphaUpperCase, numbers];
    NSString *randomString = @"";
    
    NSRange range = NSMakeRange(0, 1);    
    for (int i = 0; i < length; i++)
    {
        range.location = arc4random() % [selectedSet length];
        randomString = [randomString stringByAppendingString:[selectedSet substringWithRange:range]];
    }
    
    return randomString;
}


- (BOOL)containsSubstring:(NSString *)substring
{
    if (substring && [self rangeOfString:substring].location != NSNotFound)
    {
        return YES;
    }
    
    return NO;
}


@end