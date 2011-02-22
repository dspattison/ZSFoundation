//
//  TestZSLRUQueueCache.m
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

#import "TestZSLRUQueueCache.h"
#import "TestUtility.h"
#import "ZSLRUQueueCache.h"


@implementation TestZSLRUQueueCache

@synthesize cache;

- (void)setUp {
    self.cache = [[[ZSLRUQueueCache alloc] initWithCacheDirectory:[[TestUtility cachePath] stringByAppendingPathComponent:@"lruCache"]] autorelease];
	[self.cache removeAllObjectsFromDisk];
}

- (void)tearDown {
    self.cache = nil;
}

- (void)dealloc {
	[cache release];
	
	[super dealloc];
}

- (UIImage *)imageFromResource:(NSString *)filename {
	NSString *imagePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:filename];
    return [[[UIImage alloc] initWithContentsOfFile:imagePath] autorelease];
}

- (NSData *)helperDataForResourceName:(NSString *)imageName {
    UIImage *image = [self imageFromResource:imageName];
	STAssertNotNil(image, @"Image not loaded!");
	NSData *imageData = UIImagePNGRepresentation(image);
	STAssertNotNil(imageData, @"PNG NSData could not be generated from image!");
	
	return imageData;
}

- (void)testCanStoreObjects {
	// Load image
	NSData *imageData = [self helperDataForResourceName:@"gtm.png"];
	
	// Test basic storage
	[self.cache setObject:imageData forKey:@"object1"];
	STAssertNotNil([self.cache objectForKey:@"object1"], @"1) Cached object could not be retrieved!");
	STAssertTrue(1 == [self.cache countInMemory], @"2) Count of objects in memory incorrect: %d", [self.cache countInMemory]);

	// Test that disk backup is working
	[self.cache removeAllObjectsFromMemory];
	STAssertTrue(0 == [self.cache countInMemory], @"3) Count of objects in memory incorrect: %d", [self.cache countInMemory]);
	STAssertNotNil([self.cache objectForKey:@"object1"], @"4) Cached object could not be retrieved from disk!");
}

- (void)testLRURemoval {
	// Set an in-memory limit
	self.cache.memoryCountLimit = 2;
	
	// Load images
	NSData *imageData1 = [self helperDataForResourceName:@"gtm copy 1.png"];
	NSData *imageData2 = [self helperDataForResourceName:@"gtm copy 2.png"];
	NSData *imageData3 = [self helperDataForResourceName:@"gtm copy 3.png"];
	
	// Store object1
	[self.cache setObject:imageData1 forKey:@"object1"];
	STAssertTrue(1 == [self.cache countInMemory], @"1) Count of objects in memory incorrect: %d", [self.cache countInMemory]);
	
	// Store object2
	[self.cache setObject:imageData2 forKey:@"object2"];
	STAssertTrue(2 == [self.cache countInMemory], @"2) Count of objects in memory incorrect: %d", [self.cache countInMemory]);
	
	// Store object3 - This should eject object1
	[self.cache setObject:imageData3 forKey:@"object3"];
	STAssertTrue(2 == [self.cache countInMemory], @"3) Count of objects in memory incorrect: %d", [self.cache countInMemory]);
	
	// If we clear the disk cache, object3 should be gone
	[self.cache removeAllObjectsFromDisk];
	STAssertNil([self.cache objectForKey:@"object1"], @"4) Object 1 not ejected from memory cache properly");
	STAssertNotNil([self.cache objectForKey:@"object2"], @"5) Object 2 improperly ejected from memory cache");
	STAssertNotNil([self.cache objectForKey:@"object3"], @"6) Object 3 improperly ejected from memory cache");
}

- (void)testLRURemoval2 {
	// Set an in-memory limit
	self.cache.memoryCountLimit = 2;
	
	// Load images
	NSData *imageData1 = [self helperDataForResourceName:@"gtm copy 1.png"];
	NSData *imageData2 = [self helperDataForResourceName:@"gtm copy 2.png"];
	NSData *imageData3 = [self helperDataForResourceName:@"gtm copy 3.png"];
	
	// Store object1
	[self.cache setObject:imageData1 forKey:@"object1"];
	STAssertTrue(1 == [self.cache countInMemory], @"1) Count of objects in memory incorrect: %d", [self.cache countInMemory]);
	
	// Store object2
	[self.cache setObject:imageData2 forKey:@"object2"];
	STAssertTrue(2 == [self.cache countInMemory], @"2) Count of objects in memory incorrect: %d", [self.cache countInMemory]);
	
	// Access object1 - This should move object1 back ahead of object2 in our queue
	STAssertNotNil([self.cache objectForKey:@"object1"], @"3) object1 could not be retrieved!");
	
	// Store object3 - This should eject object2
	[self.cache setObject:imageData3 forKey:@"object3"];
	STAssertTrue(2 == [self.cache countInMemory], @"4) Count of objects in memory incorrect: %d", [self.cache countInMemory]);
	
	// If we clear the disk cache, object3 should be gone
	[self.cache removeAllObjectsFromDisk];
	STAssertNotNil([self.cache objectForKey:@"object1"], @"5) Object 1 improperly ejected from memory cache");
	STAssertNil([self.cache objectForKey:@"object2"], @"6) Object 2 not ejected from memory cache properly");
	STAssertNotNil([self.cache objectForKey:@"object3"], @"7) Object 3 improperly ejected from memory cache");
}

