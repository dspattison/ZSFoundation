//
//  ZSBool.m
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

#import "ZSBool.h"


@implementation ZSBool

@synthesize value;

- (id)initWithValue:(BOOL)aValue {
	if (self = [super init]) {
		value = aValue;
	}
	return self;
}

- (NSComparisonResult)compare:(ZSBool *)aZSBool {
	NSAssert(aZSBool != nil, @"ZSBool cannot compare to nil");
	
	if (self.value == NO && aZSBool.value == YES) {
		return NSOrderedAscending;
	} else if (self.value == aZSBool.value) {
		return NSOrderedSame;
	} else {
		return NSOrderedDescending;
	}
}


#pragma mark -
#pragma mark NSObject Protocol methods

- (NSUInteger)hash {
	return self.value == NO ? 0 : 1;
}

- (BOOL)isEqual:(id)anObject {
	if (self == anObject) {
		return YES;
	}
	
	if (!anObject) {
		// We know self isn't nil, so return NO
		return NO;
	}
	
	if (![anObject isKindOfClass:[ZSBool class]]) {
		return NO;
	}
	
	return self.value == ((ZSBool *)anObject).value;
}


#pragma mark -
#pragma mark NSCopying Protocol methods

- (id)copyWithZone:(NSZone *)zone {
	ZSBool *newObject = [[ZSBool allocWithZone:zone] init];
	
	newObject.value = self.value;
	
	return newObject;
}


#pragma mark -
#pragma mark NSCoding methods

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [super init]) {
		value = [coder decodeBoolForKey:@"ZSBool.value"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeBool:self.value forKey:@"ZSBool.value"];
}

@end
