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
import FirebaseRemoteConfigSwift

import XCTest

/// String constants used for testing.
private enum Constants {
  static let jsonKey = "Recipe"
  static let recipe = ["recipeName": "PB&J",
                       "ingredients": ["bread", "peanut butter", "jelly"],
                       "cookTime": 7] as [String: AnyHashable]
}

#if compiler(>=5.5) && canImport(_Concurrency)
  @available(iOS 15, tvOS 15, macOS 12, watchOS 8, *)
  class CodableTests: APITestBase {
    var console: RemoteConfigConsole!

    override func setUp() {
      super.setUp()
      do {
        let jsonData = try JSONSerialization.data(
          withJSONObject: Constants.recipe,
          options: .prettyPrinted
        )
        guard let jsonValue = String(data: jsonData, encoding: .ascii) else {
          fatalError("Failed to make json Value from jsonData")
        }
        if APITests.useFakeConfig {
          fakeConsole.config = [Constants.jsonKey: jsonValue]
        } else {
          console = RemoteConfigConsole()
          console.updateRemoteConfigValue(jsonValue, forKey: Constants.jsonKey)
        }
      } catch {
        print("Failed to initialize json data in fake Console \(error.localizedDescription)")
      }
    }

    override func tearDown() {
      super.tearDown()

      // If using RemoteConfigConsole, reset remote config values.
      if !APITests.useFakeConfig {
        console.removeRemoteConfigValue(forKey: Constants.jsonKey)
      }
    }

    func testFetchAndActivateWithoutCodable() async throws {
      let status = try await config.fetchAndActivate()
      XCTAssertEqual(status, .successFetchedFromRemote)
      guard let dict = config[Constants.jsonKey].jsonValue as? [String: AnyHashable] else {
        XCTFail("Failed to extract json")
        return
      }
      XCTAssertEqual(dict["recipeName"], "PB&J")
      XCTAssertEqual(dict["ingredients"], ["bread", "peanut butter", "jelly"])
      XCTAssertEqual(dict["cookTime"], 7)
      XCTAssertEqual(
        config[Constants.jsonKey].jsonValue as! [String: AnyHashable],
        Constants.recipe
      )
    }

    struct Recipe: Decodable {
      var recipeName: String
      var ingredients: [String]
      var cookTime: Int
    }

    func testFetchAndActivateWithCodable() async throws {
      let status = try await config.fetchAndActivate()
      XCTAssertEqual(status, .successFetchedFromRemote)
      guard let value = try await config[Constants.jsonKey].decode(valueType: Recipe?.self) else {
        XCTFail("Failed to extract json")
        return
      }
      XCTAssertEqual(value.recipeName, "PB&J")
      XCTAssertEqual(value.ingredients, ["bread", "peanut butter", "jelly"])
      XCTAssertEqual(value.cookTime, 7)
    }
  }
#endif
