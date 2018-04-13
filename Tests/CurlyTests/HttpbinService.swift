
import Foundation
import Curly

struct NoPostModel: Codable { }
struct NoPostResponseModel: Codable { }

struct HttpbinService: ClientRestProtocol {
    typealias ExternalServices = ExternalAPIs
    typealias PostModelType = NoPostModel
    typealias GetModelType = Httpbin
    typealias PostResponseType = NoPostResponseModel
}
