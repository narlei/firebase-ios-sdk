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

// This file is needed to link in Swift sources (HeartbeatLogging) for
// Firebase Core Unit tests.

// Without it, error "Library not found for `-lswiftSwiftOnoneSupport`" occurs
// when buildiing the Firebase Core Unit tests target with CocoaPods.
