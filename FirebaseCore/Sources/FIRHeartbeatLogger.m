// Copyright 2021 Google
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "FirebaseCore/Sources/Private/FIRHeartbeatLogger.h"

#if SWIFT_PACKAGE
@import HeartbeatLogging;
#else
#import <FirebaseCore/FirebaseCore-Swift.h>
#endif  // SWIFT_PACKAGE

#import "FirebaseCore/Sources/Private/FIRAppInternal.h"

/// <#Description#>
static NSInteger const kFlushLimit = 10;

@interface FIRHeartbeatLogger ()

@property(nonatomic, readonly) FIRInteropHeartbeatLogger *logger;

@end

@implementation FIRHeartbeatLogger

- (instancetype)initWithAppID:(NSString *)appID {
  self = [super init];
  if (self) {
    _logger = [[FIRInteropHeartbeatLogger alloc] initWithId:appID];
  }
  return self;
}

- (void)log {
  [self.logger log:[FIRApp firebaseUserAgent]];
}

- (FIRInteropHeartbeatData *)flush {
  return [self.logger flushWithLimit:kFlushLimit];
}

- (BOOL)assertSwiftInteropWorksOnCI {
  return [self.logger assertSwiftInteropWorksOnCI];
}

@end
