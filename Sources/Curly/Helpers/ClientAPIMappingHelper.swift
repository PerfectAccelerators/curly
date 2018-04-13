
import PerfectLib
import PerfectCURL
import PerfectLogger
import Foundation

/// Helper methods to handle the mapping of the response to Codable
struct ClientAPIMappingHelper {
    
    static func processResponse<T: Codable>(_ responseType: T.Type,
                                            _ confirmation: () throws -> CURLResponse,
                                            _ completion: @escaping (_ response: T?, _ error: Error?) -> Void) {
        
        do {
            let response = try confirmation()
            var success = true
            if response.responseCode > 399 {
                success = false
            }
            self.parseResponse(response, responseType, success, completion)
        } catch let error as CURLResponse.Error {
            let err = error.response
            self.parseResponse(err, responseType, false, completion)
            LogFile.debug("responseCode: \(err.responseCode) - json: \(err.bodyString) - responseType:\(responseType) ")
        } catch let error {
            LogFile.critical("CURL GET request perform error")
            let httpError = ClientAPIError(code: 500,
                                           userFriendlyMessage: "",
                                           message: "confirmation failed - \(error.localizedDescription)",
                                           success: false)
            completion(nil, httpError)
        }
    }
    
    private static func parseResponse<T: Codable>(_ resp: CURLResponse,
                                                  _ responseType: T.Type,
                                                  _ isSuccess: Bool,
                                                  _ completion: @escaping (_ response: T?, _ error: Error?) -> Void) {
        
        do {
            guard let jsonData = resp.bodyString.data(using: .utf8) else {
                let httpError = ClientAPIError(code: 500,
                                               userFriendlyMessage: "",
                                               message: "Body string data conversion failed",
                                               success: false)
                
                completion(nil, httpError)
                LogFile.error("responseCode: \(resp.responseCode) - error json: \(resp.bodyString) - responseType:\(responseType) ")
                return
            }
            let decoder = JSONDecoder()
            if isSuccess {
                let model = try decoder.decode(responseType, from: jsonData)
                completion(model, nil)
            } else {
                let model = try decoder.decode(ClientAPIError.self, from: jsonData)
                completion(nil, model)
            }
            LogFile.info("responseCode: \(resp.responseCode) -  json: \n\(resp.bodyString) - responseType:\(responseType) ")
        } catch let error as CURLResponse.Error {
            let err = error.response
            let httpError = ClientAPIError(code: err.responseCode,
                                           userFriendlyMessage: err.bodyString,
                                           message: "parsing data",
                                           success: false)
            
            LogFile.error("Failed response code \(err.responseCode) - url: \(err.url) - Failed response bodyString: \(err.bodyString)")
            completion(nil, httpError)
        } catch let error {
            LogFile.error("parseResponse - decoder failed for \(responseType): \(error)")
            let httpError = ClientAPIError(code: 500,
                                           userFriendlyMessage: "Not able to convert \(responseType): \(error)",
                                           message: "Something went wrong",
                                           success: false)
            completion(nil, httpError)
        }
    }
}
