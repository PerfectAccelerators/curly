
import PerfectLib
import PerfectCURL
import PerfectHTTP
import Foundation
import Dispatch

/// Http Client to send requests to external APIs.
/// It relies on a concerte object conforiming to `ClientAPIProtocol`.
///
/// **Client of this struct needs to implement the protocol and
/// inject it via init**

public struct HttpClient {
    
    // MARK: - Dependency Injection
    /// ***Dependency injection***
    let clientAPIs: ClientAPIProtocol
    /// ***Init method for Dependency injection***
    init(_ clientAPIProtocol: ClientAPIProtocol) {
        self.clientAPIs = clientAPIProtocol
    }
    
    // MARK: - properties
    var bearerToken: String = ""
    
    // MARK: - GET Request
    
    /// Send a request - Async - with params
    /// This method can be used for **GET** requests to external APIs
    /// - Parameter params: GET request parameters
    /// - Parameter responseType: expected response type
    /// - Parameter completion: Closure as the completion handler
    /// - Parameter response: mapped model ready to use
    /// - Parameter error: optional error
    
    func request<V: Codable>(with params: [String: Any],
                             for responseType: V.Type,
                             completion: @escaping (_ response: V?, _ error: Error?) -> Void) {
        
        // configure the request by getting the API details
        let api = ClientAPIConfigHelper.apiDetails(responseType, apis: self.clientAPIs)
        var parameteredURL = "\(api.url)"
        switch api.httpMethod {
        case .post:
            break
        case .get:
            if api.paramFormat == .valueOnly {
                for (_, value) in params {
                    parameteredURL.append("/\(value)")
                }
            } else if api.paramFormat == .keyValuePair {
                for (key, value) in params {
                    parameteredURL.append("/\(key)/\(value)")
                }
            } else if api.paramFormat == .urlEncoding {
                parameteredURL.append("?")
                var index = 0
                for (key, value) in params {
                    parameteredURL.append("\(key)=\(value)")
                    index += 1
                    if index < params.count {
                        parameteredURL.append("&")
                    }
                }
            }
        default:
            break
        }
        
        let curlRequest = ClientAPIConfigHelper.curlRequest(for: api,
                                                            url: parameteredURL,
                                                            bearerToken: self.bearerToken)
        
        curlRequest.perform {
            (confirmation) in
            ClientAPIMappingHelper.processResponse(responseType, confirmation, completion)
        }
    }
    
    // MARK: - POST Request
    
    /// Send a request - Async - with requestModel
    /// This method can be used to make **POST** requests to external APIs
    /// - Parameter requestModel: POST request model
    /// - Parameter responseType: expected response type
    /// - Parameter completion: closure as the completion handler
    /// - Parameter response: mapped model ready to use
    /// - Parameter error: optional error
    func request<T: Codable, V: Codable>(with requestModel: T,
                                         for responseType: V.Type,
                                         completion: @escaping (_ response: V?, _ error: Error?) -> Void) {
        
        // configure the request by getting the API details
        let api = ClientAPIConfigHelper.apiDetails(responseType, apis: self.clientAPIs)

        var curlRequest = CURLRequest(api.url)
        
        if api.httpMethod == .post {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            do {
                let postJSON = try encoder.encode(requestModel)
                guard let json = String(data: postJSON, encoding: .utf8) else {
                    let clientError = ClientAPIError(code: 400,
                                                     userFriendlyMessage: "",
                                                     message: "Invalid request",
                                                     success: false)
                    completion(nil, clientError)
                    return
                }
                curlRequest = ClientAPIConfigHelper.curlRequest(for: api,
                                                                url: api.url,
                                                                bearerToken: self.bearerToken)
                curlRequest.options.append(CURLRequest.Option.postString(json))
            } catch let error {
                let clientError = ClientAPIError(code: 400,
                                                 userFriendlyMessage: "Invalid request",
                                                 message: "\(error)",
                                                 success: false)
                completion(nil, clientError)
                return
            }
        } else {
            print("this is a post")
        }
        curlRequest.perform {
            (confirmation) in
            ClientAPIMappingHelper.processResponse(responseType, confirmation, completion)
        }
    }





	/// The function that triggers the specific interaction with a remote server
	/// Parameters:
	/// - method: The HTTP Method enum, i.e. .get, .post
	/// - route: The route required
	/// - to: The type of the object to parse into
	/// - error: The error type into which to parse the error
	/// - params: The name/value pair to transform into the JSON or form submission
	/// - headers: The name/value pair to transform into additional headers
	/// - encoding: json, or form
	/// - bearerToken: A string with the authentication token
	/// Response: CURLResponse
	/// Usage:
	/// let r : HTTPbin = try CodableRequest.request(.post, "https://httpbin.org/get", to: HTTPbin.self, error: ErrorResponse.self)

	public static func request<T: Codable, E: ClientAPIDefaultErrorResponseProtocol>(
		_ method: HTTPMethod,
		_ url: String,
		to responseType: T.Type,
		error errorType: E.Type,
		body: String = "",
		json: [String: Any] = [String: Any](),
		params: [String: Any] = [String: Any](),
		headers: [String: Any] = [String: Any](), // additional headers. use to override things like weird auth formats
		encoding: String = "json",
		bearerToken: String = "") throws -> T {

		var curlObject = CURLRequest(url, options: [CURLRequest.Option.httpMethod(method)])
		var byteArray = [UInt8]()

		if !body.isEmpty {
			print(body.utf8)
			byteArray = [UInt8](body.utf8)
		} else if !json.isEmpty {
			do {
				print(try json.jsonEncodedString().utf8)
				byteArray = [UInt8](try json.jsonEncodedString().utf8)
			} catch {
				throw error
			}
		} else if !params.isEmpty {
			byteArray = [UInt8]((self.toParams(params).joined(separator: "&")).utf8)
		}


		if method == .post || method == .put || method == .patch {
			curlObject = CURLRequest(url, CURLRequest.Option.httpMethod(method), .postData(byteArray))
		} else {
			curlObject = CURLRequest(url, CURLRequest.Option.httpMethod(method))
		}


		curlObject.addHeader(.accept, value: "application/json")
		curlObject.addHeader(.cacheControl, value: "no-cache")
		curlObject.addHeader(.userAgent, value: "PerfectCodableRequest1.0")

		for (i,v) in headers {
			curlObject.addHeader(.custom(name: i), value: "\(v)")
		}


		if !bearerToken.isEmpty {
			curlObject.addHeader(.authorization, value: "Bearer \(bearerToken)")
		}

		if encoding == "json" {
			curlObject.addHeader(.contentType, value: "application/json")
		} else {
			curlObject.addHeader(.contentType, value: "application/x-www-form-urlencoded")
		}

		do {
			let response = try curlObject.perform()
			if response.responseCode >= 400 {
				do {
					let e = try response.bodyJSON(errorType)
					throw e

				} catch {
					let e = ClientAPIDefaultErrorResponse(error: ClientAPIDefaultErrorMsg(message: response.bodyString, type: "", param: "", code: "\(response.responseCode)"))
					throw e
				}
			}
			let model = try response.bodyJSON(responseType)
			return model as T

		} catch let error as CURLResponse.Error {
			let e = try error.response.bodyJSON(errorType)
			throw e

		} catch {
			throw error
		}
	}

	private static func toParams(_ params:[String: Any]) -> [String] {
		var str = [String]()
		for (key, value) in params {
			let v = "\(value)".stringByEncodingURL
			str.append("\(key)=\(v)")
		}
		return str
	}
}
