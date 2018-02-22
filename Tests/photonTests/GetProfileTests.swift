import XCTest
@testable import photon

class GetProfileTests: XCTestCase {

    func test_that_we_can_get_a_users_profile() {
        let session     = MockURLSession()
        XCTAssert(queue(response: "user.json", into: session))
        XCTAssert(queue(response: "user.json", into: session))

        let client = Photon(host: "krad.tv", session: session)
        
        let login = PhoneLogin(countryCode: .usa, phoneNumber: "5555551212", password: "password")
        let l = self.expectation(description: "We need to login first")
        client.send(login) { (result) in l.fulfill() }
        self.wait(for: [l], timeout: 10)
        
        let req    = GetProfile()
        let e = self.expectation(description: "Should be able to get the current user's profile")
        client.send(req) { (result) in
            switch result {
            case .success(let user):
                XCTAssertNotNil(user)
                XCTAssertNotNil(user.userID)
            case .failure(let err):
                XCTFail("We shouldn't have failed: \(err)")
            }
            e.fulfill()
        }
        
        self.wait(for: [e], timeout: 10)
    }
    
}
