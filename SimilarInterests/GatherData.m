//
//  GatherData.m
//  SimilarInterests
//
//  Created by Healthhub on 7/30/15.
//  Copyright (c) 2015 Healthhub. All rights reserved.
//

#import "GatherData.h"
@import HealthKit;

@implementation GatherData
+ (void)checkForHealthkit {
    if(NSClassFromString(@"HKHealthStore") && [HKHealthStore isHealthDataAvailable])
    {
        NSLog(@"Healthkit is working");
    }
    else{
        NSLog(@"Healthkit is not working");
    }
}
@end