
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
