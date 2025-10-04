//
//  EditableSettingsView.swift
//  Death Clock
//
//  Created by Michael Bester on 7/16/25.
//

import SwiftUI

struct EditableSettingsView: View {
  @Bindable var userSettings: UserSettings
  @Environment(\.modelContext) private var modelContext
  let onSave: () -> Void
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Settings")
        .font(.headline)
      
      VStack(alignment: .leading, spacing: 8) {
        Text("Date of Birth")
          .font(.subheadline.weight(.medium))
        
        DatePicker(
          "Birth Date",
          selection: Binding(
            get: { userSettings.birthDate },
            set: { 
              userSettings.birthDate = $0
              userSettings.invalidateCache()
            }
          ),
          displayedComponents: .date
        )
        .datePickerStyle(.compact)
        .labelsHidden()
      }
      
      VStack(alignment: .leading, spacing: 8) {
        Text("Life Expectancy")
          .font(.subheadline.weight(.medium))
        
        HStack(spacing: 12) {
          VStack(alignment: .leading, spacing: 4) {
            Text("Years")
              .font(.caption)
              .foregroundStyle(.secondary)
            
            TextField(
              "Years",
              value: Binding(
                get: { userSettings.lifeExpectancyYears },
                set: { 
                  userSettings.lifeExpectancyYears = max(0, min(120, $0))
                  userSettings.invalidateCache()
                }
              ),
              format: .number
            )
            .textFieldStyle(.roundedBorder)
            .frame(width: 60)
          }
          
          VStack(alignment: .leading, spacing: 4) {
            Text("Months")
              .font(.caption)
              .foregroundStyle(.secondary)
            
            TextField(
              "Months",
              value: Binding(
                get: { userSettings.lifeExpectancyMonths },
                set: { 
                  userSettings.lifeExpectancyMonths = max(0, min(12, $0))
                  userSettings.invalidateCache()
                }
              ),
              format: .number
            )
            .textFieldStyle(.roundedBorder)
            .frame(width: 60)
          }
          
          VStack(alignment: .leading, spacing: 4) {
            Text("Weeks")
              .font(.caption)
              .foregroundStyle(.secondary)
            
            TextField(
              "Weeks",
              value: Binding(
                get: { userSettings.lifeExpectancyWeeks },
                set: { 
                  userSettings.lifeExpectancyWeeks = max(0, min(4, $0))
                  userSettings.invalidateCache()
                }
              ),
              format: .number
            )
            .textFieldStyle(.roundedBorder)
            .frame(width: 60)
          }
        }
      }
      
      Button("Save") {
        try? modelContext.save()
        onSave()
      }
      .keyboardShortcut(.return)
      .buttonStyle(.bordered)
      .controlSize(.large)
      .padding(.top)
    }
    .padding()
    .frame(width: 300)
  }
}

#Preview {
  EditableSettingsView(
    userSettings: UserSettings(
      birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date(),
      lifeExpectancyYears: 75,
      lifeExpectancyMonths: 4,
      lifeExpectancyWeeks: 2
    ),
    onSave: {}
  )
}
