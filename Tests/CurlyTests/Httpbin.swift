
import Foundation

struct Httpbin: Codable {
    let args: Args?
    let headers: Headers
    let origin: String
    let url: String
}

struct Args: Codable { }

struct Headers: Codable {
    let accept: String?
    let acceptEncoding: String?
    let acceptLanguage: String?
    let connection: String?
    let cookie: String?
    let host: String?
    let referer: String?
    let upgradeInsecureRequests: String?
    let userAgent: String?
    
    enum CodingKeys: String, CodingKey {
        case accept = "Accept"
        case acceptEncoding = "Accept-Encoding"
        case acceptLanguage = "Accept-Language"
        case connection = "Connection"
        case cookie = "Cookie"
        case host = "Host"
        case referer = "Referer"
        case upgradeInsecureRequests = "Upgrade-Insecure-Requests"
        case userAgent = "User-Agent"
    }
}
