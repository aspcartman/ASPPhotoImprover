//
// Created by ASPCartman on 10/04/15.
// Copyright (c) 2015 aspcartman. All rights reserved.
//

#import "ASPInjector.h"
#import <objc/objc-runtime.h>
@implementation ASPInjector
{
}
+ (void) load
{

	{
		const Class  pObjc_class = NSClassFromString(@"IPXSetFolderSortKey");
		const SEL    pSelector   = NSSelectorFromString(@"initWithFolder:newSortKeyPath:");
		const Method pMethod     = class_getInstanceMethod(pObjc_class, pSelector);
		id(*origIMP)(id, SEL, id, id) = (id (*)(id, SEL, id, id)) method_getImplementation(pMethod);
		method_setImplementation(pMethod, imp_implementationWithBlock(^id(id _s, id folder, id kp) {
			NSLog(@"Set %@", kp);
			return origIMP(_s, pSelector, folder, @"basicProperties.AlbumCreationDate");
		}));
	}

	{
		const Class pObjc_class = NSClassFromString(@"IPXSetAlbumSortKey");
		const SEL pSelector = NSSelectorFromString(@"initWithAlbum:newSortKeyPath:");
		const Method pMethod = class_getInstanceMethod(pObjc_class, pSelector);
		id(*origIMP)(id,SEL,id,id) = (id (*)(id, SEL, id, id)) method_getImplementation(pMethod);
		method_setImplementation(pMethod, imp_implementationWithBlock(^id(id _s, id folder, id kp){
			NSLog(@"Set %@", kp);
			return origIMP(_s, pSelector, folder, kp);
		}));
	}

	{
		NSMutableSet *knownToRespond = [NSMutableSet new];
		const Class pObjc_class = NSClassFromString(@"RDAlbum");
		const SEL pSelector = NSSelectorFromString(@"respondsToSelector:");
		const Method pMethod = class_getInstanceMethod(pObjc_class, pSelector);
		BOOL(*origIMP)(id,SEL,SEL) = (BOOL (*)(id, SEL, SEL)) method_getImplementation(pMethod);
		method_setImplementation(pMethod, imp_implementationWithBlock(^BOOL(id _s, SEL sel){
			BOOL responds = origIMP(_s, pSelector, sel);
			NSString *const string = NSStringFromSelector(sel);
			if (responds && ![knownToRespond containsObject:string])
			{
				[knownToRespond addObject:string];
				NSLog(@"RDAlbum responds to %@", string);
			}
			return responds;
		}));
	}

	NSLog(@"ASP Photo Improver has been loaded.");
}
@end