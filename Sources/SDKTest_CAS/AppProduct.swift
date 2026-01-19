
import SwiftUI

public struct AppProduct {
    public var nameApp: String
    public var iconApp: String
    public var appID: String
    
    public init(nameApp: String, iconApp: String, appID: String) {
        self.nameApp = nameApp
        self.iconApp = iconApp
        self.appID = appID
    }
}
