//
//  TestZSInteger.m
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

#import "TestZSInteger.h"
#import "ZSInteger.h"


@implementation TestZSInteger

- (void)testInitialization {
	ZSInteger *testInteger1 = [[[ZSInteger alloc] init] autorelease];
	STAssertTrue(0 == testInteger1.value, @"1) Default initializer did not work properly!");
	
	ZSInteger *testInteger2 = [[[ZSInteger alloc] initWithInteger:-56] autorelease];
	STAssertTrue(-56 == testInteger2.value, @"2) Initializing with initial value did not work properly!");
	
	ZSInteger *testInteger3 = [[[ZSInteger alloc] initWithInteger:2] autorelease];
	STAssertTrue(2 == testInteger3.value, @"3) Initializing with initial value did not work properly!");
}

- (void)testHashAndEquals {
	ZSInteger *testInteger1	= [[[ZSInteger alloc] initWithInteger:1] autorelease];
	ZSInteger *testInteger2	= [[[ZSInteger alloc] initWithInteger:5] autorelease];
	ZSInteger *testInteger3	= [[[ZSInteger alloc] initWithInteger:5] autorelease];
	
	STAssertTrue(![testInteger1 isEqual:testInteger2], @"1) isEquals true when should be false!");
	STAssertTrue([testInteger2 isEqual:testInteger3], @"2) isEquals false when should be true!");
	STAssertTrue([testInteger2 hash] == [testInteger3 hash], @"3) hash values for equivalent objects not the same!");
}

- (void)testCopy {
	ZSInteger *testInteger1	= [[[ZSInteger alloc] initWithInteger:-346] autorelease];
	ZSInteger *testInteger2	= [testInteger1 copy];
	
	STAssertTrue([testInteger1 isEqual:testInteger2], @"1) Copied object not equal to original!");
}

- (void)testCompare {
	ZSInteger *testInteger1	= [[[ZSInteger alloc] initWithInteger:45] autorelease];
	ZSInteger *testInteger2	= [[[ZSInteger alloc] initWithInteger:45] autorelease];
	ZSInteger *testInteger3	= [[[ZSInteger alloc] initWithInteger:7657] autorelease];
	ZSInteger *testInteger4	= [[[ZSInteger alloc] initWithInteger:7657] autorelease];
	
	STAssertTrue(NSOrderedSame == [testInteger1 compare:testInteger2], @"1) Equal objects not NSOrderedSame!");
	STAssertTrue(NSOrderedAscending == [testInteger1 compare:testInteger3], @"2) Not NSOrderedAscending when should be!");
	STAssertTrue(NSOrderedSame == [testInteger3 compare:testInteger4], @"3) Equal objects not NSOrderedSame!");
	STAssertTrue(NSOrderedDescending == [testInteger3 compare:testInteger1], @"4) Not NSOrderedDescending when should be!");
}

- (void)testNSCoding {
	ZSInteger *testInteger1	= [[[ZSInteger alloc] initWithInteger:-45645] autorelease];
	
	NSMutableData *data			= [NSMutableData data];
	NSKeyedArchiver *archiver	= [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:testInteger1 forKey:@"object"];
	[archiver finishEncoding];
	[archiver release];
	
	STAssertTrue([data length] > 0, @"1) Data not encoded!");
	
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	id decodedObject = [unarchiver decodeObjectForKey:@"object"];
	[unarchiver finishDecoding];
	[unarchiver release];
	
	STAssertTrue([testInteger1 isEqual:decodedObject], @"2) Encoded and decoded object not equal!");
}

@end