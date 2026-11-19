import Foundation

/// Converts between GCJ-02 (China mainland map coordinates used by Apple Maps / AutoNavi)
/// and WGS-84 (standard GPS coordinates expected by iOS Developer Location Simulation).
public enum ChinaCoordinate {
    private static let a = 6_378_245.0
    private static let ee = 0.00669342162296594323

    /// Returns true if the coordinate lies inside the mainland China GCJ-02 region
    /// (excluding Taiwan, which uses WGS-84).
    public static func isInChinaMainland(latitude: Double, longitude: Double) -> Bool {
        guard longitude >= 72.004, longitude <= 137.8347,
              latitude >= 0.8293, latitude <= 55.8271 else {
            return false
        }
        // Taiwan uses WGS-84 rather than GCJ-02.
        if longitude >= 119.3, longitude <= 122.2, latitude >= 21.8, latitude <= 25.4 {
            return false
        }
        return true
    }

    public static func wgs84ToGcj02(latitude: Double, longitude: Double) -> (latitude: Double, longitude: Double) {
        guard isInChinaMainland(latitude: latitude, longitude: longitude) else {
            return (latitude, longitude)
        }
        let dLat = transformLat(x: longitude - 105.0, y: latitude - 35.0)
        let dLon = transformLon(x: longitude - 105.0, y: latitude - 35.0)
        let radLat = latitude / 180.0 * .pi
        var magic = sin(radLat)
        magic = 1.0 - ee * magic * magic
        let sqrtMagic = sqrt(magic)
        let latOffset = (dLat * 180.0) / ((a * (1.0 - ee)) / (magic * sqrtMagic) * .pi)
        let lonOffset = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * .pi)
        return (latitude + latOffset, longitude + lonOffset)
    }

    /// Exact iterative inversion of `wgs84ToGcj02` (< 0.1 mm error).
    public static func gcj02ToWgs84(latitude: Double, longitude: Double) -> (latitude: Double, longitude: Double) {
        guard isInChinaMainland(latitude: latitude, longitude: longitude) else {
            return (latitude, longitude)
        }
        var wgsLat = latitude
        var wgsLon = longitude
        for _ in 0..<8 {
            let est = wgs84ToGcj02(latitude: wgsLat, longitude: wgsLon)
            wgsLat += latitude - est.latitude
            wgsLon += longitude - est.longitude
        }
        return (wgsLat, wgsLon)
    }

    private static func transformLat(x: Double, y: Double) -> Double {
        var ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x))
        ret += (20.0 * sin(6.0 * x * .pi) + 20.0 * sin(2.0 * x * .pi)) * 2.0 / 3.0
        ret += (20.0 * sin(y * .pi) + 40.0 * sin(y / 3.0 * .pi)) * 2.0 / 3.0
        ret += (160.0 * sin(y / 12.0 * .pi) + 320.0 * sin(y * .pi / 30.0)) * 2.0 / 3.0
        return ret
    }

    private static func transformLon(x: Double, y: Double) -> Double {
        var ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(abs(x))
        ret += (20.0 * sin(6.0 * x * .pi) + 20.0 * sin(2.0 * x * .pi)) * 2.0 / 3.0
        ret += (20.0 * sin(x * .pi) + 40.0 * sin(x / 3.0 * .pi)) * 2.0 / 3.0
        ret += (150.0 * sin(x / 12.0 * .pi) + 300.0 * sin(x / 30.0 * .pi)) * 2.0 / 3.0
        return ret
    }
}
