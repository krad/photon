import XCTest
@testable import photon

class SignupTests: XCTestCase {

    func test_that_we_can_signup_with_a_phone_number() {
        let session     = MockURLSession()
        XCTAssert(queue(response: "user_signup.json", into: session))

        let client      = PhotonWebAPI(host: "krad.tv", session: session)
        let req         = PhoneSignup(countryCode: .usa, phoneNumber: "5555551212")
        
        let e = self.expectation(description: "We should be able to signup")
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
