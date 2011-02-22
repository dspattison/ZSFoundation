//
//  TestZSLRUQueueCache.h
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

#import <SenTestingKit/SenTestingKit.h>

@class ZSLRUQueueCache;

@interface TestZSLRUQueueCache : SenTestCase {
    ZSLRUQueueCache		*cache;
}

@property (nonatomic, retain)	ZSLRUQueueCache		*cache;

/**
 * Tests basic storage and removal of items
 */
- (void)testCanStoreObjects;

/**
 * Tests that items are properly prioritized based on LRU
 */
- (void)testLRURemoval;

/**
 * Tests that items are properly re-prioritized based on access
 */
- (void)testLRURemoval2;

/**
 * Tests that disk storage is properly limited
 */
- (void)testDiskLimiting;

/**
 * Tests that in-memory limit is properly adjusted after a low-memory event
 */
- (void)testLowMemoryResizing;

@end
