//
//  ZSLRUQueueCache.m
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

#import "ZSLRUQueueCache.h"
#import "ZSKeyValuePair.h"


#define ZSLRUQueueCache_DYNAMIC_RESIZE_FACTOR 0.7

@interface ZSLRUQueueCache ()

/**
 * If this object is listening for low memory warnings, this method will be called.
 */
- (void)lowMemoryWarning;
/**
 * Returns the size of the disk cache in bytes.
 * WARNING - This method requires significant disk access
 */
- (unsigned long long)computeDiskCacheSize;
/**
 * Returns an array of ZSKeyValuePairs where the key is the complete file path
 * and the value is an NSDate representing the file's modification date.
 * WARNING - This method requires significant disk access
 */
- (NSArray *)cacheFilesSortedByModifiedDate;
/**
 * Removes items from in-memory cache in excess of memoryCountLimit
 */
- (void)removeMemoryItemsToLimit;
/**
 * Removes items from disk cache until total size < diskSizeLimit
 */
- (void)removeDiskItemsToLimit;

@end


@implementation ZSLRUQueueCache

@synthesize cacheDirectory;
@synthesize memoryCountLimit, diskSizeLimit, diskSize;
@synthesize exclusiveDiskCacheUser, shouldClearOnLowMemory, shouldReduceCacheOnLowMemory;
@synthesize memoryCache, keyQueue;

+ (NSString *)diskFilenameForCacheKey:(id)aKey {
	return [NSString stringWithFormat:@"%d.zslru", [aKey hash]];
}

- (id)init {
	// Does not support default init
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)initWithCacheDirectory:(NSString *)aCacheDirectory {
	if (self = [self initWithCacheDirectory:aCacheDirectory memoryCountLimit:0 diskSizeLimit:0]) {
		exclusiveDiskCacheUser	= YES;
		diskSize				= 0;
		
		keyQueue			= [[NSMutableArray alloc] initWithCapacity:(memoryCountLimit + 1)];
		memoryCache			= [[NSMutableDictionary alloc] initWithCapacity:(memoryCountLimit + 1)];
		
		// Create directory if necessary
		BOOL isDir = NO;
		NSError *error;
		if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory isDirectory:&isDir] && isDir == NO) {
			if (![[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
				// Could not create the directory, fail init
				NSLog(@"Failed to create cache directory for ZSLRUQueueCache");
				[self release];
				return nil;
			}
		} else {
			// Disk cache directory already exists, calculate size
			diskSize = [self computeDiskCacheSize];
		}
	}
	return self;
}

- (id)initWithCacheDirectory:(NSString *)aCacheDirectory memoryCountLimit:(NSUInteger)memoryLimit diskSizeLimit:(NSUInteger)diskLimit {
	if (self = [super init]) {
		cacheDirectory		= [aCacheDirectory copy];
		memoryCountLimit	= memoryLimit;
		diskSizeLimit		= diskLimit;
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[cacheDirectory release];
	
	[memoryCache release];
	[keyQueue release];

	[super dealloc];
}

- (void)setMemoryCountLimit:(NSUInteger)aLimit {
	memoryCountLimit = aLimit;
	
	[self removeMemoryItemsToLimit];
}

- (void)setDiskSizeLimit:(NSUInteger)aLimit {
	diskSizeLimit = aLimit;
	
	[self removeDiskItemsToLimit];
}

- (void)setExclusiveDiskCacheUser:(BOOL)aBool {
	exclusiveDiskCacheUser = aBool;

	if (exclusiveDiskCacheUser) {
		// We need to recalculate our initial running total size
		diskSize = [self computeDiskCacheSize];
	}
}

- (unsigned long long)diskSize {
	if (self.exclusiveDiskCacheUser) {
		return diskSize;
	} else {
		return [self computeDiskCacheSize];
	}

}

- (void)setShouldClearOnLowMemory:(BOOL)aBool {
	shouldClearOnLowMemory = aBool;
	
	if (shouldClearOnLowMemory) {
		// Start listening for low memory warnings
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(lowMemoryWarning)
													 name:UIApplicationDidReceiveMemoryWarningNotification
												   object:nil];
	} else {
		// Stop listening for low memory warnings
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	}
}

- (void)lowMemoryWarning {
	// Clear our in-memory cache
	[self removeAllObjectsFromMemory];
	
	// Resize our in-memory cache if appropriate
	if (self.shouldReduceCacheOnLowMemory) {
		self.memoryCountLimit = (NSUInteger)ceil(self.memoryCountLimit * ZSLRUQueueCache_DYNAMIC_RESIZE_FACTOR);
	}
}

- (unsigned long long)computeDiskCacheSize {
	unsigned long long recomputedCacheSize = 0;
	
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.cacheDirectory error:nil];
	for (NSString *file in files) {
		NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.cacheDirectory stringByAppendingPathComponent:file] error:nil];
		if (![[fileAttributes fileType] isEqualToString:NSFileTypeDirectory]) {
			recomputedCacheSize += [fileAttributes fileSize];
		}
	}
	
	return recomputedCacheSize;
}

