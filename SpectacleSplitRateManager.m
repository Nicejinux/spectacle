//
//  SpectacleSplitRateManager.m
//  Spectacle
//
//  Created by Nicejinux on 2014. 1. 19..
//
//

#import "SpectacleSplitRateManager.h"
#import "SpectacleConstants.h"

@interface SpectacleSplitRateManager ()

@property (nonatomic) NSUserDefaults *userDefault;

@end

#pragma mark -

@implementation SpectacleSplitRateManager

- (id)init {
    if ((self = [super init])) {
        _userDefault = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

#pragma mark -

+ (SpectacleSplitRateManager *)sharedManager {
    static SpectacleSplitRateManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

#pragma mark - getters

- (CGSize)registeredSplitRate {
    CGSize splitRate = CGSizeMake([self registeredColSplitRate], [self registeredRowSplitRate]);
    return splitRate;
}

- (NSInteger)registeredColSplitRate {
    NSNumber *colRate = [_userDefault objectForKey:SpectacleColSplitRate];
    if (!colRate) {
        [self registerColSplitRate:SpectacleDefaultSplitRate];
        return SpectacleDefaultSplitRate;
    } else {
        return [colRate integerValue];
    }
}

- (NSInteger)registeredRowSplitRate {
    NSNumber *rowRate = [_userDefault objectForKey:SpectacleRowSplitRate];
    if (!rowRate) {
        [self registerRowSplitRate:SpectacleDefaultSplitRate];
        return SpectacleDefaultSplitRate;
    } else {
        return [rowRate integerValue];
    }
}

#pragma mark - setters

- (void)registerSplitRates:(CGSize)splitRates {
    [self registerColSplitRate:splitRates.width];
    [self registerRowSplitRate:splitRates.height];
}

- (void)registerColSplitRate:(NSInteger)colSplitRate {
    if (colSplitRate > 100 || colSplitRate < 0) {
        colSplitRate = SpectacleDefaultSplitRate;
    }

    [_userDefault setObject:@(colSplitRate) forKey:SpectacleColSplitRate];
    [_userDefault synchronize];
}

- (void)registerRowSplitRate:(NSInteger)rowSplitRate {
    if (rowSplitRate > 100 || rowSplitRate < 0) {
        rowSplitRate = SpectacleDefaultSplitRate;
    }
    
    [_userDefault setObject:@(rowSplitRate) forKey:SpectacleRowSplitRate];
    [_userDefault synchronize];
}


@end
