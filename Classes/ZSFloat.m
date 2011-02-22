//
//  ZSFloat.m
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

#import "ZSFloat.h"


@implementation ZSFloat

@synthesize value;

- (id)initWithValue:(CGFloat)aValue {
	if (self = [super init]) {
		value = aValue;
	}
	return self;
}

- (NSComparisonResult)compare:(ZSFloat *)aZSFloat {
	NSAssert(aZSFloat != nil, @"ZSFloat cannot compare to nil");
	
	if (self.value < aZSFloat.value) {
		return NSOrderedAscending;
	} else if (self.value == aZSFloat.value) {
		return NSOrderedSame;
	} else {
		return NSOrderedDescending;
	}
}


#pragma mark -
#pragma mark NSObject Protocol methods

- (NSUInteger)hash {
	int exponent;
	
#if CGFLOAT_IS_DOUBLE
	double significand = frexp(self.value, &exponent);
#else
	float significand = frexpf(self.value, &exponent);
#endif

	return (NSUInteger)(NSUIntegerMax * (significand * 2.0 - 1.0));
}

- (BOOL)isEqual:(id)anObject {
	if (self == anObject) {
		return YES;
	}
	
	if (!anObject) {
		// We know self isn't nil, so return NO
		return NO;
	}
	
	if (![anObject isKindOfClass:[ZSFloat class]]) {
		return NO;
	}
	
	return self.value == ((ZSFloat *)anObject).value;
}


#pragma mark -
#pragma mark NSCopying Protocol methods

- (id)copyWithZone:(NSZone *)zone {
	ZSFloat *newObject = [[ZSFloat allocWithZone:zone] init];
	
	newObject.value = self.value;
	
	return newObject;
}


#pragma mark -
#pragma mark NSCoding methods

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [super init]) {
		value = [coder decodeFloatForKey:@"ZSFloat.value"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeFloat:self.value forKey:@"ZSFloat.value"];
}

@end
