//
//  ContentView.swift
//  Death Clock
//
//  Created by Michael Bester on 7/16/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var userSettingsList: [UserSettings]
  @Binding var showingSettings: Bool
  @Binding var showingAbout: Bool
  @State private var tempSettings: UserSettings?
  
  init(showingSettings: Binding<Bool> = .constant(false), showingAbout: Binding<Bool> = .constant(false)) {
    self._showingSettings = showingSettings
    self._showingAbout = showingAbout
  }
  
  private var userSettings: UserSettings? {
    return userSettingsList.first
  }
  
  var body: some View {
    VStack(spacing: 0) {
      if showingAbout {
        AboutView()
      } else if showingSettings {
        if let settings = userSettings {
          EditableSettingsView(userSettings: settings) {
            showingSettings = false
          }
        } else {
          initialSetupView
        }
      } else if let settings = userSettings {
        mainView(settings: settings)
      } else {
        setupView
      }
    }
    .frame(width: 400)
  }
  
  private func mainView(settings: UserSettings) -> some View {
    LifeVisualizationView(userSettings: settings, showingSettings: $showingSettings)
  }
  
  private var setupView: some View {
    VStack(spacing: 16) {
      Image(systemName: "hourglass")
        .font(.system(size: 32))
        .foregroundStyle(.secondary)
      
      Text("Welcome to Death Clock")
        .font(.headline)
      
      Text("Death Clock is a memento mori. It shows you how much of your life has already passed, as well as what remains.")
        .font(.body)
        .foregroundStyle(.primary)
        .multilineTextAlignment(.center)
      
    
      Text("What will you do with that time?")
        .font(.body)
        .foregroundStyle(.primary)
        .multilineTextAlignment(.center)
        
      Text("To get started, enter your birth dated and how old you think you might be when you expire.")
        .font(.body)
        .foregroundStyle(.primary)
        .multilineTextAlignment(.center)
    
      Button("Let‘s Go") {
        showingSettings = true
      }
      .buttonStyle(.borderedProminent)
      .controlSize(.large)
      
    }
    .padding(24)
  }
  
  private var initialSetupView: some View {
    Group {
      if tempSettings == nil {
        Color.clear.onAppear {
          tempSettings = UserSettings()
        }
      } else if let temp = tempSettings {
        EditableSettingsView(userSettings: temp) {
          modelContext.insert(temp)
          try? modelContext.save()
          tempSettings = nil
          showingSettings = false
        }
      }
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(for: UserSettings.self, inMemory: true)
}