- (void)testDiskLimiting {
	// NOTE - Our test images are 13256 bytes on disk (in simulator on OS X)
	// Set a disk size limit - 30k for error margin
	self.cache.diskSizeLimit = 30000;
	
	// Load images
	NSData *imageData1 = [self helperDataForResourceName:@"gtm copy 1.png"];
	NSData *imageData2 = [self helperDataForResourceName:@"gtm copy 2.png"];
	NSData *imageData3 = [self helperDataForResourceName:@"gtm copy 3.png"];
	
	// Store object1
	[self.cache setObject:imageData1 forKey:@"object1"];
	// Set object1's timestamp back for testing
	[[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObject:[NSDate dateWithTimeIntervalSinceNow:-30.0] forKey:NSFileModificationDate]
									 ofItemAtPath:[self.cache.cacheDirectory stringByAppendingPathComponent:[ZSLRUQueueCache diskFilenameForCacheKey:@"object1"]]
											error:nil];
	STAssertTrue(1 == [self.cache countInMemory], @"1) Count of objects in memory incorrect: %d", [self.cache countInMemory]);
	unsigned long long diskSize1 = self.cache.diskSize;
	STAssertTrue(0 < diskSize1, @"2) Size of objects on disk not correct!");
	
	// Store object2
	[self.cache setObject:imageData2 forKey:@"object2"];
	// Set object2's timestamp back for testing
	[[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObject:[NSDate dateWithTimeIntervalSinceNow:-10.0] forKey:NSFileModificationDate]
									 ofItemAtPath:[self.cache.cacheDirectory stringByAppendingPathComponent:[ZSLRUQueueCache diskFilenameForCacheKey:@"object2"]]
											error:nil];
	STAssertTrue(2 == [self.cache countInMemory], @"3) Count of objects in memory incorrect: %d", [self.cache countInMemory]);
	unsigned long long diskSize2 = self.cache.diskSize;
	STAssertTrue(diskSize1 < diskSize2, @"4) Size of objects on disk did not increase!");
	
	// Store object3 - This should eject object2
	[self.cache setObject:imageData3 forKey:@"object3"];
	STAssertTrue(3 == [self.cache countInMemory], @"5) Count of objects in memory incorrect: %d", [self.cache countInMemory]);
	unsigned long long diskSize3 = self.cache.diskSize;
	STAssertTrue(diskSize2 == diskSize3, @"6) Disk cache size not properly restricted!");
	
	// If we clear memory cache, object1 should be gone
	[self.cache removeAllObjectsFromMemory];
	STAssertNil([self.cache objectForKey:@"object1"], @"7) Object 1 not ejected from disk cache properly");
	STAssertNotNil([self.cache objectForKey:@"object2"], @"8) Object 2 improperly ejected from disk cache");
	STAssertNotNil([self.cache objectForKey:@"object3"], @"9) Object 3 improperly ejected from disk cache");
	
	// Assert that disk size limit did not change
	STAssertTrue(30000 == self.cache.diskSizeLimit, @"Disk size limit should not have changed! Was %d", self.cache.diskSizeLimit);
}

- (void)testLowMemoryResizing {
	// Set an in-memory limit
	self.cache.memoryCountLimit = 4;
	self.cache.shouldClearOnLowMemory		= YES;
	self.cache.shouldReduceCacheOnLowMemory	= YES;
	
	// Load images
	NSData *imageData1 = [self helperDataForResourceName:@"gtm copy 1.png"];
	NSData *imageData2 = [self helperDataForResourceName:@"gtm copy 2.png"];
	NSData *imageData3 = [self helperDataForResourceName:@"gtm copy 3.png"];
	
	// Store object1
	[self.cache setObject:imageData1 forKey:@"object1"];
	STAssertTrue(1 == [self.cache countInMemory], @"1) Count of objects in memory incorrect: %d", [self.cache countInMemory]);

	// Store object2
	[self.cache setObject:imageData2 forKey:@"object2"];
	STAssertTrue(2 == [self.cache countInMemory], @"2) Count of objects in memory incorrect: %d", [self.cache countInMemory]);

	// Store object3
	[self.cache setObject:imageData3 forKey:@"object3"];
	STAssertTrue(3 == [self.cache countInMemory], @"3) Count of objects in memory incorrect: %d", [self.cache countInMemory]);
	
	// Fake a low memory event
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UIApplicationDidReceiveMemoryWarningNotification object:nil]];
	
	// Assert that objects are gone from memory, and limit has been resized
	STAssertEquals(0U, [self.cache countInMemory], @"Count in memory should be 0");
	STAssertEquals(3U, self.cache.memoryCountLimit, @"Memory limit not resized!");
}

@end
