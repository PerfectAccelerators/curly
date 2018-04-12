
import PerfectLib
import PerfectCURL
import PerfectHTTP
import Foundation
import Dispatch

struct HttpClient {
    
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
    /// This method can be used for GET requests to external APIs
    /// - Parameter params: GET request parameters
    /// - Parameter responseType: expected response type
    /// - Parameter completion: Closure as the completion handler
    /// - Parameter response: mapped model ready to use
    /// - Parameter error: optional error
    
    func request<V: Codable>(with params: [String: Any],
                             for responseType: V.Type,
                             completion: @escaping (_ response: V?, _ error: Error?) -> Void) {
        
        // configure the request
        let api = ClientAPIConfigHelper.apiDetails(responseType, apis: self.clientAPIs)
        var parameteredURL = "\(api.url)"
        switch api.httpMethod {
        case .post:
            for (_, value) in params {
                parameteredURL.append("/\(value)")
            }
        case .get:
            if api.paramFormat == .valueOnly {
                for (_, value) in params {
                    parameteredURL.append("/\(value)")
                }
            } else if api.paramFormat == .keyValuePair {
                for (key, value) in params {
                    parameteredURL.append("/\(key)/\(value)")
                }
            }
        default:
            for (_, value) in params {
                parameteredURL.append("/\(value)")
            }
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
    /// This method can be used to make POST requests to external APIs
    /// - Parameter requestModel: POST request model
    /// - Parameter responseType: expected response type
    /// - Parameter completion: closure as the completion handler
    /// - Parameter response: mapped model ready to use
    /// - Parameter error: optional error
    func request<T: Codable, V: Codable>(with requestModel: T,
                                         for responseType: V.Type,
                                         completion: @escaping (_ response: V?, _ error: Error?) -> Void) {
        
        // configure the request
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
}
