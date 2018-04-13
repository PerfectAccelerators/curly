
import PerfectHTTP
import Curly

struct ExternalAPIs: ClientAPIProtocol {
    
    var baseURL: String
    var resources: [String: ExternalAPI]
    var headers: [HTTPRequestHeader.Name: String]
    
    init() {
        baseURL = ""
        headers = [HTTPRequestHeader.Name.contentType: "application/json"]
        let httpbin = ExternalAPI(url: "https://httpbin.org/get", httpMethod: .get, encoding: "json", headers: headers, paramFormat: .none)
        resources = [
            Httpbin.resourceName: httpbin,
        ]
    }
    
    func resource(name: String) -> ExternalAPI {
        return resources[name]!
    }
}
