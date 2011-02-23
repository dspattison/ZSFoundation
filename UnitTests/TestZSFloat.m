//
//  TestZSFloat.m
//
//	Copyright 2011 Zoosk, Inc.
//
//	Licensed under the Apache License, Version 2.0 (the "License");
//	you may not use this file except in compliance with the License.
//	You may obtain a copy of the License at
//
//	http://www.apache.org/licenses/LICENSE-2.0
//
//	Unless required by applicable law or agreed to in writing, software
//	distributed under the License is distributed on an "AS IS" BASIS,
//	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//	See the License for the specific language governing permissions and
//	limitations under the License.
//

#import "TestZSFloat.h"
#import "ZSFloat.h"


@implementation TestZSFloat

- (void)testInitialization {
	ZSFloat *testFloat1 = [[[ZSFloat alloc] init] autorelease];
	STAssertTrue(0.0 == testFloat1.value, @"1) Default initializer did not work properly!");
	
	ZSFloat *testFloat2 = [[[ZSFloat alloc] initWithFloat:0.5] autorelease];
	STAssertTrue(0.5 == testFloat2.value, @"2) Initializing with initial value did not work properly!");
	
	ZSFloat *testFloat3 = [[[ZSFloat alloc] initWithFloat:1.0] autorelease];
	STAssertTrue(1.0 == testFloat3.value, @"3) Initializing with initial value did not work properly!");
}

- (void)testHashAndEquals {
	ZSFloat *testFloat1	= [[[ZSFloat alloc] initWithFloat:2.7] autorelease];
	ZSFloat *testFloat2	= [[[ZSFloat alloc] initWithFloat:4.3] autorelease];
	ZSFloat *testFloat3	= [[[ZSFloat alloc] initWithFloat:4.3] autorelease];
	
	STAssertTrue(![testFloat1 isEqual:testFloat2], @"1) isEquals true when should be false!");
	STAssertTrue([testFloat2 isEqual:testFloat3], @"2) isEquals false when should be true!");
	STAssertTrue([testFloat2 hash] == [testFloat3 hash], @"3) hash values for equivalent objects not the same!");
}

- (void)testCopy {
	ZSFloat *testFloat1	= [[[ZSFloat alloc] initWithFloat:-66.2] autorelease];
	ZSFloat *testFloat2	= [testFloat1 copy];
	
	STAssertTrue([testFloat1 isEqual:testFloat2], @"1) Copied object not equal to original!");
}

- (void)testCompare {
	ZSFloat *testFloat1	= [[[ZSFloat alloc] initWithFloat:6.6] autorelease];
	ZSFloat *testFloat2	= [[[ZSFloat alloc] initWithFloat:6.6] autorelease];
	ZSFloat *testFloat3	= [[[ZSFloat alloc] initWithFloat:332.5] autorelease];
	ZSFloat *testFloat4	= [[[ZSFloat alloc] initWithFloat:332.5] autorelease];
	
	STAssertTrue(NSOrderedSame == [testFloat1 compare:testFloat2], @"1) Equal objects not NSOrderedSame!");
	STAssertTrue(NSOrderedAscending == [testFloat1 compare:testFloat3], @"2) Not NSOrderedAscending when should be!");
	STAssertTrue(NSOrderedSame == [testFloat3 compare:testFloat4], @"3) Equal objects not NSOrderedSame!");
	STAssertTrue(NSOrderedDescending == [testFloat3 compare:testFloat1], @"4) Not NSOrderedDescending when should be!");
}

- (void)testNSCoding {
	ZSFloat *testFloat1	= [[[ZSFloat alloc] initWithFloat:345.6] autorelease];
	
	NSMutableData *data			= [NSMutableData data];
	NSKeyedArchiver *archiver	= [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:testFloat1 forKey:@"object"];
	[archiver finishEncoding];
	[archiver release];
	
	STAssertTrue([data length] > 0, @"1) Data not encoded!");
	
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	id decodedObject = [unarchiver decodeObjectForKey:@"object"];
	[unarchiver finishDecoding];
	[unarchiver release];
	
	STAssertTrue([testFloat1 isEqual:decodedObject], @"2) Encoded and decoded object not equal!");
}

@end
