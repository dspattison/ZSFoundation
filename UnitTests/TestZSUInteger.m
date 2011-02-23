//
//  TestZSUInteger.m
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

#import "TestZSUInteger.h"
#import "ZSUInteger.h"


@implementation TestZSUInteger

- (void)testInitialization {
	ZSUInteger *testUInteger1 = [[[ZSUInteger alloc] init] autorelease];
	STAssertTrue(0 == testUInteger1.value, @"1) Default initializer did not work properly!");
	
	ZSUInteger *testUInteger2 = [[[ZSUInteger alloc] initWithUInteger:1] autorelease];
	STAssertTrue(1 == testUInteger2.value, @"2) Initializing with initial value did not work properly!");
	
	ZSUInteger *testUInteger3 = [[[ZSUInteger alloc] initWithUInteger:2] autorelease];
	STAssertTrue(2 == testUInteger3.value, @"3) Initializing with initial value did not work properly!");
}

- (void)testHashAndEquals {
	ZSUInteger *testUInteger1	= [[[ZSUInteger alloc] initWithUInteger:1] autorelease];
	ZSUInteger *testUInteger2	= [[[ZSUInteger alloc] initWithUInteger:5] autorelease];
	ZSUInteger *testUInteger3	= [[[ZSUInteger alloc] initWithUInteger:5] autorelease];
	
	STAssertTrue(![testUInteger1 isEqual:testUInteger2], @"1) isEquals true when should be false!");
	STAssertTrue([testUInteger2 isEqual:testUInteger3], @"2) isEquals false when should be true!");
	STAssertTrue([testUInteger2 hash] == [testUInteger3 hash], @"3) hash values for equivalent objects not the same!");
}

- (void)testCopy {
	ZSUInteger *testUInteger1	= [[[ZSUInteger alloc] initWithUInteger:-346] autorelease];
	ZSUInteger *testUInteger2	= [testUInteger1 copy];
	
	STAssertTrue([testUInteger1 isEqual:testUInteger2], @"1) Copied object not equal to original!");
}

- (void)testCompare {
	ZSUInteger *testUInteger1	= [[[ZSUInteger alloc] initWithUInteger:45] autorelease];
	ZSUInteger *testUInteger2	= [[[ZSUInteger alloc] initWithUInteger:45] autorelease];
	ZSUInteger *testUInteger3	= [[[ZSUInteger alloc] initWithUInteger:7657] autorelease];
	ZSUInteger *testUInteger4	= [[[ZSUInteger alloc] initWithUInteger:7657] autorelease];
	
	STAssertTrue(NSOrderedSame == [testUInteger1 compare:testUInteger2], @"1) Equal objects not NSOrderedSame!");
	STAssertTrue(NSOrderedAscending == [testUInteger1 compare:testUInteger3], @"2) Not NSOrderedAscending when should be!");
	STAssertTrue(NSOrderedSame == [testUInteger3 compare:testUInteger4], @"3) Equal objects not NSOrderedSame!");
	STAssertTrue(NSOrderedDescending == [testUInteger3 compare:testUInteger1], @"4) Not NSOrderedDescending when should be!");
}

- (void)testNSCoding {
	ZSUInteger *testUInteger1	= [[[ZSUInteger alloc] initWithUInteger:45645] autorelease];
	
	NSMutableData *data			= [NSMutableData data];
	NSKeyedArchiver *archiver	= [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:testUInteger1 forKey:@"object"];
	[archiver finishEncoding];
	[archiver release];
	
	STAssertTrue([data length] > 0, @"1) Data not encoded!");
	
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	id decodedObject = [unarchiver decodeObjectForKey:@"object"];
	[unarchiver finishDecoding];
	[unarchiver release];
	
	STAssertTrue([testUInteger1 isEqual:decodedObject], @"2) Encoded and decoded object not equal!");
}
@end
