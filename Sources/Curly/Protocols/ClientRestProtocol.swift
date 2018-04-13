
import Foundation

/// Conveience protocol with default implementation
/// to consume (GET) and produce (POST)
///
/// - Define all your API dependecies in a struct that conforms to `ClientAPIProtocol`.
/// - Create a struct that conforms to `ClientRestProtocol`
/// - Set `ExternalServices` with the defined struct
/// - Fianlly, set the model types for POST and GET
public protocol ClientRestProtocol {
    associatedtype ExternalServices: ClientAPIProtocol
    associatedtype PostModelType: Codable
    associatedtype GetModelType: Codable
    associatedtype PostResponseType: Codable
}

extension ClientRestProtocol {
    
    /* Example usage
     let params: [String: Any] = ["bar": "foo"]
     HttpbinService.consume(with: params) { (response, error) in
        print("\(String(describing: response))")
     }
     */
    public static func consume(with: [String: Any],
                               completion: @escaping (GetModelType?, Error?) -> Void) {
        
        let httpClient = HttpClient(ExternalServices.init())
        httpClient.request(with: with,
                           for: GetModelType.self) {
                            
                            (response, error) in
                            if let result = response {
                                print("response: \(result)")
                                completion(result, nil)
                            } else if let failure = error {
                                print("error:\(failure)")
                                completion(nil, failure)
                            }
        }
    }
    
    public static func produce(with: PostModelType,
                               completion: @escaping (PostResponseType?, Error?) -> Void) {
        
        let httpClient = HttpClient(ExternalServices.init())
        httpClient.request(with: with,
                           for: PostResponseType.self) {
                            
                            (response, error) in
                            if let result = response {
                                print("response: \(result)")
                                completion(result, nil)
                            } else if let failure = error {
                                print("error:\(failure)")
                                completion(nil, failure)
                            }
        }
        
    }
}
