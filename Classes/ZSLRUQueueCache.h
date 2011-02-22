//
//  ZSLRUQueueCache.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 * ZSLRUQueueCache is a least recently used cache with user defined limits.
 *
 * This class must be initialized with the directory to be used for on-disk cache.  It
 * will assume that this directory is only being used for this cache.
 * 
 * You may set limits on the number of items to be stored in memory, and the size in
 * bytes that may be stored on disk.  In both instances, the least recently used items
 * will be ejected from the cache first.
 *
 * There are also options to dynamically reduce the in-memory limits when low memory
 * conditions are encountered.
 *
 * Cached objects must implement the NSCoding protocol in order to be written to disk.
 */
@interface ZSLRUQueueCache : NSObject {
@private
	/**
	 * The directory where cache files will be stored.
	 *
	 * This directory will be created on initialization if it does not exist.
	 * All files in this directory will be managed by the cache, so you should
	 * use a dedicated directory with no other files.
	 * Trailing slash (/) is optional.
	 */
	NSString				*cacheDirectory;
	
	/**
	 * If > 0, memory cache will be limited to this number of items
	 */
	NSUInteger				memoryCountLimit;
	/**
	 * If > 0, disk cache will be limited to this size in Bytes
	 */
	NSUInteger				diskSizeLimit;
	/**
	 * Size in bytes of cache on disk.
	 * If exclusiveDiskCacheUser == YES, this will not result in disk access.  If not, this
	 * method will perform a (expensive!) size summation of items in cache.
	 */
	unsigned long long		diskSize;
	
	/**
	 * If YES, cache will assume that no other ZSLRUQueueCache object is using the disk cache.
	 * It will not bother to recalculate the size of files on disk during every addition resulting
	 * in significant execution time improvements.
	 * WARNING - If this value is NO and something else is using the cache, consistency will be compromised.
	 *
	 * DEFAULT = YES;
	 */
	BOOL					exclusiveDiskCacheUser;
	/**
	 * If YES, this cache will listen for low memory notifications, and clear its in-memory cache.
	 *
	 * DEFAULT = NO;
	 */
	BOOL					shouldClearOnLowMemory;
	/**
	 * If YES, in-memory cache count and size limit will be reduced to a fraction of its
	 * current limit whenever low memory occurs (dictated by ZSLRUQueueCache_DYNAMIC_RESIZE_FACTOR).
	 * Has no effect if shouldClearOnMemory is not also YES.
	 * Has no effect if memoryCountLimit == 0 (unlimited).
	 * Note that this could potentially result in thrashing in extreme low memory situations.  Cache size
	 * will be reduced to 1 at minimum, and if memory is still an issue at that point, cache misses will
	 * be nearly 100%.
	 *
	 * DEFAULT = NO;
	 */
	BOOL					shouldReduceCacheOnLowMemory;

	// The following variables are for internal use
	NSMutableDictionary		*memoryCache;
	NSMutableArray			*keyQueue;
}

@property (nonatomic, copy)		NSString				*cacheDirectory;

@property (nonatomic)			NSUInteger				memoryCountLimit;
@property (nonatomic)			NSUInteger				diskSizeLimit;
@property (nonatomic, readonly)	unsigned long long		diskSize;

@property (nonatomic)			BOOL					exclusiveDiskCacheUser;
@property (nonatomic)			BOOL					shouldClearOnLowMemory;
@property (nonatomic)			BOOL					shouldReduceCacheOnLowMemory;

+ (NSString *)diskFilenameForCacheKey:(id)aKey;

/**
 * INITIALIZER
 * This initializer will create a ZSLRUQueueCache with no limits on items in memory or on disk.
 *
 * @param	aCacheDirectory		The path to cache files on disk
 * @return						A ZSLRUQueueCache object
 */
- (id)initWithCacheDirectory:(NSString *)aCacheDirectory;

/**
 * INITIALIZER (DESIGNATED)
 * This initializer will create a ZSLRUQueueCache with limits on the numbers of items in
 * memory and on disk.
 * Settings either value to 0 will make the count unlimited.
 *
 * @param	aCacheDirectory		The path to cache files on disk
 * @param	memoryLimit			The maximum number of items to keep in memory
 * @param	diskLimit			The maximum size of items to keep on disk
 * @return						A ZSLRUQueueCache object
 */
- (id)initWithCacheDirectory:(NSString *)aCacheDirectory memoryCountLimit:(NSUInteger)memoryLimit diskSizeLimit:(NSUInteger)diskLimit;

- (NSUInteger)countInMemory;

- (id<NSCoding>)objectForKey:(id)aKey;

- (void)setObject:(id<NSCoding>)anObject forKey:(id)aKey;

- (void)removeAllObjectsFromMemory;

- (void)removeAllObjectsFromDisk;

@end
