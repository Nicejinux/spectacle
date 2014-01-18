//
//  SpectacleSplitRateManager.h
//  Spectacle
//
//  Created by Nicejinux on 2014. 1. 19..
//
//

#import <Foundation/Foundation.h>

@interface SpectacleSplitRateManager : NSObject

+ (SpectacleSplitRateManager *)sharedManager;

#pragma mark - gatter

- (CGSize)registeredSplitRate;
- (NSInteger)registeredColSplitRate;
- (NSInteger)registeredRowSplitRate;

#pragma mark - setter

- (void)registerSplitRates:(CGSize)splitRates;
- (void)registerColSplitRate:(NSInteger)colSplitRate;
- (void)registerRowSplitRate:(NSInteger)rowSplitRate;

@end
