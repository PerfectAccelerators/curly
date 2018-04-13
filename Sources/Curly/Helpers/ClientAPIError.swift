
/// In case of error this struct will be returned
struct ClientAPIError: Error, Codable {
    var code: Int?
    var userFriendlyMessage: String?
    var message: String?
    var success: Bool?
}

extension ClientAPIError {
    static func defaultError() -> ClientAPIError {
        return ClientAPIError(code: 500,
                              userFriendlyMessage: "Something went wrong",
                              message: "Internal server error",
                              success: false)
    }
}


/// For CodableRequest-style requests
public protocol ClientAPIDefaultErrorResponseProtocol: Codable, Error {}

public struct ClientAPIDefaultErrorResponse: ClientAPIDefaultErrorResponseProtocol {
	public var error: ClientAPIDefaultErrorMsg?
}
public struct ClientAPIDefaultErrorMsg: Codable {
	public var message: String?
	public var type: String?
	public var param: String?
	public var code: String?
}
