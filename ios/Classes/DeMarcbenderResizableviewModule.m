/**
 * titanium-resizableview
 *
 * Created by Your Name
 * Copyright (c) 2021 Your Company. All rights reserved.
 */

#import "DeMarcbenderResizableviewModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@implementation DeMarcbenderResizableviewModule

#pragma mark Internal

// This is generated for your module, please do not change it
- (id)moduleGUID
{
  return @"96bc7218-a4b6-4c8e-ad40-3b54d94e6712";
}

// This is generated for your module, please do not change it
- (NSString *)moduleId
{
  return @"de.marcbender.resizableview";
}

#pragma mark Lifecycle

- (void)startup
{
  // This method is called when the module is first loaded
  // You *must* call the superclass
  [super startup];
  DebugLog(@"[DEBUG] %@ loaded", self);
}

#pragma Public APIs

- (NSString *)example:(id)args
{
  // Example method. 
  // Call with "MyModule.example(args)"
  return @"hello world";
}

- (NSString *)exampleProp
{
  // Example property getter. 
  // Call with "MyModule.exampleProp" or "MyModule.getExampleProp()"
  return @"Titanium rocks!";
}

- (void)setExampleProp:(id)value
{
  // Example property setter. 
  // Call with "MyModule.exampleProp = 'newValue'" or "MyModule.setExampleProp('newValue')"
}

@end
