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

	// ==========================================
	// CodableRequest-style tests
	// ==========================================
	
	func testSimplePostErrorHandling() {
		do {
			let _ : Httpbin = try HttpClient.request(.post, "https://httpbin.org/get", to: Httpbin.self, error: ClientAPIDefaultErrorResponse.self)
			XCTFail()
		} catch let error as ClientAPIDefaultErrorResponse {
			// Pass
			XCTAssert(error.error?.code == "405", "Response should have been 405 Method not allowed")
		} catch {
			XCTFail("Should have had a graceful error handling")
		}
	}

	func testSimpleGet() {
		do {
			let response : Httpbin = try HttpClient.request(.get, "https://httpbin.org/get", to: Httpbin.self, error: ClientAPIDefaultErrorResponse.self)
			XCTAssert(response.url == "https://httpbin.org/get", "Unexpected response")
		} catch {
			XCTFail("\(error)")
		}
	}

	func testSimplePostEmpty() {
		do {
			let response : Httpbin = try HttpClient.request(.post, "https://httpbin.org/post", to: Httpbin.self, error: ClientAPIDefaultErrorResponse.self)
			XCTAssert(response.url == "https://httpbin.org/post", "Unexpected response")
		} catch {
			XCTFail("\(error)")
		}
	}

	func testSimplePostForm() {
		do {
			let response : Httpbin = try HttpClient.request(.post, "https://httpbin.org/post", to: Httpbin.self, error: ClientAPIDefaultErrorResponse.self, params: ["donkey":"kong"], encoding: "form")
			XCTAssert(response.url == "https://httpbin.org/post", "Unexpected response")
			//			XCTAssert(response.form == ["donkey":"kong"], "Unexpected response ([donkey:kong])")
		} catch {
			XCTFail("\(error)")
		}
	}

	func testSimpleGetWithHeader() {
		do {
			let response : Httpbin = try HttpClient.request(
				.get,
				"https://httpbin.org/get",
				to: Httpbin.self,
				error: ClientAPIDefaultErrorResponse.self,
				headers: ["testing": "123"]
			)
			XCTAssert(response.url == "https://httpbin.org/get", "Unexpected response")
		} catch {
			XCTFail("\(error)")
		}
	}


    static var allTests = [
		("testGETRequest", testGETRequest),
		("testClientRestProtocol", testClientRestProtocol),

		// CodableRequest-Style Tests
		("testSimplePostErrorHandling", testSimplePostErrorHandling),
		("testSimpleGet", testSimpleGet),
		("testSimplePostEmpty", testSimplePostEmpty),
		("testSimplePostForm", testSimplePostForm),
		("testSimpleGetWithHeader", testSimpleGetWithHeader),

    ]
}
