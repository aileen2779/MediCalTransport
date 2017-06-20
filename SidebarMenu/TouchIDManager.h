

#import <Foundation/Foundation.h>

@interface TouchIDManager : NSObject

+ (void)authenticateUserWithSuccess:(void (^)(BOOL result))successBlock
                            failure:(void (^)(NSError *error))failureBlock;

@end
