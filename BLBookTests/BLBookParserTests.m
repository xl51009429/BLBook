//
//  BLBookParserTests.m
//  BLBook
//
//  Created by bigliang on 2017/3/13.
//  Copyright © 2017年 5i5j. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BLBookParser.h"

@interface BLBookParserTests : XCTestCase

@property (nonatomic, strong) BLBookParser *parser;

@end

@implementation BLBookParserTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.parser = [[BLBookParser alloc]init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    self.parser = nil;
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [BLBookParser parserBookAtPath:@"" deleteWhenSuccess:YES bookId:1];
}
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.

    }];
}

@end
