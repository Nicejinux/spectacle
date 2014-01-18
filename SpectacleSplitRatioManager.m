//
//  SpectacleSplitRatioManager.m
//  Spectacle
//
//  Created by Nicejinux on 2014. 1. 19..
//
//

#import "SpectacleSplitRatioManager.h"
#import "SpectacleConstants.h"

@interface SpectacleSplitRatioManager ()

@property (nonatomic) NSUserDefaults *userDefault;

@end

#pragma mark -

@implementation SpectacleSplitRatioManager

- (id)init {
    if ((self = [super init])) {
        _userDefault = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

#pragma mark -

+ (SpectacleSplitRatioManager *)sharedManager {
    static SpectacleSplitRatioManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

#pragma mark - getters

- (CGSize)registeredSplitSize {
    CGSize splitRate = CGSizeMake([self registeredColSplitValue], [self registeredRowSplitValue]);
    return splitRate;
}

- (NSInteger)registeredColSplitValue {
    NSNumber *colRate = [_userDefault objectForKey:SpectacleColSplitRate];
    if (!colRate) {
        [self registerColSplitValue:SpectacleDefaultSplitRate];
        return SpectacleDefaultSplitRate;
    } else {
        return [colRate integerValue];
    }
}

- (NSInteger)registeredRowSplitValue {
    NSNumber *rowRate = [_userDefault objectForKey:SpectacleRowSplitRate];
    if (!rowRate) {
        [self registerRowSplitValue:SpectacleDefaultSplitRate];
        return SpectacleDefaultSplitRate;
    } else {
        return [rowRate integerValue];
    }
}

- (CGFloat)registeredColSplitRatioLeft {
    NSInteger value = [self registeredColSplitValue];
    CGFloat ratio = value / 100.0f;
    
    return ratio;
}

- (CGFloat)registeredColSplitRatioRight {
    return 1.0f - [self registeredColSplitRatioLeft];
}

- (CGFloat)registeredRowSplitRatioTop {
    NSInteger value = [self registeredRowSplitValue];
    CGFloat ratio = value / 100.0f;
    
    return ratio;
}

- (CGFloat)registeredRowSplitRatioBottom {
    return 1.0f - [self registeredRowSplitRatioTop];
}

#pragma mark - setters

- (void)registerSplitSize:(CGSize)splitSize {
    [self registerColSplitValue:splitSize.width];
    [self registerRowSplitValue:splitSize.height];
}

- (void)registerColSplitValue:(NSInteger)colSplitValue {
    if (colSplitValue > 100 || colSplitValue < 0) {
        colSplitValue = SpectacleDefaultSplitRate;
    }

    [_userDefault setObject:@(colSplitValue) forKey:SpectacleColSplitRate];
    [_userDefault synchronize];
}

- (void)registerRowSplitValue:(NSInteger)rowSplitValue {
    if (rowSplitValue > 100 || rowSplitValue < 0) {
        rowSplitValue = SpectacleDefaultSplitRate;
    }
    
    [_userDefault setObject:@(rowSplitValue) forKey:SpectacleRowSplitRate];
    [_userDefault synchronize];
}


@end
