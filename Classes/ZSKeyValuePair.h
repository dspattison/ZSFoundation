//
//  ZSKeyValuePair.h
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
 * This class is usefull for maintaining a 2-tuple of objects.
 * In many cases, we would be forced to create nested dictionarys or arrays to
 * collect pairs of objects.  This class formalizes that pattern into a clearer
 * typing system.
 */
@interface ZSKeyValuePair : NSObject {
@private
	id	key;
	id	value;
}

@property (nonatomic, retain)	id	key;
@property (nonatomic, retain)	id	value;

/**
 * INITIALIZER (DESIGNATED)
 * This initializer will create a ZSKeyValuePair with a given key and value.
 *
 * @param	aKey		The key
 * @param	aValue		The value
 * @return				A ZSKeyValuePair object
 */
- (id)initWithKey:(id)aKey andValue:(id)aValue;

@end
