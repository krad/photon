import Foundation

let version      = "0.1.0"
let release_name = "caffeinated crackup"

#if os(macOS)
    var operatingSystem = "macOS"
    var systemVersion   = ProcessInfo.processInfo.operatingSystemVersionString
#elseif os(iOS)
    import UIKit
    var operatingSystem: String = "iOS"
    var systemVersion           = UIDevice.current.systemVersion
#elseif os(Linux)
    var operatingSystem: String = "Linux"
    var systemVersion           = "Proper support coming soon."
#endif

let userAgent: String = "photon v\(version) - \(release_name) - \(operatingSystem) \(systemVersion)"
