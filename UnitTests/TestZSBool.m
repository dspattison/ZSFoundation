//
//  TestZSBool.m
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

#import "TestZSBool.h"
#import "ZSBool.h"


@implementation TestZSBool

- (void)testInitialization {
	ZSBool *testBool1 = [[[ZSBool alloc] init] autorelease];
	STAssertTrue(NO == testBool1.value, @"1) Default initializer did not work properly!");
	
	ZSBool *testBool2 = [[[ZSBool alloc] initWithBool:NO] autorelease];
	STAssertTrue(NO == testBool2.value, @"2) Initializing with initial value did not work properly!");
	
	ZSBool *testBool3 = [[[ZSBool alloc] initWithBool:YES] autorelease];
	STAssertTrue(YES == testBool3.value, @"3) Initializing with initial value did not work properly!");
}

- (void)testHashAndEquals {
	ZSBool *testBool1	= [[[ZSBool alloc] initWithBool:NO] autorelease];
	ZSBool *testBool2	= [[[ZSBool alloc] initWithBool:YES] autorelease];
	ZSBool *testBool3	= [[[ZSBool alloc] initWithBool:YES] autorelease];
	
	STAssertTrue(![testBool1 isEqual:testBool2], @"1) isEquals true when should be false!");
	STAssertTrue([testBool2 isEqual:testBool3], @"2) isEquals false when should be true!");
	STAssertTrue([testBool2 hash] == [testBool3 hash], @"3) hash values for equivalent objects not the same!");
}

- (void)testCopy {
	ZSBool *testBool1	= [[[ZSBool alloc] initWithBool:YES] autorelease];
	ZSBool *testBool2	= [testBool1 copy];
	
	STAssertTrue([testBool1 isEqual:testBool2], @"1) Copied object not equal to original!");
}

- (void)testCompare {
	ZSBool *testBool1	= [[[ZSBool alloc] initWithBool:NO] autorelease];
	ZSBool *testBool2	= [[[ZSBool alloc] initWithBool:NO] autorelease];
	ZSBool *testBool3	= [[[ZSBool alloc] initWithBool:YES] autorelease];
	ZSBool *testBool4	= [[[ZSBool alloc] initWithBool:YES] autorelease];
	
	STAssertTrue(NSOrderedSame == [testBool1 compare:testBool2], @"1) Equal objects not NSOrderedSame!");
	STAssertTrue(NSOrderedSame != [testBool1 compare:testBool3], @"2) Non-equal objects NSOrderedSame!");
	STAssertTrue(NSOrderedSame == [testBool3 compare:testBool4], @"3) Equal objects not NSOrderedSame!");
	STAssertTrue(NSOrderedSame != [testBool3 compare:testBool1], @"4) Non-equal objects NSOrderedSame!");
}

- (void)testNSCoding {
	ZSBool *testBool1	= [[[ZSBool alloc] initWithBool:YES] autorelease];
	
	NSMutableData *data			= [NSMutableData data];
	NSKeyedArchiver *archiver	= [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:testBool1 forKey:@"object"];
	[archiver finishEncoding];
	[archiver release];
	
	STAssertTrue([data length] > 0, @"1) Data not encoded!");
	
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	id decodedObject = [unarchiver decodeObjectForKey:@"object"];
	[unarchiver finishDecoding];
	[unarchiver release];
	
	STAssertTrue([testBool1 isEqual:decodedObject], @"2) Encoded and decoded object not equal!");
}

@end
