//
//  Death_ClockApp.swift
//  Death Clock
//
//  Created by Michael Bester on 7/16/25.
//

import SwiftUI
import SwiftData
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
  var menuBarController: MenuBarController?
  var modelContainer: ModelContainer?
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    // Hide the app from the Dock since this is a menubar-only app
    NSApp.setActivationPolicy(.accessory)
    
    let schema = Schema([UserSettings.self])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    
    do {
      modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
    
    menuBarController = MenuBarController()
    if let modelContainer = modelContainer {
      menuBarController?.initialize(with: modelContainer)
    }
  }
}

@main
struct Death_ClockApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var body: some Scene {
    Settings {
      EmptyView()
    }
  }
}
