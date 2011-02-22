//
//  ZSFloat.h
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
 * ZSFoundation NSObject wrapper for a CGFloat value
 * WARNING - Be extremely careful using this class. There are a lot of
 * problems with doing comparisons, hashes, etc with floating point values.
 * This is alright to use for non-critical comparisons, but should not be relied
 * upon if accuracy is important.
 *
 * @see README for more detailed information
 */
@interface ZSFloat : NSObject <NSCopying, NSCoding> {
@private
	CGFloat		value;
}

@property (nonatomic)	CGFloat	value;

- (id)initWithValue:(CGFloat)aValue;
- (NSComparisonResult)compare:(ZSFloat *)aZSFloat;

@end
