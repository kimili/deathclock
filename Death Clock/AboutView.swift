//
//  AboutView.swift
//  Death Clock
//
//  Created by Michael Bester on 7/16/25.
//

import SwiftUI

struct AboutView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Spacer()
        .frame(height: 16)
      
      HStack {
        Image("hourglass")
          .resizable()
          .frame(width: 42, height: 48)
          .foregroundStyle(.secondary)
        
        VStack(alignment: .leading, spacing: 4) {
          Text("Death Clock")
            .font(.title.bold())
          
          Text("Version 1.0")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
      }
      
      VStack(alignment: .leading, spacing: 12) {
        Text("About")
          .font(.headline)
        
        Text("Death Clock is a Memento Mori, a reminder that you will eventually perish. Give it your date of birth, as well as how old you think you might live to, and it gives you a visual overview of the life you’ve lived, and the life that remains.")
          .font(.body)
          .fixedSize(horizontal: false, vertical: true)
        
        Text("How can you the most of the time you have left?")
          .font(.body)
          .italic()
          .fixedSize(horizontal: false, vertical: true)
      }
      
      VStack(alignment: .leading, spacing: 8) {
        Text("Developer")
          .font(.headline)
        
        Text("Michael Bester, with help from Claude Code.")
          .font(.body)
          
        Text("https://michaelbester.com")
          .font(.body)
        
        Text("Built on \(buildDateString)")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      
      Spacer()
    }
    .padding(24)
    .frame(width: 400, height: 340)
    .background(Color(NSColor.controlBackgroundColor))
  }
  
  private var buildDateString: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter.string(from: buildDate)
  }
  
  private var buildDate: Date {
    // Try to get build date from bundle info, fallback to current date
    if let infoPath = Bundle.main.path(forResource: "Info", ofType: "plist"),
       let infoDict = NSDictionary(contentsOfFile: infoPath),
       let buildDateString = infoDict["CFBundleVersion"] as? String,
       let buildTimestamp = TimeInterval(buildDateString) {
      return Date(timeIntervalSince1970: buildTimestamp)
    }
    
    // Fallback: use compilation date (approximate)
    return Date()
  }
}

#Preview {
  AboutView()
}
