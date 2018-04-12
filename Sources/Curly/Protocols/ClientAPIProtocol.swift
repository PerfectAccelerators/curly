
import Foundation
import PerfectHTTP

enum ClientAPIRequestParamType {
    case keyValuePair
    case valueOnly
}

struct ExternalAPI {
    let url: String
    let httpMethod: HTTPMethod
    let encoding: String
    let headers: [HTTPRequestHeader.Name: String]
    let paramFormat: ClientAPIRequestParamType
}

/// This protocol defines methods that should be implemented
/// by conforming classes to handle **Dependency Injection**
protocol ClientAPIProtocol {
    
    /// ## Get Resources
    /// This method contracts the resource information retrieval
    /// - parameter resourceName: resourceName is the name of model object
    /// - parameter isCollection: true if resource returns an array
    /// - returns: a tuple of (resouceName, url, requestMethod)
    func getResource(_ resourceName: String) -> ExternalAPI
    func getTimeout(_ resourceName: String) -> TimeInterval
}

extension ClientAPIProtocol {
    public func getTimeout(_ resourceName: String) -> TimeInterval {
        return 3
    }
}
