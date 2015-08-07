//
//  SecondViewController.m
//  SimilarInterests
//
//  Created by Healthhub on 7/29/15.
//  Copyright (c) 2015 Healthhub. All rights reserved.
//

#import "SecondViewController.h"
@import HealthKit;

@interface SecondViewController () 

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Check to make sure the device has healthkit available. Only devices with > iOS 8 can utilize healthkit
    if(NSClassFromString(@"HKHealthStore") && [HKHealthStore isHealthDataAvailable])
    {
        HKHealthStore *healthStore = [[HKHealthStore alloc] init];
        
        NSSet *writeDataTypes = [self dataTypesToWrite];
        NSSet *readDataTypes = [self dataTypesToRead];
        
        //Request user authorization to access their healthkit data. A user can deny a single component without denying the whole request (for example a user could refuse to allow you to read weight)
        [healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
                
                return;
            }
            else{
                
            }
        }];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
        
        NSDate *startDate = [calendar dateFromComponents:components];
        NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
        
        HKSampleType *weightType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
        HKSampleType *calType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
        HKSampleType *stepType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
        
        //Declare the range with which you would like to collect data from. In this case a day
        NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
        
        //Query for the users weight
        HKSampleQuery *weightQuery = [[HKSampleQuery alloc] initWithSampleType:weightType predicate:predicate limit:0 sortDescriptors:nil
                                                          resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
                                                              //You can do (and really should) some error handling here for a more complete app
                                                              if(!error && results)
                                                              {
                                                                  NSLog(@"It has grabbed data");
                                                                  
                                                                  //Only grab the most recent weight measurement
                                                                  if([results count] > 0){
                                                                      HKQuantitySample *sample = results[0];
                                                                      double weightVal = [sample.quantity doubleValueForUnit:[HKUnit poundUnit]];
                                                                      
                                                                      [weight setText:[NSString stringWithFormat:@"%.02f", weightVal]];
                                                                  }
                                                              }
                                                          }];
        //Query for the users calories
        HKSampleQuery *currentCalQuery = [[HKSampleQuery alloc] initWithSampleType:calType predicate:predicate limit:0 sortDescriptors:nil
                                                                resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
                                                                    if(!error && results)
                                                                    {
                                                                        double calories = 0;
                                                                        for (HKQuantitySample *sample in results) {
                                                                            calories += [sample.quantity doubleValueForUnit:[HKUnit calorieUnit]];
                                                                        }
                                                                        
                                                                        [currentCals setText:[NSString stringWithFormat:@"%.02f", calories]];
                                                                                                                                            }
                                                                }];
        //Query for the users steps
        HKSampleQuery *currentStepQuery = [[HKSampleQuery alloc] initWithSampleType:stepType predicate:predicate limit:0 sortDescriptors:nil
                                                                    resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
                                                                        if(!error && results)
                                                                        {
                                                                            double steps = 0;
                                                                            for (HKQuantitySample *sample in results) {
                                                                                steps += [sample.quantity doubleValueForUnit:[HKUnit countUnit]];
                                                                            }
                                                                            
                                                                            [currentSteps setText:[NSString stringWithFormat:@"%.f", steps]];
                                                                                                                                                    }
                                                                    }];
        
        
        [healthStore executeQuery:weightQuery];
        [healthStore executeQuery:currentCalQuery];
        [healthStore executeQuery:currentStepQuery];
    }
    else{
        NSLog(@"Healthkit is not working");
    }
    
}

// Returns the types of data that Fit wishes to write to HealthKit.
- (NSSet *)dataTypesToWrite {
    HKQuantityType *dietaryCalorieEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    return [NSSet setWithObjects:dietaryCalorieEnergyType, activeEnergyBurnType, heightType, weightType, nil];
}

// Returns the types of data that Fit wishes to read from HealthKit.
- (NSSet *)dataTypesToRead {
    HKQuantityType *dietaryCalorieEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKQuantityType *stepCountType  = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    return [NSSet setWithObjects:dietaryCalorieEnergyType, activeEnergyBurnType, weightType, stepCountType, nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
                
@end
