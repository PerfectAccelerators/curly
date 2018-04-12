
import Foundation
import PerfectLib
import PerfectCURL

struct ClientAPIConfigHelper {
    
    static func apiDetails<T: Codable>(_ serviceType: T.Type, apis: ClientAPIProtocol) -> ExternalAPI {
        /// **To discover the responseType**
        let mirror = Mirror(reflecting: serviceType)
        /// **Response Model Type**
        let modelType = String(describing: mirror.subjectType).replacingOccurrences(of: ".Type", with: "")
        /// **Resource configurations**
        return apis.getResource(modelType)
    }
    
    static func curlRequest(for api: ExternalAPI,
                            url: String,
                            bearerToken: String) -> CURLRequest {
        
        var curlOpts: [CURLRequest.Option] = [
            CURLRequest.Option.httpMethod(api.httpMethod),
            CURLRequest.Option.sslVerifyPeer(false),
            CURLRequest.Option.sslVerifyHost(true),
        ]
        for header in api.headers {
            curlOpts.append(CURLRequest.Option.addHeader(header.key, header.value))
        }
        if !bearerToken.isEmpty {
            curlOpts.append(CURLRequest.Option.addHeader(CURLRequest.Header.Name.authorization, "Bearer \(bearerToken)"))
        }
        let curlRequest = CURLRequest(url, options: curlOpts)
        
        return curlRequest
    }
}