- (NSArray *)cacheFilesSortedByModifiedDate {
	NSArray *files				= [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.cacheDirectory error:nil];
	NSMutableArray *pairArray	= [NSMutableArray arrayWithCapacity:[files count]];
	
	// Go through the files and create ZSKeyValuePairs
	for (NSString *file in files) {
		NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.cacheDirectory stringByAppendingPathComponent:file] error:nil];
		if (![[fileAttributes fileType] isEqualToString:NSFileTypeDirectory]) {
			[pairArray addObject:[[[ZSKeyValuePair alloc] initWithKey:[self.cacheDirectory stringByAppendingPathComponent:file] andValue:[fileAttributes fileModificationDate]] autorelease]];
		}
	}
	
	// Sort by value (modified date) descending
	NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"value" ascending:NO] autorelease];
	return [pairArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

- (void)removeMemoryItemsToLimit {
	if (self.memoryCountLimit > 0) {
		while ([self.keyQueue count] > self.memoryCountLimit) {
			id keyToRemove = [self.keyQueue objectAtIndex:0];
			[self.keyQueue removeObjectAtIndex:0];
			[self.memoryCache removeObjectForKey:keyToRemove];
		}
	}
}

- (void)removeDiskItemsToLimit {
	if (self.diskSizeLimit == 0) {
		// Unlimited
		return;
	}
	
	// Remove by size
	unsigned long long currentSize	= self.diskSize;
	
	if (currentSize > self.diskSizeLimit) {
		NSArray *cachedFilePairs	= [self cacheFilesSortedByModifiedDate];
		NSUInteger itemIndex		= [cachedFilePairs count] - 1;
		
		while (itemIndex >= 0 && currentSize > self.diskSizeLimit) {
			ZSKeyValuePair *filePair		= (ZSKeyValuePair *)[cachedFilePairs objectAtIndex:itemIndex];
			NSDictionary *fileAttributes	= [[NSFileManager defaultManager] attributesOfItemAtPath:filePair.key error:nil];
			
			if ([[NSFileManager defaultManager] removeItemAtPath:filePair.key error:nil]) {
				// File removed, deduct size
				currentSize -= [fileAttributes fileSize];
			}
			
			itemIndex--;
		}
		
		if (self.exclusiveDiskCacheUser) {
			diskSize = currentSize;
		}
	}
}

- (NSUInteger)countInMemory {
	return [self.keyQueue count];
}

- (id<NSCoding>)objectForKey:(id)aKey {
	if (!aKey) {
		return nil;
	}
	
	// Check memory cache
	id returnObject = [self.memoryCache objectForKey:aKey];
	
	// Update disk cache timestamp
	// NOTE - This might be a bit expensive to perform on every access
	// If performance is a concern, this should probably be profiled, and perhaps
	// removed, threaded, batched, etc.
	[[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObject:[NSDate date] forKey:NSFileModificationDate]
									 ofItemAtPath:[self.cacheDirectory stringByAppendingPathComponent:[ZSLRUQueueCache diskFilenameForCacheKey:aKey]]
											error:nil];
	
	if (returnObject) {
		[self.keyQueue removeObject:aKey];
		[self.keyQueue addObject:aKey];
		
		return returnObject;
	}
	
	// Check disk cache
	NSData *cachedData = [[NSData alloc] initWithContentsOfFile:[self.cacheDirectory stringByAppendingPathComponent:[ZSLRUQueueCache diskFilenameForCacheKey:aKey]]
														options:NSDataReadingUncached
														  error:nil];
	if (cachedData) {
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:cachedData];
		returnObject = [unarchiver decodeObjectForKey:@"object"];
		[unarchiver finishDecoding];
		[unarchiver release];
		
		if (returnObject) {
			// Add back to in-memory cache, and resize if necessary
			[self.memoryCache setObject:returnObject forKey:aKey];
			[self.keyQueue addObject:aKey];
			[self removeMemoryItemsToLimit];
		}
	}
	[cachedData release];
	
	return [[returnObject retain] autorelease];
}

- (void)setObject:(id<NSCoding>)anObject forKey:(id)aKey {
	if (!aKey) {
		@throw [NSException exceptionWithName:@"NSInvalidArgumentException" reason:@"aKey cannot be nil when adding an object to ZSLRUQueueCache!" userInfo:nil];
	} else if (!aKey) {
		@throw [NSException exceptionWithName:@"NSInvalidArgumentException" reason:@"anOjbect cannot be nil when adding an object to ZSLRUQueueCache!" userInfo:nil];
	}
	
	// Add key to queue
	id existingObject = [self.memoryCache objectForKey:aKey];
	if (existingObject) {
		[self.keyQueue removeObject:aKey];
	}
	[self.keyQueue addObject:aKey];
	
	// Add to memory cache
	[self.memoryCache setObject:anObject forKey:aKey];
	
	// Add to disk cache
	NSMutableData *data			= [NSMutableData data];
	NSKeyedArchiver *archiver	= [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:anObject forKey:@"object"];
	[archiver finishEncoding];
	[archiver release];
	
	if ([data writeToFile:[self.cacheDirectory stringByAppendingPathComponent:[ZSLRUQueueCache diskFilenameForCacheKey:aKey]] atomically:YES]) {
		// File written to disk cache successfully - add to diskSize
		if (self.exclusiveDiskCacheUser) {
			NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.cacheDirectory stringByAppendingPathComponent:[ZSLRUQueueCache diskFilenameForCacheKey:aKey]] error:nil];
			diskSize += [fileAttributes fileSize];
		}
	}
	
	// Eject objects if we've overflowed
	[self removeMemoryItemsToLimit];
	[self removeDiskItemsToLimit];
}

- (void)removeAllObjectsFromMemory {
	self.keyQueue		= [[NSMutableArray alloc] initWithCapacity:(self.memoryCountLimit + 1)];
	self.memoryCache	= [[NSMutableDictionary alloc] initWithCapacity:(self.memoryCountLimit + 1)];
}

- (void)removeAllObjectsFromDisk {
	// Remove cache directory
	[[NSFileManager defaultManager] removeItemAtPath:self.cacheDirectory error:nil];
	
	// Recreate cache directory
	if (![[NSFileManager defaultManager] createDirectoryAtPath:self.cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil]) {
		// Could not create the directory
		NSLog(@"Failed to create cache directory for ZSLRUQueueCache in removeAllObjectsFromDisk");
	}
	
	diskSize = 0;
}

@end
