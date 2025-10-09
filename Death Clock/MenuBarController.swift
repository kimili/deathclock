//
//  MenuBarController.swift
//  Death Clock
//
//  Created by Michael Bester on 7/16/25.
//

import SwiftUI
import SwiftData
import AppKit
import Combine
import ServiceManagement

class MenuBarController: NSObject, ObservableObject {
  private var statusItem: NSStatusItem?
  private var popover: NSPopover?
  @Published var showingSettings = false
  @Published var showingAbout = false
  private var modelContainer: ModelContainer?
  
  func initialize(with modelContainer: ModelContainer) {
    self.modelContainer = modelContainer
    setupMenuBar()
    
    // Observe changes to showingSettings and showingAbout and update popover content
    Publishers.CombineLatest($showingSettings, $showingAbout)
      .sink { [weak self] _, _ in
        DispatchQueue.main.async {
          self?.createPopoverContent()
        }
      }
      .store(in: &cancellables)
  }
  
  private var cancellables = Set<AnyCancellable>()
  
  func setupMenuBar() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    if let button = statusItem?.button {
      let image = NSImage(named: "hourglass-icon")
      image?.accessibilityDescription = "Death Clock"
      image?.isTemplate = true
      button.image = image
      button.action = #selector(statusItemClicked(_:))
      button.target = self
      button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }
    
    setupPopover()
  }
  
  private func setupPopover() {
    popover = NSPopover()
    popover?.contentSize = NSSize(width: 400, height: 300)
    popover?.behavior = .transient
    createPopoverContent()
  }
  
  private func createPopoverContent() {
    guard let modelContainer = self.modelContainer else { return }
    
    let showingSettingsBinding = Binding(
      get: { self.showingSettings },
      set: { self.showingSettings = $0 }
    )
    
    let showingAboutBinding = Binding(
      get: { self.showingAbout },
      set: { self.showingAbout = $0 }
    )
    
    let contentView = ContentView(showingSettings: showingSettingsBinding, showingAbout: showingAboutBinding)
      .modelContainer(modelContainer)
      .environmentObject(self)
    
    let hostingController = NSHostingController(rootView: contentView)
    popover?.contentViewController = hostingController
  }
  
  @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
    guard let event = NSApp.currentEvent else { return }
    
    if event.type == .rightMouseUp || (event.type == .leftMouseUp && event.modifierFlags.contains(.control)) {
      showContextMenu()
    } else {
      // Normal click always shows main view
      showMainView()
    }
  }
  
  private func showContextMenu() {
    let menu = NSMenu()
    
    let aboutItem = NSMenuItem(title: "About...", action: #selector(aboutClicked), keyEquivalent: "")
    aboutItem.target = self
    menu.addItem(aboutItem)
    
    let settingsItem = NSMenuItem(title: "Settings", action: #selector(settingsClicked), keyEquivalent: "")
    settingsItem.target = self
    menu.addItem(settingsItem)
    
    menu.addItem(NSMenuItem.separator())
    
    let loginItem = NSMenuItem(title: "Start Death Clock at Login", action: #selector(toggleLoginItem), keyEquivalent: "")
    loginItem.target = self
    loginItem.state = isLoginItemEnabled() ? .on : .off
    menu.addItem(loginItem)
    
    menu.addItem(NSMenuItem.separator())
    
    let quitItem = NSMenuItem(title: "Quit Death Clock", action: #selector(quitClicked), keyEquivalent: "")
    quitItem.target = self
    menu.addItem(quitItem)
    
    statusItem?.menu = menu
    statusItem?.button?.performClick(nil)
    
    // Clear menu after showing to restore normal click behavior
    DispatchQueue.main.async {
      self.statusItem?.menu = nil
    }
  }
  
  private func togglePopover() {
    if let popover = popover {
      if popover.isShown {
        popover.close()
      } else {
        if let button = statusItem?.button {
          popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
      }
    }
  }
  
  private func showMainView() {
    showingSettings = false
    showingAbout = false
    createPopoverContent()
    if let popover = popover, !popover.isShown {
      if let button = statusItem?.button {
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
      }
    }
  }
  
  @objc private func aboutClicked() {
    showingAbout = true
    showingSettings = false
    // Recreate the popover content to ensure it reflects the current state
    createPopoverContent()
    // Show the popover if it's not already shown
    if let popover = popover, !popover.isShown {
      if let button = statusItem?.button {
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
      }
    }
  }
  
  @objc private func settingsClicked() {
    showingSettings = true
    showingAbout = false
    // Recreate the popover content to ensure it reflects the current state
    createPopoverContent()
    // Show the popover if it's not already shown
    if let popover = popover, !popover.isShown {
      if let button = statusItem?.button {
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
      }
    }
  }
  
  @objc private func toggleLoginItem() {
    if isLoginItemEnabled() {
      removeFromLoginItems()
    } else {
      addToLoginItems()
    }
  }
  
  private func isLoginItemEnabled() -> Bool {
    return SMAppService.mainApp.status == .enabled
  }
  
  private func addToLoginItems() {
    do {
      try SMAppService.mainApp.register()
    } catch {
      print("Failed to add to login items: \(error)")
    }
  }
  
  private func removeFromLoginItems() {
    do {
      try SMAppService.mainApp.unregister()
    } catch {
      print("Failed to remove from login items: \(error)")
    }
  }
  
  @objc private func quitClicked() {
    NSApplication.shared.terminate(nil)
  }
}
