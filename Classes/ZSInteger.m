//
//  ZSInteger.m
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

#import "ZSInteger.h"


@implementation ZSInteger

@synthesize value;

- (id)initWithValue:(NSInteger)aValue {
	if (self = [super init]) {
		value = aValue;
	}
	return self;
}

- (NSComparisonResult)compare:(ZSInteger *)aZSInteger {
	NSAssert(aZSInteger != nil, @"ZSInteger cannot compare to nil");
	
	if (self.value < aZSInteger.value) {
		return NSOrderedAscending;
	} else if (self.value == aZSInteger.value) {
		return NSOrderedSame;
	} else {
		return NSOrderedDescending;
	}
}


#pragma mark -
#pragma mark NSObject Protocol methods

- (NSUInteger)hash {
	return (NSUInteger)self.value;
}

- (BOOL)isEqual:(id)anObject {
	if (self == anObject) {
		return YES;
	}
	
	if (!anObject) {
		// We know self isn't nil, so return NO
		return NO;
	}
	
	if (![anObject isKindOfClass:[ZSInteger class]]) {
		return NO;
	}
	
	return self.value == ((ZSInteger *)anObject).value;
}


#pragma mark -
#pragma mark NSCopying Protocol methods

- (id)copyWithZone:(NSZone *)zone {
	ZSInteger *newObject = [[ZSInteger allocWithZone:zone] init];
	
	newObject.value = self.value;
	
	return newObject;
}


#pragma mark -
#pragma mark NSCoding methods

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [super init]) {
		value = [coder decodeIntegerForKey:@"ZSInteger.value"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeInteger:self.value forKey:@"ZSInteger.value"];
}

@end
