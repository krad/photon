import Foundation

let version      = "0.1.0"
let release_name = "caffeinated crackup"

#if os(macOS)
    var operatingSystem = "macOS"
    var systemVersion   = ProcessInfo.processInfo.operatingSystemVersionString

#elseif os(iOS)
    var operatingSystem = "iOS"
    var systemVersion   = UIDevice.current.systemVersion
#endif

let userAgent = "photon v\(version) - \(release_name) - \(operatingSystem) \(systemVersion)"
