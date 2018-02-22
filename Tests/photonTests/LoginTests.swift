import XCTest
@testable import photon

class LoginTests: XCTestCase {

    func test_that_we_can_login_with_a_phone_number() {
        let session     = MockURLSession()
        XCTAssert(queue(response: "user.json", into: session))

        let client      = Photon(host: "krad.tv", session: session)
        let req         = PhoneLogin(countryCode: .usa,
                                     phoneNumber: "5551212",
                                     password: "password")

        let e = self.expectation(description: "We should be able to login")
        
        client.send(req) { result in
            switch result {
            case .success(let user):
                XCTAssertNotNil(user)
            case .failure(let err):
                XCTFail("We shouldn't have failed. Error: \(err)")
            }
            e.fulfill()
        }
        
        self.wait(for: [e], timeout: 2)
    }
    
}
