
import Foundation
import PerfectHTTP

/// GET API request parameters format
public enum ClientAPIRequestParamType {
    case none // none
    case keyValuePair // api/key1/value1/key2/value2
    case valueOnly // api/value1/value2
    case urlEncoding // api?key=value&key2=value2
}

/// Definition of an API to be called by HttpClient
public struct ExternalAPI {
    let url: String
    let httpMethod: HTTPMethod
    let encoding: String
    let headers: [HTTPRequestHeader.Name: String]
    let paramFormat: ClientAPIRequestParamType
    
    public init(url: String,
                httpMethod: HTTPMethod,
                encoding: String,
                headers: [HTTPRequestHeader.Name: String],
                paramFormat: ClientAPIRequestParamType) {
        self.url = url
        self.httpMethod =  httpMethod
        self.encoding = encoding
        self.headers = headers
        self.paramFormat = paramFormat
    }
}

/// This protocol defines methods that should be implemented
/// by conforming classes to handle **Dependency Injection**
public protocol ClientAPIProtocol {
    
    /// ## resources
    /// This method contracts the resource information retrieval
    /// - parameter resourceName: resourceName is the name of model object
    /// - returns: ExternalAPI definition
    func resource(name: String) -> ExternalAPI
    func timeout(resourceName: String) -> TimeInterval
    init()
}

public extension ClientAPIProtocol {
    public func timeout(resourceName: String) -> TimeInterval {
        return 3
    }
}

public extension Encodable {
    static var resourceName: String {
        return String(describing: self).replacingOccurrences(of: ".Type", with: "")
    }
}
