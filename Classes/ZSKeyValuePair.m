//
//  ZSKeyValuePair.m
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

#import "ZSKeyValuePair.h"


@implementation ZSKeyValuePair

@synthesize key, value;

- (id)initWithKey:(id)aKey andValue:(id)aValue {
	if (self = [super init]) {
		key		= [aKey retain];
		value	= [aValue retain];
	}
	return self;
}

- (void)dealloc {
	[key release];
	[value release];
	
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"ZSKeyValuePair: %@ -> %@", self.key, self.value];
}

- (id)copyWithZone:(NSZone *)zone {
	ZSKeyValuePair *copy = [[ZSKeyValuePair allocWithZone:zone] init];
	
	[copy setKey:self.key];
	[copy setValue:self.value];
	
	return copy;
}

- (BOOL)isEqual:(id)anObject {
	if (self == anObject) {
		return YES;
	}
	
	if (![anObject isKindOfClass:[ZSKeyValuePair class]]) {
		return NO;
	}
	
	return [key isEqual:((ZSKeyValuePair *)anObject).key] && [value isEqual:((ZSKeyValuePair *)anObject).value];
}

- (NSUInteger)hash {
	NSUInteger hash = 0;
	hash = (hash * 31) + key != nil ? [key hash] : 0;
	hash = (hash * 31) + value != nil ? [value hash] : 0;
	return hash;
}

@end
