//
//  StatisticsView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 10/31/23.
//

import SwiftUI
import Charts
import Supabase

struct StatisticsView: View {
    
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var usageData: [UsageDataUpload] = []
    @State var decodedUsageData: [[UsageData]] = []
    @State var currUserIndex = 0
    @State var isLoading = false
    @State var showUserDetails = false
    @State var showStatsDetails = false
    @State var showTotalSheets = false
    @State var showTotalCustomIcons = false
    @State var showTotalDocuments = false
    @State var password = ""
    private let devPassword = "071321!"
    
    var body: some View {
        if password != devPassword {
            Spacer()
            Text("\(Image(systemName: "exclamationmark.triangle.fill")) Developer Access Only")
                .minimumScaleFactor(0.01)
                .multilineTextAlignment(.center)
                .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                .foregroundColor(.orange)
                .padding()
            Button(action: {
                self.presentation.wrappedValue.dismiss()
            }) {
                Text("\(Image(systemName: "arrow.backward")) Back")
                    .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .padding([.top, .bottom, .trailing], horizontalSizeClass == .compact ? 5 : 10)
                    .padding()
            }
            .background(.ultraThinMaterial)
            .cornerRadius(horizontalSizeClass == .compact ? 20 : 25)
            .buttonStyle(PlainButtonStyle())
            .padding()
            SecureField("", text: $password)
                .multilineTextAlignment(.center)
                .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                .accentColor(Color(.systemBackground))
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(.systemBackground))
                )
                .padding()
            Spacer()
        } else {
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack {
                        Text("\(Image(systemName: "chart.bar.xaxis")) Usage Dashboard")
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                            .padding()
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                        LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                            if #available(iOS 16.0, *) {
                                Button(action: {
                                    showStatsDetails.toggle()
                                    showTotalSheets.toggle()
                                }) {
                                    ZStack {
                                        Image(systemName: "app.fill")
                                            .resizable()
                                            .foregroundStyle(Color(.systemGray6))
                                            .scaledToFit()
                                        VStack {
                                            ZStack {
                                                Color.clear.frame(width: horizontalSizeClass == .compact ? 30 : 45, height: horizontalSizeClass == .compact ? 30 : 45)
                                                    .padding()
                                                Text(String(format: "%.2f", averageTotalSheets))
                                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 45, weight: .bold, design: .rounded))
                                            }
                                            Text("Average Sheets")
                                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                                .lineLimit(2)
                                                .multilineTextAlignment(.center)
                                                .foregroundStyle(.gray)
                                        }
                                        .padding(5)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: {
                                    showStatsDetails.toggle()
                                    showTotalCustomIcons.toggle()
                                }) {
                                    ZStack {
                                        Image(systemName: "app.fill")
                                            .resizable()
                                            .foregroundStyle(Color(.systemGray6))
                                            .scaledToFit()
                                        VStack {
                                            ZStack {
                                                Color.clear.frame(width: horizontalSizeClass == .compact ? 30 : 45, height: horizontalSizeClass == .compact ? 30 : 45)
                                                    .padding()
                                                Text(String(format: "%.2f", averageTotalCustomIcons))
                                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 45, weight: .bold, design: .rounded))
                                            }
                                            Text("Average Custom Icons")
                                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                                .lineLimit(2)
                                                .multilineTextAlignment(.center)
                                                .foregroundStyle(.gray)
                                        }
                                        .padding(5)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: {
                                    showStatsDetails.toggle()
                                    showTotalDocuments.toggle()
                                }) {
                                    ZStack {
                                        Image(systemName: "app.fill")
                                            .resizable()
                                            .foregroundStyle(Color(.systemGray6))
                                            .scaledToFit()
                                        VStack {
                                            ZStack {
                                                Color.clear.frame(width: horizontalSizeClass == .compact ? 30 : 45, height: horizontalSizeClass == .compact ? 30 : 45)
                                                    .padding()
                                                Text(String(format: "%.2f", averageItemsInDocuments))
                                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 45, weight: .bold, design: .rounded))
                                            }
                                            Text("Average Documents")
                                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                                .lineLimit(2)
                                                .multilineTextAlignment(.center)
                                                .foregroundStyle(.gray)
                                        }
                                        .padding(5)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: {
                                    showStatsDetails.toggle()
                                }) {
                                    ZStack {
                                        Image(systemName: "app.fill")
                                            .resizable()
                                            .foregroundStyle(Color(.systemGray6))
                                            .scaledToFit()
                                        VStack {
                                            ZStack {
                                                Color.clear.frame(width: horizontalSizeClass == .compact ? 30 : 45, height: horizontalSizeClass == .compact ? 30 : 45)
                                                    .padding()
                                                Text(String(format: "%.2f", averageDataArrayLength))
                                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 45, weight: .bold, design: .rounded))
                                            }
                                            Text("Average Usage")
                                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                                .lineLimit(2)
                                                .multilineTextAlignment(.center)
                                                .foregroundStyle(.gray)
                                        }
                                        .padding(5)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            if #available(iOS 17.0, *) { //charts
                                ZStack {
                                    Image(systemName: "app.fill")
                                        .resizable()
                                        .foregroundStyle(Color(.systemGray6))
                                        .scaledToFit()
                                    Chart(deviceModelProportions.keys.sorted(), id: \.self) { key in
                                        let value = deviceModelProportions[key] ?? 0.0
                                        SectorMark(
                                            angle: .value("Value", value),
                                            innerRadius: .ratio(0.0),
                                            outerRadius: .ratio(1.0)
                                        )
                                        .foregroundStyle(by: .value("Key", key))
                                    }
                                    .aspectRatio(1, contentMode: .fit)
                                    .padding()
                                }
                                ZStack {
                                    Image(systemName: "app.fill")
                                        .resizable()
                                        .foregroundStyle(Color(.systemGray6))
                                        .scaledToFit()
                                    Chart(systemVersionProportions.keys.sorted(), id: \.self) { key in
                                        let value = systemVersionProportions[key] ?? 0.0
                                        SectorMark(
                                            angle: .value("Value", value),
                                            innerRadius: .ratio(0.0),
                                            outerRadius: .ratio(1.0)
                                        )
                                        .foregroundStyle(by: .value("Key", key))
                                    }
                                    .aspectRatio(1, contentMode: .fit)
                                    .padding()
                                }
                                ZStack {
                                    Image(systemName: "app.fill")
                                        .resizable()
                                        .foregroundStyle(Color(.systemGray6))
                                        .scaledToFit()
                                    Chart(appVersionProportions.keys.sorted(), id: \.self) { key in
                                        let value = appVersionProportions[key] ?? 0.0
                                        SectorMark(
                                            angle: .value("Value", value),
                                            innerRadius: .ratio(0.0),
                                            outerRadius: .ratio(1.0)
                                        )
                                        .foregroundStyle(by: .value("Key", key))
                                    }
                                    .aspectRatio(1, contentMode: .fit)
                                    .padding()
                                }
                                ZStack {
                                    Image(systemName: "app.fill")
                                        .resizable()
                                        .foregroundStyle(Color(.systemGray6))
                                        .scaledToFit()
                                    Chart(customIconProportions.keys.sorted(), id: \.self) { key in
                                        let value = customIconProportions[key] ?? 0.0
                                        SectorMark(
                                            angle: .value("Value", value),
                                            innerRadius: .ratio(0.0),
                                            outerRadius: .ratio(1.0)
                                        )
                                        .foregroundStyle(by: .value("Key", key))
                                    }
                                    .aspectRatio(1, contentMode: .fit)
                                    .padding()
                                }
                            }
                        }
                        Divider().padding()
                        ForEach(0..<usageData.count, id: \.self) { usageIndex in
                            Button(action: {
                                currUserIndex = usageIndex
                                showUserDetails.toggle()
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("\(deviceModels[usageData[usageIndex].device_identifier ?? "?"] ?? usageData[usageIndex].device_identifier ?? "?"), \(usageData[usageIndex].system_name ?? "?") \(usageData[usageIndex].system_version ?? "?")")
                                            .font(.system(size: horizontalSizeClass == .compact ? 15 : 20, weight: .bold, design: .rounded))
                                        if decodedUsageData.count == usageData.count {
                                            Text("\(usageData[usageIndex].user_id?.uuidString ?? "")")
                                                .lineLimit(1)
                                                .font(.system(size: horizontalSizeClass == .compact ? 12 : 18, weight: .medium, design: .rounded))
                                                .foregroundStyle(.gray)
                                        }
                                    }
                                    Spacer()
                                    Text("\(Image(systemName: "chevron.forward"))")
                                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                        .opacity(0.4)
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(horizontalSizeClass == .compact ? 20 : 25)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.bottom, 150)
                }
                .navigationBarHidden(true)
                .refreshable {
                    currSessionLog.append("refreshing")
                    do {
                        usageData = try await client
                            .from("DaysyUsage")
                            .select()
                            .execute()
                            .value
                        // First decode and update accounts
                        currSessionLog.append("updating account array")
                        currSessionLog.append("done updating")
                    } catch {
                        currSessionLog.append(error.localizedDescription)
                    }
                    decodedUsageData.removeAll()
                    for data in usageData {
                        if let decodedData = try? decoder.decode([UsageData].self, from: data.usage_data ?? Data()) {
                            let sortedData = decodedData.map { usageData in
                                UsageData(date: Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: usageData.date) ?? usageData.date,
                                          data: usageData.data)
                            }
                            decodedUsageData.append(fillMissingDates(in: sortedData))
                        }
                    }
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            self.presentation.wrappedValue.dismiss()
                        }) {
                            Text("\(Image(systemName: "arrow.backward")) Back")
                                .lineLimit(1)
                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                                .padding(horizontalSizeClass == .compact ? 20 : 30)
                        }
                        .background(.ultraThinMaterial)
                        .cornerRadius(horizontalSizeClass == .compact ? 20 : 25)
                        .padding()
                        .navigationBarHidden(true)
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                    }
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color(.systemBackground), Color(.systemBackground), Color.clear]), startPoint: .bottom, endPoint: .top)
                            .ignoresSafeArea()
                    )
                }
            }
            .task {
                await setupRealtimeChannel()
            }
            .sheet(isPresented: $showUserDetails) {
                UsageDetailView(usageData: $usageData, decodedUsageData: $decodedUsageData, currUserIndex: $currUserIndex)
            }
            .sheet(isPresented: $showStatsDetails) {
                VStack {
                    if #available(iOS 17.0, *) {
                        if showTotalSheets {
                            HStack {
                                Text("Total Sheets (By User)")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                    .padding(.top)
                                    .padding(.bottom, horizontalSizeClass == .compact ? 5 : 0)
                                if horizontalSizeClass == .compact {
                                    Spacer()
                                    Button(action: {
                                        showStatsDetails.toggle()
                                        showTotalSheets.toggle()
                                    }) {
                                        Text("\(Image(systemName: "xmark.circle.fill"))")
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.5)
                                            .font(.system(size: 30, weight: .bold, design: .rounded))
                                            .foregroundStyle(.gray)
                                            .symbolRenderingMode(.hierarchical)
                                    }
                                }
                            }
                            .padding()
                            Spacer()
                            Chart {
                                ForEach(usageData) { data in
                                    BarMark(
//                                        x: .value("Device", "\(data.device_identifier ?? "?") (\(data.id)"),
                                        x: .value("Device", "\(data.device_identifier ?? "?") (\(data.user_id?.uuidString ?? ""))"),
                                        y: .value("Total Sheets", data.total_sheets)
                                    )
                                    .cornerRadius(20.0)
                                }
                            }
                            .chartYAxis {
                                AxisMarks(values: .automatic(desiredCount: 2))
                            }
                            .scaledToFit()
                            .padding()
                        } else if showTotalCustomIcons {
                            HStack {
                                Text("Total Custom Icons (By User)")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                    .padding(.top)
                                    .padding(.bottom, horizontalSizeClass == .compact ? 5 : 0)
                                if horizontalSizeClass == .compact {
                                    Spacer()
                                    Button(action: {
                                        showStatsDetails.toggle()
                                        showTotalCustomIcons.toggle()
                                    }) {
                                        Text("\(Image(systemName: "xmark.circle.fill"))")
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.5)
                                            .font(.system(size: 30, weight: .bold, design: .rounded))
                                            .foregroundStyle(.gray)
                                            .symbolRenderingMode(.hierarchical)
                                    }
                                }
                            }
                            .padding()
                            Spacer()
                            Chart {
                                ForEach(usageData) { data in
                                    BarMark(
//                                        x: .value("Device", "\(data.device_identifier ?? "?") (\(data.id)"),
                                        x: .value("Device", "\(data.device_identifier ?? "?") (\(data.user_id?.uuidString ?? ""))"),
                                        y: .value("Total Custom Icons", data.total_custom_icons)
                                    )
                                    .cornerRadius(20.0)
                                }
                            }
                            .chartYAxis {
                                AxisMarks(values: .automatic(desiredCount: 2))
                            }
                            .scaledToFit()
                            .padding()
                        } else if showTotalDocuments {
                            HStack {
                                Text("Total Documents (By User)")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                    .padding(.top)
                                    .padding(.bottom, horizontalSizeClass == .compact ? 5 : 0)
                                if horizontalSizeClass == .compact {
                                    Spacer()
                                    Button(action: {
                                        showStatsDetails.toggle()
                                        showTotalDocuments.toggle()
                                    }) {
                                        Text("\(Image(systemName: "xmark.circle.fill"))")
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.5)
                                            .font(.system(size: 30, weight: .bold, design: .rounded))
                                            .foregroundStyle(.gray)
                                            .symbolRenderingMode(.hierarchical)
                                    }
                                }
                            }
                            .padding()
                            Spacer()
                            Chart {
                                ForEach(usageData) { data in
                                    BarMark(
                                        x: .value("Device", "\(data.device_identifier ?? "?") (\(data.user_id?.uuidString ?? ""))"),
                                        y: .value("Total Documents", data.items_in_documents)
                                    )
                                    .cornerRadius(20.0)
                                }
                            }
                            .chartYAxis {
                                AxisMarks(values: .automatic(desiredCount: 2))
                            }
                            .scaledToFit()
                            .padding()
                        } else {
                            HStack {
                                Text("Total Usage (By User)")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                    .padding(.top)
                                    .padding(.bottom, horizontalSizeClass == .compact ? 5 : 0)
                                if horizontalSizeClass == .compact {
                                    Spacer()
                                    Button(action: {
                                        showStatsDetails.toggle()
                                    }) {
                                        Text("\(Image(systemName: "xmark.circle.fill"))")
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.5)
                                            .font(.system(size: 30, weight: .bold, design: .rounded))
                                            .foregroundStyle(.gray)
                                            .symbolRenderingMode(.hierarchical)
                                    }
                                }
                            }
                            .padding()
                            Spacer()
                            Chart {
                                ForEach(Array(decodedUsageData.enumerated()), id: \.offset) { (index, usageArray) in
                                    // Your code to handle each element
                                    BarMark(
//                                        x: .value("Device", usageData[index].device_identifier ?? "?"),
                                        x: .value("Device", "\(usageData[index].device_identifier ?? "?") (\(usageData[index].user_id?.uuidString ?? ""))"),
                                        y: .value("Total Usage", usageArray.filter { !$0.data.isEmpty }.count)
                                    )
                                    .cornerRadius(20.0)
                                }
                            }
                            .chartYAxis {
                                AxisMarks(values: .automatic(desiredCount: 2))
                            }
                            .scaledToFit()
                            .padding()
                        }
                    }
                }
            }
        }
    }
    var averageDataArrayLength: Double {
        guard !decodedUsageData.isEmpty else { return 0.0 }
        
        var totalDataCount = 0
        for usageDataArray in decodedUsageData {
            for usageData in usageDataArray {
                totalDataCount += usageData.data.count
            }
        }
        return Double(totalDataCount) / Double(decodedUsageData.count)
    }
    var averageTotalSheets: Double {
        guard !usageData.isEmpty else { return 0.0 }
        let totalSheetsSum = usageData.reduce(0) { $0 + $1.total_sheets }
        return Double(totalSheetsSum) / Double(usageData.count)
    }
    var averageTotalCustomIcons: Double {
        guard !usageData.isEmpty else { return 0.0 }
        let totalCustomIconsSum = usageData.reduce(0) { $0 + $1.total_custom_icons }
        return Double(totalCustomIconsSum) / Double(usageData.count)
    }
    var averageItemsInDocuments: Double {
        guard !usageData.isEmpty else { return 0.0 }
        let itemsInDocumentsSum = usageData.reduce(0) { $0 + $1.items_in_documents }
        return Double(itemsInDocumentsSum) / Double(usageData.count)
    }
    var deviceModelProportions: [String: Double] {
        // Count the occurrences of each system_name
        var deviceModelCounts: [String: Int] = [:]
        for usageData in usageData {
            if let deviceModel = usageData.device_model {
                deviceModelCounts[deviceModel, default: 0] += 1
            }
        }
        
        // Calculate the total number of system_name entries
        let totalCount = usageData.count
        
        // Calculate the proportions
        var deviceModelProportions: [String: Double] = [:]
        for (deviceModel, count) in deviceModelCounts {
            deviceModelProportions[deviceModel] = Double(count) / Double(totalCount)
        }
        
        return deviceModelProportions
    }
    var customIconProportions: [String: Double] {
        let totalCount = usageData.count
        let counts: [String: Int] = usageData.reduce(into: ["Has Custom": 0, "No Custom": 0]) { counts, data in
            if data.total_custom_icons >= 1 {
                counts["Has Custom", default: 0] += 1
            } else {
                counts["No Custom", default: 0] += 1
            }
        }
        
        return counts.mapValues { Double($0) / Double(totalCount) }
    }
    var systemVersionProportions: [String: Double] {
        // Count the occurrences of each system_version
        var systemVersionCounts: [String: Int] = [:]
        for usageData in usageData {
            if let systemVersion = usageData.system_version {
                systemVersionCounts[systemVersion, default: 0] += 1
            }
        }
        
        // Calculate the total number of system_version entries
        let totalCount = usageData.count
        
        // Calculate the proportions
        var systemVersionProportions: [String: Double] = [:]
        for (systemVersion, count) in systemVersionCounts {
            systemVersionProportions[systemVersion] = Double(count) / Double(totalCount)
        }
        
        return systemVersionProportions
    }
    var appVersionProportions: [String: Double] {
        // Count the occurrences of each app_version
        var appVersionCounts: [String: Int] = [:]
        for usageData in usageData {
            if let appVersion = usageData.app_version {
                appVersionCounts[appVersion, default: 0] += 1
            }
        }
        
        // Calculate the total number of app_version entries
        let totalCount = usageData.count
        
        // Calculate the proportions
        var appVersionProportions: [String: Double] = [:]
        for (appVersion, count) in appVersionCounts {
            appVersionProportions[appVersion] = Double(count) / Double(totalCount)
        }
        
        return appVersionProportions
    }
    
    func setupRealtimeChannel() async {
        do {
            usageData = try await client
                .from("DaysyUsage")
                .select()
                .execute()
                .value
        } catch {
            currSessionLog.append(error.localizedDescription)
        }
        currSessionLog.append("recieved \(usageData.count) data")
        decodedUsageData.removeAll()
        for data in usageData {
            if let decodedData = try? decoder.decode([UsageData].self, from: data.usage_data ?? Data()) {
                let sortedData = decodedData.map { usageData in
                    UsageData(date: Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: usageData.date) ?? usageData.date,
                              data: usageData.data)
                }
                decodedUsageData.append(fillMissingDates(in: sortedData))
            }
        }
        isLoading = false
        
        let channel = client.realtimeV2.channel("public:DaysyUsage")
        
        
        let changes = channel.postgresChange(
            AnyAction.self,
            schema: "public",
            table: "DaysyUsage"
        )
        
        
        await channel.subscribe()
        currSessionLog.append("\(channel.status) to channel")
        
        for await _ in changes {
            isLoading = true
            currSessionLog.append("detected change")
            do {
                usageData = try await client
                    .from("DaysyUsage")
                    .select()
                    .execute()
                    .value
                // First decode and update accounts
                currSessionLog.append("updating account array")
                currSessionLog.append("done updating")
            } catch {
                currSessionLog.append(error.localizedDescription)
            }
            decodedUsageData.removeAll()
            for data in usageData {
                if let decodedData = try? decoder.decode([UsageData].self, from: data.usage_data ?? Data()) {
                    let sortedData = decodedData.map { usageData in
                        UsageData(date: Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: usageData.date) ?? usageData.date,
                                  data: usageData.data)
                    }
                    decodedUsageData.append(fillMissingDates(in: sortedData))
                }
            }
            isLoading = false
        }
    }
}

