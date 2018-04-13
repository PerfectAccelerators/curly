import XCTest
@testable import Curly

final class CurlyTests: XCTestCase {
    
    override func setUp() {
        
    }
    
    func testGETRequest() {
        let httpClient = HttpClient(ExternalAPIs())
        let params: [String: Any] = ["bar": "foo"]
        let expec = expectation(description: "GET Results")

        httpClient.request(with: params,
                           for: Httpbin.self) { (response, error) in
                            // print("\(String(describing: response))")
                            expec.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testClientRestProtocol() {
        let params: [String: Any] = ["bar": "foo"]
        let expec = expectation(description: "GET Results via Client REST protocol")
        HttpbinService.consume(with: params) { (response, error) in
            // print("\(String(describing: response))")
            expec.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        
    }


    static var allTests = [
		("testGETRequest", testGETRequest),
		("testClientRestProtocol", testClientRestProtocol),
    ]
}
