
import PerfectHTTP

struct ExternalServices: ClientAPIProtocol {
    
    let baseURL: String = ""
    let resources: [String: ExternalAPI]
    
    init() {
        let baseURL: String = ""
        let headers = [HTTPRequestHeader.Name.contentType: "application/json"]
        let user = ExternalAPI(url: "\(baseURL)/api/v1/login", httpMethod: .post, encoding: "json", headers: headers, paramFormat: .keyValuePair)
        resources = [
            "User": user,
        ]
    }
    
    func getResource(_ resourceName: String) -> ExternalAPI {
        return resources[resourceName]!
    }
}

