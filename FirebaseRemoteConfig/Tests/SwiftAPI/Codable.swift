// Copyright 2021 Google LLC
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

import FirebaseRemoteConfig

import XCTest

/// String constants used for testing.
private enum Constants {
  static let key1 = "Key1"
  static let kirk = "Kirk"
  static let spock = "Spock"
  static let jsonKey = "Recipe"
  static let recipe = [ "Recipe Name": "PB&J",
                       "Ingredients" : [ "bread", "peanut butter", "jelly"],
                        "Cook Time" : 7 ] as [String : AnyHashable]
}

#if compiler(>=5.5) && canImport(_Concurrency)
  @available(iOS 15, tvOS 15, macOS 12, watchOS 8, *)
class CodableTests: APITestBase {
  var console: RemoteConfigConsole!

  override func setUp() {
    super.setUp()
    if APITests.useFakeConfig {
      do {
        let jsonData = try JSONSerialization.data(withJSONObject: Constants.recipe, options: .prettyPrinted)
        fakeConsole.config = [Constants.jsonKey: String(data: jsonData, encoding: .ascii)]
      } catch {
          print("Failed to intialize json data in facke Console \(error.localizedDescription)")
      }
    } else {
      console = RemoteConfigConsole()
      console.updateRemoteConfigValue(Constants.key1, forKey: Constants.spock)
    }
  }

  override func tearDown() {
    super.tearDown()

    // If using RemoteConfigConsole, reset remote config values.
    if !APITests.useFakeConfig {
      console.removeRemoteConfigValue(forKey: Constants.key1)
    }
  }

  func testFetchAndActivate() async throws {
    let status = try await config.fetchAndActivate()
    XCTAssertEqual(status, .successFetchedFromRemote)
    guard let dict = config[Constants.jsonKey].jsonValue as? [String : AnyHashable] else {
      XCTFail("Failed to extract json")
      return
    }
    XCTAssertEqual(dict["Recipe Name"], "PB&J")
    XCTAssertEqual(dict["Ingredients"], [ "bread", "peanut butter", "jelly"])
    XCTAssertEqual(dict["Cook Time"], 7)
    XCTAssertEqual(config[Constants.jsonKey].jsonValue as! [String: AnyHashable], Constants.recipe)
  }
}
#endif
