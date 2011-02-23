//
//  ZSBool.h
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


/**
 * ZSFoundation NSObject wrapper for a BOOL value.
 *
 * @see README for more detailed information
 */
@interface ZSBool : NSObject <NSCopying, NSCoding> {
@private
	BOOL	value;
}

@property (nonatomic)	BOOL	value;

- (id)initWithBool:(BOOL)aValue;
- (NSComparisonResult)compare:(ZSBool *)aZSBool;

@end
