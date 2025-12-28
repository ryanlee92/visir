import AppIntents
import Foundation
import home_widget
import SwiftUI

@available(iOS 17, *)
public struct OpenAppIntent: AppIntent {
   static public var title: LocalizedStringResource = "Open App Intent"
   static public var openAppWhenRun: Bool = true // required

   @Parameter(title: "Widget URI")
   var url: URL?

   @Parameter(title: "AppGroup")
   var appGroup: String?

   public init() {}

   public init(url: URL?, appGroup: String?) {
      self.url = url
      self.appGroup = appGroup
   }

   public func perform() async throws -> some IntentResult {
      if let url = url {
         await EnvironmentValues().openURL(url)
      }
      return .result()
   }
}

@available(iOS 17, *)
@available(iOSApplicationExtension, unavailable)
extension OpenAppIntent: ForegroundContinuableIntent {}
