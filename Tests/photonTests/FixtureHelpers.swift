import Foundation
import photon

func fixtureData(for fixture: String) throws -> Data {
    let fixtureURL  = URL(fileURLWithPath: fixturesPath).appendingPathComponent(fixture)
    let fixtureData = try Data(contentsOf: fixtureURL)
    return fixtureData
}

func queue(response mock: String, into session: MockURLSession) -> Bool {
    do {
        let data = try fixtureData(for: mock)
        session.responses.append(data)
        return true
    } catch {
        return false
    }
}
