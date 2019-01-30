/*
 * Copyright 2019 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef FIRESTORE_CORE_SRC_FIREBASE_FIRESTORE_REMOTE_REMOTE_STORE_H_
#define FIRESTORE_CORE_SRC_FIREBASE_FIRESTORE_REMOTE_REMOTE_STORE_H_

#if !defined(__OBJC__)
#error "This header only supports Objective-C++"
#endif  // !defined(__OBJC__)

#import <Foundation/Foundation.h>

#include <memory>
#include <unordered_map>

#include "Firestore/core/src/firebase/firestore/model/snapshot_version.h"
#include "Firestore/core/src/firebase/firestore/model/types.h"
#include "Firestore/core/src/firebase/firestore/remote/online_state_tracker_.h"
#include "Firestore/core/src/firebase/firestore/remote/remote_event.h"
#include "Firestore/core/src/firebase/firestore/remote/watch_change.h"
#include "Firestore/core/src/firebase/firestore/util/status.h"

@class FSTMutationBatchResult;
@class FSTQueryData;

NS_ASSUME_NONNULL_BEGIN

/**
 * A protocol that describes the actions the FSTRemoteStore needs to perform on a cooperating
 * synchronization engine.
 */
@protocol FSTRemoteSyncer

/**
 * Applies one remote event to the sync engine, notifying any views of the changes, and releasing
 * any pending mutation batches that would become visible because of the snapshot version the
 * remote event contains.
 */
- (void)applyRemoteEvent:(const firebase::firestore::remote::RemoteEvent &)remoteEvent;

/**
 * Rejects the listen for the given targetID. This can be triggered by the backend for any active
 * target.
 *
 * @param targetID The targetID corresponding to a listen initiated via
 *     -listenToTargetWithQueryData: on FSTRemoteStore.
 * @param error A description of the condition that has forced the rejection. Nearly always this
 *     will be an indication that the user is no longer authorized to see the data matching the
 *     target.
 */
- (void)rejectListenWithTargetID:(const firebase::firestore::model::TargetId)targetID
                           error:(NSError *)error;

/**
 * Applies the result of a successful write of a mutation batch to the sync engine, emitting
 * snapshots in any views that the mutation applies to, and removing the batch from the mutation
 * queue.
 */
- (void)applySuccessfulWriteWithResult:(FSTMutationBatchResult *)batchResult;

/**
 * Rejects the batch, removing the batch from the mutation queue, recomputing the local view of
 * any documents affected by the batch and then, emitting snapshots with the reverted value.
 */
- (void)rejectFailedWriteWithBatchID:(firebase::firestore::model::BatchId)batchID
                               error:(NSError *)error;

/**
 * Returns the set of remote document keys for the given target ID. This list includes the
 * documents that were assigned to the target when we received the last snapshot.
 */
- (firebase::firestore::model::DocumentKeySet)remoteKeysForTarget:
    (firebase::firestore::model::TargetId)targetId;

@end

namespace firebase {
namespace firestore {
namespace remote {

class RemoteStore {
 public:
  RemoteStore();

  // TODO(varconst): remove
  id<FSTRemoteSyncer> sync_engine() { return sync_engine_; }


  void ListenToTarget(FSTQueryData* query_data);
  void StopListening(model::TargetId target_id);

  // TODO(varconst): all the following member functions should be private.

  void SendWatchRequest(FSTQueryData* query_data);
  void SendUnwatchRequest(model::TargetId target_id);

  void StartWatchStream();
  bool ShouldStartWatchStream() const;

  void CleanUpWatchStreamState();

  void OnWatchStreamOpen();

  void OnWatchStreamChange(const WatchChange& change, const model::SnapshotVersion& snapshot_version);
  void OnWatchStreamError(const util::Status& error);

  /**
  * Takes a batch of changes from the `Datastore`, repackages them as a `RemoteEvent`, and passes that
  * on to the `SyncEngine`.
  */
  void RaiseWatchSnapshot(const model::SnapshotVersion& snapshot_version);

  /** Process a target error and passes the error along to `SyncEngine`. */
  void ProcessTargetError(const WatchTargetChange& change);

  bool CanUseNetwork() const;

 private:
  id<FSTRemoteSyncer> sync_engine_ = nil;

  /**
  * The local store, used to fill the write pipeline with outbound mutations and resolve existence
  * filter mismatches. Immutable after initialization.
  */
  FSTLocalStore* local_store_ = nil;

  OnlineStateTracker online_state_tracker_;

  std::unique_ptr<WatchChangeAggregator> watch_change_aggregator_;

  /**
   * A mapping of watched targets that the client cares about tracking and the
   * user has explicitly called a 'listen' for this target.
   *
   * These targets may or may not have been sent to or acknowledged by the
   * server. On re-establishing the listen stream, these targets should be sent
   * to the server. The targets removed with unlistens are removed eagerly
   * without waiting for confirmation from the listen stream.
   */
  std::unordered_map<model::TargetId, FSTQueryData *> listen_targets_;

  std::shared_ptr<WatchStream> watch_stream_;

  /**
   * Set to true by `EnableNetwork` and false by `DisableNetworkInternal` and
   * indicates the user-preferred network state.
   */
  bool is_network_enabled_ = false;
};

}  // namespace remote
}  // namespace firestore
}  // namespace firebase

NS_ASSUME_NONNULL_END

#endif  // FIRESTORE_CORE_SRC_FIREBASE_FIRESTORE_REMOTE_REMOTE_STORE_H_
