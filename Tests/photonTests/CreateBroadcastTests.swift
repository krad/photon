import XCTest
@testable import photon

class CreateBroadcastTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
    }

    func test_that_we_can_create_a_broadcast() {
        
        let session = MockURLSession()
        let client  = PhotonWebAPI(host: "krad.tv", session: session)
        
        XCTAssertTrue(queue(response: "user.json", into: session))
        let login = PhoneLogin(countryCode: .usa, phoneNumber: "5551212", password: "password")
        let l = self.expectation(description: "We should be able to login")
        client.send(login) { result in
            switch result {
            case .success(let user):
                XCTAssertNotNil(user)
                l.fulfill()
            case .failure(let err):
                XCTFail("We shouldn't have failed: \(err)")
            }
        }
        self.wait(for: [l], timeout: 4)

        XCTAssertTrue(queue(response: "create_broadcast.json", into: session))
        let req = CreateBroadcast(title: "Fake test broadcast from test harness")
        let e = self.expectation(description: "We should be able to create a broadcast")
        client.send(req) { result in
            switch result {
            case .success(let broadcast):
                XCTAssertNotNil(broadcast)
                XCTAssertNotNil(broadcast.pupil)
                XCTAssertEqual(broadcast.pupil?.count, 2)
            case .failure(let err):
                XCTFail("We shouldn't have failed: \(err)")
            }
            e.fulfill()
        }
        self.wait(for: [e], timeout: 5)
    }
        
}
