#import "DeMarcbenderResizableviewViewProxy.h"
#import "DeMarcbenderResizableviewView.h"
#import "TiUtils.h"

@implementation DeMarcbenderResizableviewViewProxy

- (id)init
{
    return [super init];
}
- (void)_destroy
{
    [super _destroy];
}

- (id)_initWithPageContext:(id<TiEvaluator>)context
{
    return [super _initWithPageContext:context];
}

- (id)_initWithPageContext:(id<TiEvaluator>)context_ args:(NSArray *)args
{
    return [super _initWithPageContext:context_ args:args];
}

- (void)_configure
{
    [super _configure];
}

- (void)_initWithProperties:(NSDictionary *)properties
{
    [super _initWithProperties:properties];
}

- (void)viewWillAttach
{
}

- (void)viewDidAttach
{
        
}

- (void)viewDidDetach
{
}

- (void)viewWillDetach
{
}

@end
