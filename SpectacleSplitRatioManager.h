//
//  SpectacleSplitRatioManager.h
//  Spectacle
//
//  Created by Nicejinux on 2014. 1. 19..
//
//

#import <Foundation/Foundation.h>

@interface SpectacleSplitRatioManager : NSObject

+ (SpectacleSplitRatioManager *)sharedManager;

#pragma mark - gatter

- (CGSize)registeredSplitSize;
- (NSInteger)registeredColSplitValue;
- (NSInteger)registeredRowSplitValue;

- (CGFloat)registeredColSplitRatioLeft;
- (CGFloat)registeredColSplitRatioRight;
- (CGFloat)registeredRowSplitRatioTop;
- (CGFloat)registeredRowSplitRatioBottom;

#pragma mark - setter

- (void)registerSplitSize:(CGSize)splitSize;
- (void)registerColSplitValue:(NSInteger)colSplitValue;
- (void)registerRowSplitValue:(NSInteger)rowSplitValue;

@end