struct UsageDetailView: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @Binding var usageData: [UsageDataUpload]
    @Binding var decodedUsageData: [[UsageData]]
    @Binding var currUserIndex: Int
    
    var body: some View {
        let mostIcons = mostUsedIcons(decodedUsageData[currUserIndex])
        ScrollView(showsIndicators: false) {
        VStack {
            HStack(alignment: horizontalSizeClass == .compact ? .top : .center) {
                VStack(alignment: horizontalSizeClass == .compact ? .leading : .center) {
                    Text("\(deviceModels[usageData[currUserIndex].device_identifier ?? "?"] ?? usageData[currUserIndex].device_identifier ?? "?")")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                    Text("\(usageData[currUserIndex].system_name ?? "?") \(usageData[currUserIndex].system_version ?? "?")")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .foregroundStyle(.gray)
                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 35, weight: .bold, design: .rounded))
                    Text("\(usageData[currUserIndex].app_version ?? "?") (\(usageData[currUserIndex].bundle_version ?? "?"))")
                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 35, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .foregroundStyle(Color.accentColor)
                }
                if horizontalSizeClass == .compact {
                    Spacer()
                    Button(action: {
                        self.presentation.wrappedValue.dismiss()
                    }) {
                        Text("\(Image(systemName: "xmark.circle.fill"))")
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(.gray)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .padding()
            
            LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                ZStack {
                    Image(systemName: "app.fill")
                        .resizable()
                        .foregroundStyle(Color(.systemGray4))
                        .scaledToFit()
                    VStack {
                        ZStack {
                            Color.clear.frame(width: horizontalSizeClass == .compact ? 30 : 45, height: horizontalSizeClass == .compact ? 30 : 45)
                                .padding()
                            Text(String(usageData[currUserIndex].total_sheets))
                                .font(.system(size: horizontalSizeClass == .compact ? 30 : 45, weight: .bold, design: .rounded))
                        }
                        Text("Total Sheets")
                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.gray)
                    }
                    .padding(5)
                }
                
                ZStack {
                    Image(systemName: "app.fill")
                        .resizable()
                        .foregroundStyle(Color(.systemGray4))
                        .scaledToFit()
                    VStack {
                        ZStack {
                            Color.clear.frame(width: horizontalSizeClass == .compact ? 30 : 45, height: horizontalSizeClass == .compact ? 30 : 45)
                                .padding()
                            Text(String(usageData[currUserIndex].total_custom_icons))
                                .font(.system(size: horizontalSizeClass == .compact ? 30 : 45, weight: .bold, design: .rounded))
                        }
                        Text("Custom Icons")
                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.gray)
                    }
                    .padding(5)
                }
                
                ZStack {
                    Image(systemName: "app.fill")
                        .resizable()
                        .foregroundStyle(Color(.systemGray4))
                        .scaledToFit()
                    VStack {
                        ZStack {
                            Color.clear.frame(width: horizontalSizeClass == .compact ? 30 : 45, height: horizontalSizeClass == .compact ? 30 : 45)
                                .padding()
                            Text(String(usageData[currUserIndex].items_in_documents))
                                .font(.system(size: horizontalSizeClass == .compact ? 30 : 45, weight: .bold, design: .rounded))
                        }
                        Text("Total Documents")
                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.gray)
                    }
                    .padding(5)
                }
                ZStack {
                    Image(systemName: "app.fill")
                        .resizable()
                        .foregroundStyle(Color(.systemGray4))
                        .scaledToFit()
                    VStack {
                        ZStack {
                            Color.clear.frame(width: horizontalSizeClass == .compact ? 30 : 45, height: horizontalSizeClass == .compact ? 30 : 45)
                                .padding()
                            Text(String(decodedUsageData[currUserIndex].flatMap { $0.data }.count))
                                .font(.system(size: horizontalSizeClass == .compact ? 30 : 45, weight: .bold, design: .rounded))
                        }
                        Text("Total Usage")
                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.gray)
                    }
                    .padding(5)
                }
                ZStack {
                    Image(systemName: "app.fill")
                        .resizable()
                        .foregroundStyle(Color(.systemGray4))
                        .scaledToFit()
                    VStack {
                        ZStack {
                            Color.clear.frame(width: horizontalSizeClass == .compact ? 30 : 45, height: horizontalSizeClass == .compact ? 30 : 45)
                                .padding()
                            Text("\(decodedUsageData[currUserIndex][0].date, style: .date)")
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                                .font(.system(size: horizontalSizeClass == .compact ? 30 : 45, weight: .bold, design: .rounded))
                        }
                        Text("First Active")
                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.gray)
                    }
                    .padding(5)
                }
                
                ZStack {
                    Image(systemName: "app.fill")
                        .resizable()
                        .foregroundStyle(Color(.systemGray4))
                        .scaledToFit()
                    VStack {
                        ZStack {
                            Color.clear.frame(width: horizontalSizeClass == .compact ? 30 : 45, height: horizontalSizeClass == .compact ? 30 : 45)
                                .padding()
                            Text("\(decodedUsageData[currUserIndex][decodedUsageData[currUserIndex].count - 1].date, style: .date)")
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                                .font(.system(size: horizontalSizeClass == .compact ? 30 : 45, weight: .bold, design: .rounded))
                        }
                        Text("Last Active")
                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.gray)
                    }
                    .padding(5)
                }
            }
            .padding()
                if #available(iOS 16.0, *) { //make the x axis label reflect the period of dates showng
                    Text("\(Image(systemName: "chart.line.uptrend.xyaxis")) Usage Breakdown")
                    .lineLimit(1)
                    .minimumScaleFactor(0.01)
                    .font(.system(size: horizontalSizeClass == .compact ? 20 : 35, weight: .bold, design: .rounded))
                    .foregroundStyle(.gray)
                    .padding()
                    
                    Chart(decodedUsageData[currUserIndex]) {
                        BarMark( //wierd issues with areamark at the moment, maybe just keep it at barmark and remove this section
                            x: .value("Date", formatDateToString($0.date)),
                            y: .value("Usage", $0.data.count)
                        )
                        .cornerRadius(20)
                    }
                    .chartYAxis {
                        AxisMarks(values: .automatic(desiredCount: 2))
                    }
                    .foregroundStyle(Color.accentColor)
                    .frame(height: 400)
                    .padding()
                }
                Spacer()
                Spacer()
                if mostIcons.filter({ $0.starts(with: "action:") }).count != mostIcons.count {
                    Text("\(Image(systemName: "star.square.on.square")) Most Used Icons")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 35, weight: .bold, design: .rounded))
                        .foregroundStyle(.gray)
                        .padding()
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(0..<mostIcons.prefix(10).count, id: \.self) { item in
                                if String(mostIcons[item].prefix(7)) != "action:" {
                                    VStack {
                                        if UIImage(named: mostIcons[item]) == nil {
                                            //check if default icon or custom icon and handle
                                            if horizontalSizeClass == .compact {
                                                getCustomIcon(mostIcons[item])
                                                    .frame(width:min(250, 500), height: min(250, 500))
                                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 15)
                                                            .stroke(.black, lineWidth: 5)
                                                    )
                                                    .padding()
                                            } else {
                                                getCustomIcon(mostIcons[item])
                                                    .frame(width:min(350, 1000), height: min(350, 1000))
                                                    .clipShape(RoundedRectangle(cornerRadius: 30))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 30)
                                                            .stroke(.black, lineWidth: 10)
                                                    )
                                                    .padding()
                                            }
                                        } else {
                                            Image(mostIcons[item])
                                                .resizable()
                                                .frame(width: horizontalSizeClass == .compact ? min(250, 500) : min(350, 1000), height: horizontalSizeClass == .compact ? min(250, 500) : min(350, 1000))
                                                .clipShape(RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 15 : 30))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 15 : 30)
                                                        .stroke(.black, lineWidth: horizontalSizeClass == .compact ? 5 : 10)
                                                )
                                                .padding()
                                        }
                                        Text(" '\(mostIcons[item])' used \(howmany(in: decodedUsageData[currUserIndex], for: mostIcons[item])) times")
                                            .font(.title3)
                                            .foregroundStyle(.gray)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
            
        }
    }
}

#Preview {
    StatisticsView()
}
