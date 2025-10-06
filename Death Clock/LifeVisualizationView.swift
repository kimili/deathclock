//
//  LifeVisualizationView.swift
//  Death Clock
//
//  Created by Michael Bester on 7/16/25.
//

import SwiftUI

struct LifeVisualizationView: View {
  let userSettings: UserSettings
  @Binding var showingSettings: Bool
  
  private let blocksPerRow = 52
  private let blockSize: CGFloat = 6
  private let blockSpacing: CGFloat = 1
  
  @State private var hoveredWeek: Int? = nil
  @State private var tooltipPosition: CGPoint = .zero
  @State private var blockData: [BlockRow] = []

  // Reuse date formatter to avoid creating new instances
  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"
    return formatter
  }()

  struct BlockRow: Identifiable {
    let id: Int
    let blocks: [WeekBlock]
  }

  struct WeekBlock: Identifiable {
    let id: Int
    let weekNumber: Int
    let isPast: Bool
    let isLast: Bool
  }
  
  var body: some View {
    if userSettings.weeksLived >= userSettings.totalLifeExpectancyInWeeks {
      // Easter egg for users who have outlived their life expectancy
      wowYouAreStillHereView
    } else {
      // Normal view
      visualizeYourLifeView
    }
  }
  
  private var visualizeYourLifeView: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Text("Death Clock 💀")
          .font(.headline)
          .foregroundStyle(.primary)
        
        Spacer()
        
        Button(action: {
          showingSettings = true
        }) {
          Image(systemName: "gearshape")
            .foregroundStyle(.secondary)
            .font(.system(size: 16))
        }
        .buttonStyle(.plain)
        .help("Settings")
      }
      
      statisticsView
      
      percentageView
      
      weekBlocksView
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .coordinateSpace(name: "mainView")
    .padding()
    .background(Color(NSColor.controlBackgroundColor))
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .overlay(alignment: .topLeading) {
      if let hoveredWeek = hoveredWeek {
        tooltipView(for: hoveredWeek)
          .offset(x: tooltipPosition.x, y: tooltipPosition.y)
          .zIndex(1000)
          .allowsHitTesting(false)
      }
    }
  }
  
  private var wowYouAreStillHereView: some View {
    VStack(alignment: .center, spacing: 16) {
      HStack {
        Text("Death Clock")
          .font(.headline)
          .foregroundStyle(.primary)
        
        Spacer()
        
        Button(action: {
          showingSettings = true
        }) {
          Image(systemName: "gearshape")
            .foregroundStyle(.secondary)
            .font(.system(size: 16))
        }
        .buttonStyle(.plain)
        .help("Settings")
      }
      
      Spacer()
      
      VStack(spacing: 20) {
        Text("🎉")
          .font(.system(size: 80))
        
        VStack(spacing: 12) {
          Text("You’ve beaten the odds!")
            .font(.title.bold())
            .foregroundStyle(.primary)
          
          Text("If you’re reading this, get away from the computer and go hug the people you love.")
            .font(.body)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(32)
      }
      
      Spacer()
    }
    .padding()
    .background(Color(NSColor.controlBackgroundColor))
    .clipShape(RoundedRectangle(cornerRadius: 8))
  }
  
  private var statisticsView: some View {
    HStack(spacing: 16) {
      VStack(alignment: .leading, spacing: 2) {
        Text("\(userSettings.weeksLived)")
          .font(.title2.bold())
          .foregroundStyle(.secondary)
        Text("Weeks lived")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      
      VStack(alignment: .leading, spacing: 2) {
        Text("\(userSettings.weeksRemaining)")
          .font(.title2.bold())
          .foregroundStyle(.green)
        Text("Weeks remaining")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      
      Spacer()
    }
  }
  
  private var percentageView: some View {
    let percentageLived = Double(userSettings.weeksLived) / Double(userSettings.totalLifeExpectancyInWeeks) * 100
    
    return VStack(alignment: .leading, spacing: 4) {
      Text("You've lived \(Int(percentageLived))% of your life.")
        .font(.body.weight(.medium))
        .foregroundStyle(.primary)
      
      Text("How will you spend the rest of it?")
        .font(.body)
        .foregroundStyle(.secondary)
        .italic()
    }
    .padding(.vertical, 4)
  }
  
  private var weekBlocksView: some View {
    VStack(alignment: .leading, spacing: blockSpacing) {
      ForEach(blockData) { row in
        HStack(spacing: blockSpacing) {
          ForEach(row.blocks) { block in
            Rectangle()
              .fill(block.isLast ? Color.red : (block.isPast ? Color.gray.opacity(0.3) : Color.green))
              .frame(width: blockSize, height: blockSize)
              .onHover { isHovering in
                if isHovering {
                  hoveredWeek = block.weekNumber
                  tooltipPosition = calculateTooltipPosition(for: block.weekNumber, displayRow: row.id, col: block.id)
                } else if hoveredWeek == block.weekNumber {
                  hoveredWeek = nil
                }
              }
          }
        }
      }
    }
    .task {
      await prepareBlockData()
    }
    .onChange(of: userSettings.totalLifeExpectancyInWeeks) { _, _ in
      Task {
        await prepareBlockData()
      }
    }
    .onChange(of: userSettings.weeksLived) { _, _ in
      Task {
        await prepareBlockData()
      }
    }
  }

  private func prepareBlockData() async {
    let totalWeeks = userSettings.totalLifeExpectancyInWeeks
    let weeksLived = userSettings.weeksLived
    let totalRows = (totalWeeks + blocksPerRow - 1) / blocksPerRow
    let lastWeekNumber = totalWeeks - 1

    // Pre-compute all block data off the main thread
    let rows = await Task.detached {
      var tempRows: [BlockRow] = []

      for displayRow in 0..<totalRows {
        // Reverse the row order so future weeks are at top
        let actualRow = totalRows - 1 - displayRow
        var blocks: [WeekBlock] = []

        for col in 0..<blocksPerRow {
          let weekNumber = actualRow * blocksPerRow + col

          // Only add blocks that are within the total weeks
          if weekNumber < totalWeeks {
            blocks.append(WeekBlock(
              id: col,
              weekNumber: weekNumber,
              isPast: weekNumber < weeksLived,
              isLast: weekNumber == lastWeekNumber
            ))
          }
        }

        if !blocks.isEmpty {
          tempRows.append(BlockRow(id: displayRow, blocks: blocks))
        }
      }

      return tempRows
    }.value

    // Update on main thread
    await MainActor.run {
      blockData = rows
    }
  }
  
  private func tooltipView(for weekNumber: Int) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(weekDateString(for: weekNumber))
        .font(.caption.weight(.medium))
        .foregroundColor(.primary)
      
      Text(ageString(for: weekNumber))
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .padding(8)
    .background(Color(NSColor.controlBackgroundColor))
    .overlay(
      RoundedRectangle(cornerRadius: 4)
        .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
    )
    .clipShape(RoundedRectangle(cornerRadius: 4))
    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
  }
  
  private func weekDateString(for weekNumber: Int) -> String {
    let calendar = Calendar.current
    guard let weekDate = calendar.date(byAdding: .weekOfYear, value: weekNumber, to: userSettings.birthDate) else {
      return "Week \(weekNumber)"
    }
    return "Week of \(dateFormatter.string(from: weekDate))"
  }
  
  private func ageString(for weekNumber: Int) -> String {
    // Ensure we have a valid week number
    guard weekNumber >= 0 else { return "Not born yet" }
    
    // Calculate the date for this week number
    let calendar = Calendar.current
    guard let weekDate = calendar.date(byAdding: .weekOfYear, value: weekNumber, to: userSettings.birthDate) else {
      return "Week \(weekNumber)"
    }
    
    // If the week date is before birth, show "Not born yet"
    if weekDate < userSettings.birthDate {
      return "Not born yet"
    }
    
    // Calculate age components from birthdate to this week's date
    let ageComponents = calendar.dateComponents([.year, .month], 
                                              from: userSettings.birthDate, 
                                              to: weekDate)
    
    let years = ageComponents.year ?? 0
    let months = ageComponents.month ?? 0
    
    // Calculate weeks since the last full month
    let monthsSinceBirth = years * 12 + months
    guard let lastMonthBirthday = calendar.date(byAdding: .month, value: monthsSinceBirth, to: userSettings.birthDate) else {
      return "\(years) years, \(months) months old"
    }
    
    let weeksSinceLastMonth = calendar.dateComponents([.weekOfYear], from: lastMonthBirthday, to: weekDate).weekOfYear ?? 0
      
    let yearLabel = years == 1 ? "year" : "years"
    let monthLabel = months == 1 ? "month" : "months"
    let weekLabel = weeksSinceLastMonth == 1 ? "week" : "weeks"
    
    if years == 0 && months == 0 {
      return "\(weeksSinceLastMonth) \(weekLabel) old"
    } else if years == 0 {
      return "\(months) \(monthLabel), \(weeksSinceLastMonth) \(weekLabel) old"
    } else {
      // For display clarity, only show months within the current year
      let monthsInCurrentYear = months % 12
      if monthsInCurrentYear == 0 {
        return "\(years) \(yearLabel) old"
      } else {
        return "\(years) \(yearLabel), \(monthsInCurrentYear) \(monthLabel) old"
      }
    }
  }
  
  private func calculateTooltipPosition(for weekNumber: Int, displayRow: Int, col: Int) -> CGPoint {
    let tooltipWidth: CGFloat = 120
    let containerWidth: CGFloat = 400
    
    // Calculate header height (title + statistics + percentage views + spacing)
    let headerHeight: CGFloat = 110
    
    // Calculate block position
    let blockX = CGFloat(col) * (blockSize + blockSpacing)
    let blockY = headerHeight + CGFloat(displayRow) * (blockSize + blockSpacing)
    
    // Try to position to the right of the block
    let rightX = blockX + blockSize + 10
    let rightY = blockY - 10
    
    // If tooltip would go off the right edge, position to the left
    if rightX + tooltipWidth > containerWidth {
      let leftX = blockX - tooltipWidth - 10
      return CGPoint(x: max(0, leftX), y: rightY)
    } else {
      return CGPoint(x: rightX, y: rightY)
    }
  }
}

#Preview {
  LifeVisualizationView(
    userSettings: UserSettings(
      birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date(),
      lifeExpectancyYears: 75
    ),
    showingSettings: .constant(false)
  )
  .frame(width: 400)
}
