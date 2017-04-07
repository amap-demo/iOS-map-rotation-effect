//
//  iOS_map_rotation_effectUITests.m
//  iOS-map-rotation-effectUITests
//
//  Created by 翁乐 on 2017/4/7.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface iOS_map_rotation_effectUITests : XCTestCase

@end

@implementation iOS_map_rotation_effectUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    
    XCUIElement *mapElement = [app.otherElements elementMatchingType:XCUIElementTypeOther identifier:@"mamapview"];
    
    [mapElement swipeLeft];
    
    XCUIElement *alert = app.alerts[@"alert"];
    
    NSPredicate *exists = [NSPredicate predicateWithFormat:@"exists == YES"];
    
    [self expectationForPredicate:exists evaluatedWithObject:alert handler:nil];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        NSLog(@"error :%@",error);
        
    }];
    
    BOOL result = YES;
    NSString *text = @"rotation changed";
    
    if (text != nil)
    {
        result = [alert.staticTexts[text] exists];
    }
    
    [alert.buttons[@"OK"] tap];
    
    if (!result) {
        XCTAssertFalse(@"unexpected result");
    }
    
    [mapElement swipeLeft];
    [mapElement swipeLeft];
    [mapElement swipeLeft];
    [mapElement swipeRight];
    [mapElement swipeRight];
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

@end
