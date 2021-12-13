/*
 * Copyright 2021 Google LLC
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

import Foundation
import FirebaseRemoteConfig
import FirebaseSharedSwift

public enum RemoteConfigCodableError: Error {
  case valueError
  case internalError
}

public extension RemoteConfigValue {
//  /**
//   * Creates a reference to the Callable HTTPS trigger with the given name, the type of an `Encodable`
//   * request and the type of a `Decodable` response.
//   *
//   * - Parameter name: The name of the Callable HTTPS trigger
//   * - Parameter requestType: The type of the `Encodable` entity to use for requests to this `Callable`
//   * - Parameter responseType: The type of the `Decodable` entity to use for responses from this `Callable`
//   */
//  func httpsCallable<Request: Encodable,
//    Response: Decodable>(_ name: String,
//                         requestType: Request.Type,
//                         responseType: Response.Type,
//                         encoder: StructureEncoder = StructureEncoder(),
//                         decoder: StructureDecoder = StructureDecoder())
//    -> Callable<Request, Response> {
//    return Callable(callable: httpsCallable(name), encoder: encoder, decoder: decoder)
//  }
  #if compiler(>=5.5) && canImport(_Concurrency)
    @available(iOS 15, tvOS 15, macOS 12, watchOS 8, *)
    func decode<Value: Decodable>(valueType: Value.Type) async throws -> Value {
      guard let jsonValue = self.jsonValue else {
        throw RemoteConfigCodableError.valueError
      }
      return try StructureDecoder().decode(Value.self, from: jsonValue)
    }
  #endif
}

/**
 * A `Callable` is reference to a particular Callable HTTPS trigger in Cloud Functions.
 */
public struct Callable<Request: Encodable, Response: Decodable> {
  enum CallableError: Error {
    case internalError
  }

//  private let callable: HTTPSCallable
//  private let encoder: StructureEncoder
//  private let decoder: StructureDecoder
//
//  init(callable: HTTPSCallable, encoder: StructureEncoder, decoder: StructureDecoder) {
//    self.callable = callable
//    self.encoder = encoder
//    self.decoder = decoder
//  }
//
//  /**
//   * Executes this Callable HTTPS trigger asynchronously.
//   *
//   * The data passed into the trigger must be of the generic `Request` type:
//   *
//   * The request to the Cloud Functions backend made by this method automatically includes a
//   * Firebase Instance ID token to identify the app instance. If a user is logged in with Firebase
//   * Auth, an auth ID token for the user is also automatically included.
//   *
//   * Firebase Instance ID sends data to the Firebase backend periodically to collect information
//   * regarding the app instance. To stop this, see `[FIRInstanceID deleteIDWithHandler:]`. It
//   * resumes with a new Instance ID the next time you call this method.
//   *
//   * - Parameter data: Parameters to pass to the trigger.
//   * - Parameter completion: The block to call when the HTTPS request has completed.
//   *
//   * - Throws: An error if any value throws an error during encoding.
//   */
//  public func call(_ data: Request,
//                   completion: @escaping (Result<Response, Error>)
//                     -> Void) throws {
//    let encoded = try encoder.encode(data)
//
//    callable.call(encoded) { result, error in
//      do {
//        if let result = result {
//          let decoded = try decoder.decode(Response.self, from: result.data)
//          completion(.success(decoded))
//        } else if let error = error {
//          completion(.failure(error))
//        } else {
//          completion(.failure(CallableError.internalError))
//        }
//      } catch {
//        completion(.failure(error))
//      }
//    }
//  }
//
//  #if compiler(>=5.5) && canImport(_Concurrency)
//    /**
//     * Executes this Callable HTTPS trigger asynchronously.
//     *
//     * The data passed into the trigger must be of the generic `Request` type:
//     *
//     * The request to the Cloud Functions backend made by this method automatically includes a
//     * Firebase Instance ID token to identify the app instance. If a user is logged in with Firebase
//     * Auth, an auth ID token for the user is also automatically included.
//     *
//     * Firebase Instance ID sends data to the Firebase backend periodically to collect information
//     * regarding the app instance. To stop this, see `[FIRInstanceID deleteIDWithHandler:]`. It
//     * resumes with a new Instance ID the next time you call this method.
//     *
//     * - Parameter data: The `Request` representing the data to pass to the trigger.
//     *
//     * - Throws: An error if any value throws an error during encoding.
//     * - Throws: An error if any value throws an error during decoding.
//     * - Throws: An error if the callable fails to complete
//     *
//     * - Returns: The decoded `Response` value
//     */
//    @available(iOS 15, tvOS 15, macOS 12, watchOS 8, *)
//    public func call(_ data: Request,
//                     encoder: StructureEncoder = StructureEncoder(),
//                     decoder: StructureDecoder =
//                       StructureDecoder()) async throws -> Response {
//      let encoded = try encoder.encode(data)
//      let result = try await callable.call(encoded)
//      return try decoder.decode(Response.self, from: result.data)
//    }
//  #endif
}
