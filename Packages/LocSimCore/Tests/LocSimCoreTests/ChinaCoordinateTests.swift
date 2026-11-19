import XCTest
@testable import LocSimCore

final class ChinaCoordinateTests: XCTestCase {
    func testBeijingGcj02ToWgs84() {
        let wgs = ChinaCoordinate.gcj02ToWgs84(latitude: 39.907712, longitude: 116.459178)
        XCTAssertEqual(wgs.latitude, 39.906364, accuracy: 1e-5)
        XCTAssertEqual(wgs.longitude, 116.453009, accuracy: 1e-5)
    }

    func testRoundTripPrecision() {
        let gcj = (latitude: 31.230416, longitude: 121.473701)
        let wgs = ChinaCoordinate.gcj02ToWgs84(latitude: gcj.latitude, longitude: gcj.longitude)
        let back = ChinaCoordinate.wgs84ToGcj02(latitude: wgs.latitude, longitude: wgs.longitude)
        XCTAssertEqual(back.latitude, gcj.latitude, accuracy: 1e-7)
        XCTAssertEqual(back.longitude, gcj.longitude, accuracy: 1e-7)
    }

    func testOutsideMainlandUnchanged() {
        // Paris
        let paris = ChinaCoordinate.gcj02ToWgs84(latitude: 48.8566, longitude: 2.3522)
        XCTAssertEqual(paris.latitude, 48.8566)
        XCTAssertEqual(paris.longitude, 2.3522)
        // Taipei (Taiwan uses WGS-84)
        let taipei = ChinaCoordinate.gcj02ToWgs84(latitude: 25.0330, longitude: 121.5654)
        XCTAssertEqual(taipei.latitude, 25.0330)
        XCTAssertEqual(taipei.longitude, 121.5654)
    }
}
