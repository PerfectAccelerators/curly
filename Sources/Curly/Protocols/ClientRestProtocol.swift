
import Foundation

protocol ClientRestProtocol {
    associatedtype PostModelType: Codable
    associatedtype GetModelType: Codable
    associatedtype PostResponseType: Codable
}

extension ClientRestProtocol {
    static func consume(with: [String: Any],
                        completion: @escaping (GetModelType?, Error?) -> Void) {
        
        let httpClient = HttpClient(ExternalServices())
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
    
    static func produce(with: PostModelType,
                        completion: @escaping (PostResponseType?, Error?) -> Void) {
        
        let httpClient = HttpClient(ExternalServices())
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
