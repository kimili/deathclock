//
//  SettingsView.swift
//  Death Clock
//
//  Created by Michael Bester on 7/16/25.
//

import SwiftUI

struct SettingsView: View {
  @Binding var userSettings: UserSettings
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Settings")
        .font(.headline)
      
      VStack(alignment: .leading, spacing: 8) {
        Text("Date of Birth")
          .font(.subheadline.weight(.medium))
        
        DatePicker(
          "Birth Date",
          selection: $userSettings.birthDate,
          displayedComponents: .date
        )
        .datePickerStyle(.compact)
        .labelsHidden()
      }
      
      VStack(alignment: .leading, spacing: 8) {
        Text("Your Life Expectancy")
          .font(.subheadline.weight(.medium))
        
        HStack(spacing: 12) {
          VStack(alignment: .leading, spacing: 4) {
            Text("Years")
              .font(.caption)
              .foregroundStyle(.secondary)
            
            TextField(
              "Years",
              value: $userSettings.lifeExpectancyYears,
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
              value: $userSettings.lifeExpectancyMonths,
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
              value: $userSettings.lifeExpectancyWeeks,
              format: .number
            )
            .textFieldStyle(.roundedBorder)
            .frame(width: 60)
          }
        }
      }
      
      HStack {
        Button("Save") {
          dismiss()
        }
        .keyboardShortcut(.return)
        .buttonStyle(.borderedProminent)
      }
      .padding(.top)
    }
    .padding(24)
    .background(Color(NSColor.controlBackgroundColor))
    .frame(width: 280)
  }
}

#Preview {
  SettingsView(
    userSettings: .constant(
      UserSettings(
        birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date(),
        lifeExpectancyYears: 75
      )
    )
  )
}
