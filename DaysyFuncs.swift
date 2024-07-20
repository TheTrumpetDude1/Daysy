//
//  DaysyFuncs.swift
//  Daysy
//
//  Created by Alexander Eischeid on 11/13/23.
//

import Foundation
import SwiftUI
import AVFoundation
import UserNotifications
import CoreData
import LocalAuthentication
import NaturalLanguage
import Vision
import CoreML
import CoreGraphics
import PhotosUI
import Network
import OpenAI

var currSessionLog = [""]

func importAccount(jsonAccount: JSONAccount) -> Void {
    if let sheetArray = try? decoder.decode([SheetObject].self, from: jsonAccount.sheet_array ?? Data()),
       let communicationBoard = try? decoder.decode([[String]].self, from: jsonAccount.communication_board ?? Data()),
       let usage = try? decoder.decode([UsageData].self, from: jsonAccount.usage ?? Data()),
       let customPecsAddresses = try? decoder.decode([String: String].self, from: jsonAccount.custom_pecs_addresses ?? Data()),
       let customPecsImages = try? decoder.decode([String: Data].self, from: jsonAccount.custom_pecs_images ?? Data()),
       let settings = try? decoder.decode([String: Bool].self, from: jsonAccount.settings ?? Data()) {
        
        let account = Account(
            id: jsonAccount.id,
            first_name: jsonAccount.first_name ?? "",
            last_name: jsonAccount.last_name ?? "",
            user_name: jsonAccount.user_name ?? "",
            password: jsonAccount.password ?? "",
            email: jsonAccount.email ?? "",
            sheet_array: sheetArray,
            communication_board: communicationBoard,
            usage: usage,
            custom_pecs_addresses: customPecsAddresses,
            settings: settings, curr_voice_ratio: jsonAccount.curr_voice_ratio ?? 1.0, curr_voice: jsonAccount.curr_voice ?? "com.apple.ttsbundle.Daniel-compact", custom_pecs_images: customPecsImages,
            created_at: jsonAccount.created_at ?? Date()
        )
        
        saveCommunicationBoard(account.communication_board)
        saveSheetArray(sheetObjects: account.sheet_array)
        saveCustomPECSAddresses(account.custom_pecs_addresses)
        saveUsage(account.usage)
        for (key, value) in account.settings {
            defaults.setValue(value, forKey: key)
        }
        defaults.setValue(0, forKey: "currSheetIndex")
        
        //now also handle custom images
        
        for (name, imageData) in account.custom_pecs_images {
            if let loadedImage = UIImage(data: imageData) {
                currSessionLog.append(saveImageToDocumentsDirectory(loadedImage, fileName: name))
            }
        }
    }
}

func getCustomPECSImagesData() -> [String: Data] {
    var images: [String: Data] = [:]
    let customPECSAddresses = getCustomPECSAddresses()
    for (key, value) in customPECSAddresses {
        guard let localURL = URL(string: String("\(documentsURL)") + value) else {
            break
        }
        do {
            let imageData = try Data(contentsOf: localURL)
            images[key] = imageData
        } catch {
            currSessionLog.append(error.localizedDescription)
        }
    }
    return images
}

//func gptCreateSheet(name: String) -> SheetObject {
//    var sheet = SheetObject()
//    var currSlot = GridSlot()
//    var currLabelIcon = ""
//    var currLabel = name
//    
//    return sheet
//}

func saveSheetArray(sheetObjects: [SheetObject]) {
    if let encoded = try? encoder.encode(sheetObjects) {
        defaults.set(encoded, forKey: "sheetArray")
    }
}

func saveTappedIcons(_ icons: [String]) {
    if let encoded = try? encoder.encode(icons) {
        defaults.set(encoded, forKey: "tappedIcons")
    }
}

func loadTappedIcons() -> [String] {
    if let savedData = defaults.data(forKey: "tappedIcons") {
        if let loadedObjects = try? decoder.decode([String].self, from: savedData) {
            return loadedObjects
        }
    }
    return []
}

func saveHiddenIcons(_ icons: [String]) {
    if let encoded = try? encoder.encode(icons) {
        defaults.set(encoded, forKey: "hiddenIcons")
    }
}

func loadHiddenIcons() -> [String] {
    if let savedData = defaults.data(forKey: "hiddenIcons") {
        if let loadedObjects = try? decoder.decode([String].self, from: savedData) {
            return loadedObjects
        }
    }
    return []
}

func removeSheet(sheetIndex: Int) {
    var currArray = loadSheetArray()
    if sheetIndex < currArray.count {
        currArray.remove(at: sheetIndex)
        saveSheetArray(sheetObjects: currArray)
    }
}

func loadSheetArray() -> [SheetObject] {
    if let savedData = defaults.data(forKey: "sheetArray") {
        if let loadedObjects = try? decoder.decode([SheetObject].self, from: savedData) {
            return loadedObjects
        }
    }
    return [SheetObject(label: "Debug, ignore this page")]
}

func loadCommunicationBoard() -> [[String]] {
    if let savedData = defaults.data(forKey: "myCommunicationBoard") {
        if let loadedObjects = try? decoder.decode([[String]].self, from: savedData) {
            return loadedObjects
        }
    }
    return defaultCommunicationBoard
}

func saveCommunicationBoard(_ communicationBoard: [[String]]) {
    if let encoded = try? encoder.encode(communicationBoard) {
        defaults.set(encoded, forKey: "myCommunicationBoard")
    }
}


func newSheet(gridType: String, label: String = "label") {
    var currArray = loadSheetArray()
    currArray.append(SheetObject(gridType: gridType, removedIcons: [], label: label))
    saveSheetArray(sheetObjects: currArray)
}


func sortSheet(_ gridSlots: [GridSlot]) -> [GridSlot] {
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    let sortedDates = gridSlots.sorted { (date1, date2) -> Bool in
        let timeString1 = dateFormatter.string(from: date1.currTime)
        let timeString2 = dateFormatter.string(from: date2.currTime)
        
        return timeString1 < timeString2
    }
    return sortedDates
}


func getTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
}

func getBackupTime(_ date: Date) -> String {
    var returnedDate = ""
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    dateFormatter.locale = Locale(identifier: "en_US")
    returnedDate = dateFormatter.string(from: date)
    dateFormatter.dateFormat = "h:mm a"
    return "\(returnedDate), \(dateFormatter.string(from: date))"
}

func getAllRemoved() -> [IconObject] {
    var sheetArray = loadSheetArray()
    var removedIcons: [IconObject] = []
    var sheetRemovedIcons: [IconObject] = []
    let customPECSAddresses = getCustomPECSAddresses()
    
    for (sheetIndex, sheet) in sheetArray.enumerated() {
        for icon in sheet.removedIcons {
            if customPECSAddresses[icon.currIcon] != nil || UIImage(named: icon.currIcon) != nil { //hacky fix for now to sort out icons not removed by deleteicons or update icons or something
                removedIcons.append(icon)
                sheetRemovedIcons.append(icon)
            }
        }
        sheetArray[sheetIndex].removedIcons = sheetRemovedIcons
        sheetRemovedIcons = []
    }
    saveSheetArray(sheetObjects: sheetArray)
    return removedIcons
}

//temp migration that removes all Completed icons, just adds to removed icons
func migrateRemoved() -> SheetObject {
    var sheetArray = loadSheetArray()
    for (sheetIndex, sheet) in sheetArray.enumerated() {
        sheetArray[sheetIndex].removedIcons = sheet.removedIcons + (sheet.completedIcons ?? [])
        sheetArray[sheetIndex].completedIcons = nil
    }
    saveSheetArray(sheetObjects: sheetArray)
    return sheetArray[defaults.integer(forKey: "currSheetIndex")]
}
    
func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
        if granted {
            currSessionLog.append("Notification permission granted.")
            defaults.set(true, forKey : "notificationsAllowed")
        } else {
            currSessionLog.append("Notification permission denied.")
            defaults.set(false, forKey : "notificationsAllowed")
        }
    }
}

func manageNotifications() {
    currSessionLog.append("notifs on: \(defaults.bool(forKey: "notifsOn"))")
    if defaults.bool(forKey: "notifsOn") {
        let currSheetArray = loadSheetArray()
        for (index, sheet) in currSheetArray.enumerated() {
            if sheet.gridType == "time" {
                sheetNotifications(sheet: sheet, sheetIndex: index)
            }
        }
    } else {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}

func sheetNotifications(sheet: SheetObject, sheetIndex: Int) {
    //let presentationOptions: UNNotificationPresentationOptions = [.alert, .sound, .badge]
    
    notificationCenter.getPendingNotificationRequests { requests in
            let requestsToRemove = requests.filter { $0.identifier == sheet.label }
            
            let identifiersToRemove = requestsToRemove.map { $0.identifier }
            
            notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
            
            currSessionLog.append("Removed notifications with identifier: \(sheet.label)")
        }
    
    for object in sheet.currGrid {
        let content = UNMutableNotificationContent()
        content.title = sheet.label
        content.body = "It's time for your \(getTime(date: object.currTime)) timeslot!"
        content.userInfo = ["currSheetIndex": sheetIndex]
        
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        
        let components = calendar.dateComponents([.hour, .minute], from: object.currTime)

        let scheduledDate = calendar.date(bySettingHour: components.hour!, minute: components.minute!, second: 0, of: object.currTime)!

        let triggerDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: scheduledDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: true)


        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                currSessionLog.append("Error scheduling \(sheet.label) notification: \(error.localizedDescription)")
            } else {
                currSessionLog.append("\(sheet.label) notification scheduled successfully for \(getTime(date: object.currTime))")
            }
        }
    }
}

func autoRemoveSlots(_ currSheet: SheetObject) -> SheetObject {
    var newSheet = currSheet
    if defaults.bool(forKey: "emptyOn") {
        for (index, _) in newSheet.currGrid.enumerated() {
            newSheet.currGrid[index].currIcons.sort { (object1, object2) -> Bool in
                if object1.currIcon.isEmpty {
                    return false
                } else if object2.currIcon.isEmpty {
                    return true
                } else {
                    return false // or false based on your sorting criteria for other icons
                }
                //            }
            }
            newSheet.currGrid = newSheet.currGrid.filter { !$0.isEmpty() }
            if newSheet.currGrid.count < 1 {
                newSheet.currGrid.append(GridSlot())
            }
        }
    }
    return newSheet
}


func isBiometricAuthenticationAvailable() -> Bool {
    let context = LAContext()

    var error: NSError?

    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
        return true
    } else {
        if let error = error {
            // Handle the error if needed
            currSessionLog.append("Biometric authentication is not available. Error: \(error.localizedDescription)")
        }
        return false
    }
}

func isPasswordAuthenticationAvailable() -> Bool {
    let context = LAContext()

    var error: NSError?

    if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
        return true
    } else {
        if let error = error {
            // Handle the error if needed
            currSessionLog.append("Password authentication is not available. Error: \(error.localizedDescription)")
        }
        return false
    }
}

func updateCurrTimeToNow(_ customObjects: [GridSlot]) -> [GridSlot] {
    let now = Date()
    var newGrid = customObjects

    for index in customObjects.indices {
        let currTimeComponents = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: customObjects[index].currTime)
        let updatedCurrTime = calendar.date(bySettingHour: currTimeComponents.hour!, minute: currTimeComponents.minute!, second: currTimeComponents.second!, of: now)!

        newGrid[index].currTime = updatedCurrTime
    }
    return newGrid
}

func canUseBiometrics() -> Bool {
    let context = LAContext()

    var error: NSError?

    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
        // Biometrics are available on the device
        return true
    } else {
        // Biometrics are not available or are restricted on the device
        return false
    }
}

func canUsePassword() -> Bool {
    let context = LAContext()

    var error: NSError?

    if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
        // Device has a passcode set
        return true
    } else {
        // Device does not have a passcode set or is restricted
        return false
    }
}

func getCurrentTimeRoundedToHalfHour() -> Date {
    let testCalendar = Calendar.current
    
    let currentDate = Date()
    
    // Extract components from the current date
    let components = testCalendar.dateComponents([.hour, .minute], from: currentDate)
    
    // Check if components.hour and components.minute are not nil
    if let hour = components.hour, let minute = components.minute {
        // Calculate the rounded minute value to the nearest half-hour
        let roundedMinutes = (minute + 15) / 30 * 30 % 60
        
        // Create a new date with the rounded components
        if let roundedDate = testCalendar.date(bySettingHour: hour, minute: roundedMinutes, second: 0, of: currentDate) {
            return roundedDate
        } else {
            currSessionLog.append("Unable to create rounded date at \(getTime(date: Date()))")
        }
    } else {
        currSessionLog.append("Unable to extract date components at \(getTime(date: Date()))")
    }
    return Date()
}



func getDateTwoHoursPrior(from date: Date) -> Date {
    
    // Subtract two hours from the specified date
    if let newDate = calendar.date(byAdding: .hour, value: -2, to: date) {
        return newDate
    } else {
        // Return the original date in case of an error
        currSessionLog.append("Cannot get date two hours prior")
        return date
    }
}

//funcs for usage statistics below

func formatDateToString(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd"
    return dateFormatter.string(from: date)
}

func updateUsage(_ icon: String) -> Void {
    var currUsage = getUsage()
    if let index = currUsage.firstIndex(where: { $0.date == Date() }) {
        currUsage[index].data.append(icon)
    } else {
        currUsage.append(UsageData(data: [icon]))
    }
    saveUsage(currUsage)
    Task {
        await uploadUsage()
    }
}

// Function to save usage data to UserDefaults
func saveUsage(_ usageData: [UsageData]) {
    if let encodedData = try? encoder.encode(usageData) {
        defaults.set(encodedData, forKey: "usageData")
    }
}

// Function to retrieve usage data from UserDefaults
func getUsage() -> [UsageData] {
    if let data = defaults.data(forKey: "usageData"),
       var decodedData = try? decoder.decode([UsageData].self, from: data) {

        // Modify all dates in the array to be at 11:59:59 pm
        decodedData = decodedData.map { usageData in
            UsageData(date: Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: usageData.date) ?? usageData.date,
                      data: usageData.data)
        }
        
        return fillMissingDates(in: decodedData)
    }
    
    return []
}

func systemInfoString(isHTML: Bool, completion: @escaping (String) -> Void) {
    Task {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.compactMap { $0.value as? Int8 }.filter { $0 != 0 }.map { String(UnicodeScalar(UInt8($0))) }.joined()
        
        let systemName = await UIDevice.current.systemName
        let systemVersion = await UIDevice.current.systemVersion
        let userID = await getUserID()
        var deviceInfo = ""
        if isHTML {
            deviceInfo = """
            <b>System Information:</b> <br>
            \(identifier) <br>
            \(systemName) \(systemVersion) <br>
            Daysy \(appVersion) (\(bundleVersion)) <br>
            <i>\(userID)</i>
            """
            print("returning html info")
            completion("<u>Please leave your feedback here.</u> <br> <br> <br>" + deviceInfo)
        } else {
            deviceInfo = """
            System Information:
            \(identifier)
            \(systemName) \(systemVersion)
            Daysy \(appVersion) (\(bundleVersion))
            \(userID)
            """
            print("returning non-html info")
            completion("Please leave your feedback here. \n \n \n" + deviceInfo)
        }
    }
}

func getSettings() -> [String: Bool] {
    var settings: [String: Bool] = [:]
    settings["showCurrSlot"] = defaults.bool(forKey: "showCurrSlot")
    settings["emptyOn"] = defaults.bool(forKey: "emptyOn")
    settings["toggleOn"] = defaults.bool(forKey: "toggleOn")
    settings["statsOn"] = defaults.bool(forKey: "statsOn")
    settings["buttonsOn"] = defaults.bool(forKey: "buttonsOn")
    settings["notifsOn"] = defaults.bool(forKey: "notifsOn")
    settings["aiOn"] = defaults.bool(forKey: "aiOn")
    settings["speakOn"] = defaults.bool(forKey: "speakOn")
    settings["communicationDefaultMode"] = defaults.bool(forKey: "communicationDefaultMode")
    return settings
    
}

func playAudio(_ iconName: String) {
    print("playing audio for the icon \(iconName)")
    var audioPlayer: AVAudioPlayer?
    let customAudioAddresses = getCustomAudioAddresses()
    
    guard let localURL = URL(string: String("\(documentsURL)") + (customAudioAddresses[iconName] ?? "")) else {
        currSessionLog.append("Invalid local URL string.")
        return
    }
    print("found audio file at \(localURL)")

    do {
        audioPlayer = try AVAudioPlayer(contentsOf: localURL)
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
    } catch {
        currSessionLog.append("Error loading audio from local URL: \(error.localizedDescription)")
    }
}


//most used icons, ordered from most to least
func mostUsedIcons(_ usageDataArray: [UsageData] = getUsage()) -> [String] {
    var frequencyDictionary: [String: Int] = [:]

    for usageData in usageDataArray {
        for string in usageData.data {
            if String(string.prefix(7)) != "action:" {
                frequencyDictionary[string, default: 0] += 1
            }
        }
    }

    let sortedStrings = frequencyDictionary.keys.sorted {
        frequencyDictionary[$0]! > frequencyDictionary[$1]!
    }

    return sortedStrings
}

func howmany(in usageDataArray: [UsageData], for targetString: String) -> Int {
    return usageDataArray.reduce(0) { (result, usageData) in
        return result + usageData.data.filter { $0 == targetString }.count
    }
}

// Function to fill in missing dates in UsageData array
func fillMissingDates(in usageArray: [UsageData]) -> [UsageData] {
    let usageDataArray = usageArray.sorted { $0.date < $1.date }
    let lastDate = usageDataArray.map { $0.date }.max()
    guard (usageDataArray.first?.date) != nil else {
        return usageDataArray // No dates in the array
    }
    
    var dateIndex = 0
    var missingData: [UsageData] = []
    var currentDate = usageDataArray[0].date
    
    for _ in usageDataArray {
        if dateIndex != usageDataArray.count - 1 {
            if !Calendar.current.isDate(usageDataArray[dateIndex].date, inSameDayAs: currentDate) {
                if currentDate < lastDate ?? usageDataArray[usageDataArray.count - 1].date {
                    missingData.append(UsageData(date: currentDate))
                }
            }
            dateIndex += 1
            if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDay
            } else {
             currentDate = Date()
            }
        }
    }
    
    //combibne the missing data and rthe current data and then return
    return (usageDataArray + missingData).sorted { $0.date < $1.date } //return the filled array
    
    
    func isNextDay(date: Date, from currentDate: Date) -> Bool {
        guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) else {
            return false
        }
        
        return Calendar.current.isDate(date, inSameDayAs: nextDay)
    }
}

func hasCameraPermission() -> Bool {
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    
    switch status {
    case .authorized:
        return true
    case .notDetermined:
        var isAuthorized = false
        AVCaptureDevice.requestAccess(for: .video) { granted in
            isAuthorized = granted
        }
        return isAuthorized
    default:
        return false
    }
}

func detectLanguage(for text: String) -> String {
    let recognizer = NLLanguageRecognizer()
    recognizer.processString(text)
    if let languageCode = recognizer.dominantLanguage?.rawValue {
        return languageCode
    } else {
        // Default to English if language cannot be determined
        return "en"
    }
}

func updateSuggestedWords(currLabel: String) -> [String] {
    // Initialize a UITextChecker instance
    let textChecker = UITextChecker()
    let lastWord: String = currLabel.components(separatedBy: " ").last ?? ""
    
    // Get range of text checked by UITextChecker
    let textRange = NSRange(location: 0, length: lastWord.utf16.count)
    
    // Get completions for the current search text
    let completions = textChecker.completions(forPartialWordRange: textRange, in: lastWord, language: "en")
    
    // If completions are found, update the suggestedWords array
    if let completions = completions {
        return completions
    } else {
        return []
    }
}

func labelImage(input: UIImage) async -> String {
    if #available(iOS 17.0, *) {
        guard let img = input.resize(to: CGSize(width: 256, height: 256)),
              let buffer = img.toBuffer() else {
            return ""
        }
        
        do {
            let config = MLModelConfiguration()
            let model = try FastViT(configuration: config)
            
            let input = FastViTInput(image: buffer)
            let output = try await model.prediction(input: input)
            
            // Get the most probable label
            if output.classLabel.contains(",") {
                if let commaIndex = output.classLabel.firstIndex(of: ",") {
                    let firstWord = output.classLabel[..<commaIndex]
                    return(String(firstWord))
                }
            } else {
                return output.classLabel
            }
        } catch {
            print(error.localizedDescription)
        }
    } else {
        guard let img = input.resize(to: CGSize(width: 224, height: 224)),
              let buffer = img.toBuffer() else {
            return ""
        }
        
        do {
            let config = MLModelConfiguration()
            let model = try MobileNetV2(configuration: config)
            let output = try? model.prediction(image: buffer)
            if let output=output {
                return String(output.classLabel)
            }
        } catch {
            currSessionLog.append(error.localizedDescription)
        }
    }
    return ""
}

func searchSymbols(_ searchText: String, update: @escaping ([String]) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
        let matchingItems = symbols.filter { $0.localizedCaseInsensitiveContains(searchText) }
        let sortedItems = matchingItems.sorted { (item1, item2) -> Bool in
            let startsWithSearchText1 = item1.lowercased().hasPrefix(searchText.lowercased())
            let startsWithSearchText2 = item2.lowercased().hasPrefix(searchText.lowercased())
            
            // Prioritize items that start with searchText
            if startsWithSearchText1 && !startsWithSearchText2 {
                return true
            } else if !startsWithSearchText1 && startsWithSearchText2 {
                return false
            } else {
                // For items starting with searchText or having searchText as prefix, sort them alphabetically
                return item1.localizedCaseInsensitiveCompare(item2) == .orderedAscending
            }
        }
        
        var filteredItems = sortedItems + matchingItems
        filteredItems = filteredItems.filter { UIImage(systemName: $0) != nil }
        
        for item in filteredItems {
            DispatchQueue.main.async {
                update([item])
            }
        }
    }
}

//just to simplify ML assisted searches, unfinished rn
func searchIcons(_ searchText: String) -> [String] {
    var totalArray: [String] = []
    
    //literal search
    let matchingKeys = getCustomPECSAddresses().keys.filter { $0.localizedCaseInsensitiveContains(searchText) }
    let matchingItems = allPECS.filter { $0.localizedCaseInsensitiveContains(searchText) }
    
    let sortedKeys = matchingKeys.sorted { (key1, key2) -> Bool in
        let startsWithSearchText1 = key1.lowercased().hasPrefix(searchText.lowercased())
        let startsWithSearchText2 = key2.lowercased().hasPrefix(searchText.lowercased())
        
        // Prioritize keys that start with searchText
        if startsWithSearchText1 && !startsWithSearchText2 {
            return true
        } else if !startsWithSearchText1 && startsWithSearchText2 {
            return false
        } else {
            // For keys starting with searchText or having searchText as prefix, sort them alphabetically
            return key1.localizedCaseInsensitiveCompare(key2) == .orderedAscending
        }
    }
    totalArray = totalArray + sortedKeys
    
    let sortedItems = matchingItems.sorted { (item1, item2) -> Bool in
        let startsWithSearchText1 = item1.lowercased().hasPrefix(searchText.lowercased())
        let startsWithSearchText2 = item2.lowercased().hasPrefix(searchText.lowercased())
        
        // Prioritize items that start with searchText
        if startsWithSearchText1 && !startsWithSearchText2 {
            return true
        } else if !startsWithSearchText1 && startsWithSearchText2 {
            return false
        } else {
            // For items starting with searchText or having searchText as prefix, sort them alphabetically
            return item1.localizedCaseInsensitiveCompare(item2) == .orderedAscending
        }
    }
    
    totalArray = totalArray + sortedItems
    
    //category search
    for category in pecsCategories {
        if category[0].range(of: searchText, options: .caseInsensitive) != nil {
            for index in 1..<(category.count) {
                if !totalArray.contains(category[index]) {
                    totalArray.append(category[index])
                }
            }
        }
    }
    
    //semantically related words, currently getting odd results
//    for icon in allPECS {
//        if icon != "All Icons" {
//            if areWordsRelated(word1: icon, word2: searchText) {
//                totalArray.append(icon)
//            }
//        }
//    }
    
    //search based on image classification
//    for image in allPECS {
//        if !totalArray.contains(image) {
//            if let img = UIImage(named: image) {
//                if let prediction = predictImage(input: img) {
//                    if prediction.classLabel.contains(searchText) {
//                        totalArray.append(image)
//                    }
//                }
//            }
//        }
//    }
    
    return totalArray
}

func autoCorrectComplete(text: String) -> String {
    if updateSuggestedWords(currLabel: text).isEmpty {
        
        let textChecker = UITextChecker()
        let nsString = text as NSString
        let language = detectLanguage(for: text)
        var correctedText = text
        
        let range = NSRange(location: 0, length: nsString.length)
        let misspelledRange = textChecker.rangeOfMisspelledWord(in: nsString as String, range: range, startingAt: 0, wrap: false, language: language)
        
        if misspelledRange.location != NSNotFound, let guesses = textChecker.guesses(forWordRange: misspelledRange, in: nsString as String, language: language), let firstGuess = guesses.first {
            correctedText = nsString.replacingCharacters(in: misspelledRange, with: firstGuess)
        }
        return updateSuggestedWords(currLabel: correctedText).isEmpty ? correctedText : updateSuggestedWords(currLabel: correctedText).first!
    } else {
        return updateSuggestedWords(currLabel: text).first!
    }
}

func formIntelligentSentence(from words: [String]) -> String {
//    if defaults.bool(forKey: "aiOn") && isConnectedToInternet() {
        //gpt request to make the sentence
//        return ""
//    } else {
        return words.joined(separator: ", ")
//    }
}

//temporary to remove any hardcoded plus.viewfinder saved as pllaceholders, shouldve done this a long time ago
func removePlusViewfinders() -> SheetObject {
    var currSheetArray = loadSheetArray()
    for (sheetIndex, sheet) in currSheetArray.enumerated() {
        for (gridIndex, grid) in sheet.currGrid.enumerated() {
            for (iconIndex, icon) in grid.currIcons.enumerated() {
                if icon.currIcon == "plus.viewfinder" {
                    currSheetArray[sheetIndex].currGrid[gridIndex].currIcons[iconIndex].currIcon = ""
                }
            }
        }
    }
    saveSheetArray(sheetObjects: currSheetArray)
    return currSheetArray[defaults.integer(forKey: "currSheetIndex")]
}

func withTimeout<T>(_ seconds: Double, operation: @escaping () async throws -> T) async throws -> T {
    // Create a task for the operation
    let task = Task { try await operation() }
    
    // Create a task for the timeout
    let timeoutTask = Task {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
    
    do {
        // Wait for either the operation or the timeout
        let result = try await task.value
        timeoutTask.cancel() // Cancel the timeout task if operation completes
        return result
    } catch {
        task.cancel() // Cancel the operation task if timeout occurs
        throw error
    }
}

func getSuggestedLanguages(_ language: String =  "") -> [[String]] {
    var deviceLanguage = Locale.current.languageCode ?? "en-GB"
    if defaults.object(forKey: "currVoice") != nil && language.isEmpty { //if they have a voice set and no new language is sepcified
        var currVoice = defaults.string(forKey: "currVoice")!
        var count = 0
        for item in voices {
            if item[2] == currVoice {
                currVoice = item[0]
                count += 1
            }
        }
        if count == 0 {
            currVoice = "en-GB"
        }
        if getFirstTwoLetters(of: deviceLanguage) != getFirstTwoLetters(of: currVoice) { //if their voice is not device default
            deviceLanguage = defaults.string(forKey: "currVoice")! //use their language instead of the device default
        }
    }
    var matchingLanguages: [[String]] = []
    for voice in voices {
        if getFirstTwoLetters(of: voice[0]) == getFirstTwoLetters(of: deviceLanguage) {
            matchingLanguages.append(voice)
        }
    }
    return matchingLanguages
    
    func getFirstTwoLetters(of string: String) -> String {
        guard string.count >= 2 else {
            return string
        }
        let startIndex = string.startIndex
        let endIndex = string.index(startIndex, offsetBy: 2)
        return String(string[startIndex..<endIndex])
    }
}

func getOtherLanguages(_ language: String = "") -> [[String]] {
    var matchingLanguages: [[String]] = []
    let suggestedLanguages = getSuggestedLanguages(language)
    for item in voices {
        if !suggestedLanguages.contains(item) {
            matchingLanguages.append(item)
        }
    }
    return matchingLanguages
}


func getCommBoardIndices() -> [String] {
    let currCommunicationBoard = loadCommunicationBoard()
    var commBoardIndices: [String] = []
    
    for (itemIndex, _) in currCommunicationBoard.enumerated() {
        commBoardIndices.append(String("\(itemIndex)"))
    }
    return commBoardIndices
}

func getCustomIconPreviews() async -> [String: UIImage] {
    let customPECSAddresses = getCustomPECSAddresses()
    var customIconPreviews: [String: UIImage] = [:]
    let queue = DispatchQueue(label: "com.customIconPreviews.queue")
    
    await withTaskGroup(of: (String, UIImage).self) { group in
        for (key, _) in customPECSAddresses {
            group.addTask {
                let image = await getCustomIcon(key).asImage()
                return (key, image)
            }
        }
        
        for await (key, image) in group {
            queue.sync {
                customIconPreviews[key] = image
            }
        }
    }
    return customIconPreviews
}


func getCustomPECSAddresses() -> [String: String] {
    
    if defaults.bool(forKey: "newIcons") {
        if let storedData = defaults.data(forKey: "newCustomIconAddresses"),
           let customPECSAddresses = try? decoder.decode([String: String].self, from: storedData) {
            return customPECSAddresses
        } else {
            return [:] // Return an empty dictionary if not found or decoding fails
        }
    } else {
        
        if let storedData = defaults.data(forKey: "customPECSAddresses"),
           let customPECSAddresses = try? decoder.decode([String: String].self, from: storedData) {
            return customPECSAddresses
        } else {
            return [:] // Return an empty dictionary if not found or decoding fails
        }
    }
}

func saveCustomPECSAddresses(_ addresses: [String: String]) {
    
    if defaults.bool(forKey: "newIcons") {
        do {
            let data = try encoder.encode(addresses)
            defaults.set(data, forKey: "newCustomIconAddresses")
        } catch {
            currSessionLog.append("Error encoding custom PECS addresses: \(error.localizedDescription)")
        }
    } else {
        do {
            let data = try encoder.encode(addresses)
            defaults.set(data, forKey: "customPECSAddresses")
        } catch {
            currSessionLog.append("Error encoding custom PECS addresses: \(error.localizedDescription)")
        }
    }
}

func getCustomAudioAddresses() -> [String: String] {
    if let storedData = defaults.data(forKey: "customAudioAddresses"),
       let customPECSAddresses = try? decoder.decode([String: String].self, from: storedData) {
        return customPECSAddresses
    } else {
        return [:] // Return an empty dictionary if not found or decoding fails
    }
}


func saveCustomAudioAddresses(_ addresses: [String: String]) {
    do {
        let data = try encoder.encode(addresses)
        defaults.set(data, forKey: "customAudioAddresses")
    } catch {
        currSessionLog.append("Error encoding custom PECS addresses: \(error.localizedDescription)")
    }
}

func getCustomIcon(_ keyString: String, large: Bool = false) -> some View {
    let customIconName = extractKey(from: keyString)
    let customIconObjects = getCustomPECSAddresses()
    let customImage = loadImageFromLocalURL(customIconObjects[removeCustomIconObjectPrefix(keyString)] ?? "")?.asImage ?? Image(systemName: "exclamationmark.triangle.fill")
    let noImage = loadImageFromLocalURL(customIconObjects[removeCustomIconObjectPrefix(keyString)] ?? "") == nil
    
//    if large {
//        return CustomIconViewLarge(selectedCustomImage: customImage, currCustomIconText: customIconName, noImage: noImage)
//    }
    return CustomIconView(selectedCustomImage: customImage, currCustomIconText: customIconName, noImage: noImage)
}

func extractKey(from inputString: String) -> String {
    var result = removeCustomIconObjectPrefix(inputString)
    
    guard let range = inputString.range(of: "#id") else {
        return result
    }
    
    result = String(inputString[range.upperBound...])
    
    return result
}

func removeCustomIconObjectPrefix(_ inputString: String) -> String {
    return inputString.replacingOccurrences(of: "customIconObject:", with: "")
}


func clearDocumentsDirectory() {
    do {
        let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [])

        for fileURL in fileURLs {
            try fileManager.removeItem(at: fileURL)
        }

        currSessionLog.append("Documents directory cleared successfully.")
    } catch {
        currSessionLog.append("Error clearing documents directory: \(error.localizedDescription)")
    }
}

func saveImageToDocumentsDirectory(_ uiImage: UIImage, fileName: String = generateUniqueName() + ".jpg") -> String {
    if uiImage != UIImage(systemName: "plus.viewfinder") {
        // Create a unique name for the image file
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        // Convert the UIImage to Data
        guard let imageData = uiImage.jpegData(compressionQuality: 1.0) else {
            currSessionLog.append("Failed to convert UIImage to Data.")
            return ""
        }
        
        do {
            // Write the data to the file
            try imageData.write(to: fileURL)
            currSessionLog.append("Image saved to documents directory: \(fileURL.absoluteString)")
            return fileName
        } catch {
            currSessionLog.append("Error writing image to documents directory: \(error.localizedDescription)")
        }
    }
    return ""
}

func loadImageFromLocalURL(_ localImageName: String) -> UIImage? {
    
    guard let localURL = URL(string: String("\(documentsURL)") + localImageName) else {
        currSessionLog.append("Invalid local URL string.")
        return nil
    }

    do {
        let imageData = try Data(contentsOf: localURL)
        if UIImage(data: imageData) != UIImage(systemName: "plus.viewfinder") {
            return UIImage(data: imageData)
        } else {
            return nil
        }
    } catch {
        currSessionLog.append("Error loading image from local URL: \(error.localizedDescription)")
        return nil
    }
}

func downloadImage(from url: URL) async -> UIImage? {
    do {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            currSessionLog.append("Failed to download image: Invalid response")
            return nil
        }
        return UIImage(data: data)
    } catch {
        currSessionLog.append("Failed to download image: \(error.localizedDescription)")
        return nil
    }
}

// Function to generate a unique name based on time interval since 1970
func generateUniqueName() -> String {
    return "\(Int(Date().timeIntervalSince1970))"
}

func countItemsInDocuments() -> Int {
    do {
        // Get contents of the folder
        let contents = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)

        // Return the count of items in the folder
        return contents.count
    } catch {
        // Handle any errors
        currSessionLog.append("Error counting items in folder: \(error)")
        return 0
    }
}

func deleteFile(at url: String) {
    let deleteURL = URL(string: String("\(documentsURL)") + url)

    do {
        try fileManager.removeItem(at: deleteURL!)
    } catch {}
}

func removePrefixesFix() -> [SheetObject] {
    var currSheetArray = loadSheetArray()
    var currUsage = getUsage()
    
    for (sheetIndex, sheet) in currSheetArray.enumerated() {
        for (gridIndex, grid) in sheet.currGrid.enumerated() {
            for (iconIndex, icon) in grid.currIcons.enumerated() {
                currSheetArray[sheetIndex].currGrid[gridIndex].currIcons[iconIndex].currIcon = currSheetArray[sheetIndex].currGrid[gridIndex].currIcons[iconIndex].currIcon.replacingOccurrences(of: "customIconObject:", with: "")
                
                for (detailIndex, _) in (icon.currDetails ?? []).enumerated() {
                    currSheetArray[sheetIndex].currGrid[gridIndex].currIcons[iconIndex].currDetails![detailIndex] = currSheetArray[sheetIndex].currGrid[gridIndex].currIcons[iconIndex].currDetails![detailIndex].replacingOccurrences(of: "customIconObject:", with: "")
                    
                }
            }
        }
        
        for (removedIconIndex, _) in sheet.removedIcons.enumerated() {
            currSheetArray[sheetIndex].removedIcons[removedIconIndex].currIcon = currSheetArray[sheetIndex].removedIcons[removedIconIndex].currIcon.replacingOccurrences(of: "customIconObject:", with: "")
        }
        
        currSheetArray[sheetIndex].currLabelIcon = currSheetArray[sheetIndex].currLabelIcon?.replacingOccurrences(of: "customIconObject:", with: "")
    }
    for (dataIndex, data) in currUsage.enumerated() {
        for (itemIndex, _)  in data.data.enumerated() {
            currUsage[dataIndex].data[itemIndex] = currUsage[dataIndex].data[itemIndex].replacingOccurrences(of: "customIconObject:", with: "")
        }
    }
    saveUsage(currUsage)
    
    saveSheetArray(sheetObjects: currSheetArray)
    return currSheetArray
}

func updateCustomIcons(oldKey: String, newKey: String) -> [SheetObject] {
    let altOldKey = "customIconObject:\(oldKey)"
    var currSheetArray = loadSheetArray()
    var tappedIcons = loadTappedIcons()
    var currCommunicationBoard = loadCommunicationBoard()
    var currUsage = getUsage()
    
    for (iconIndex, icon) in currCommunicationBoard.enumerated() {
        if icon.count == 1 {
            if icon[0] == oldKey {
                currCommunicationBoard[iconIndex][0] = newKey
            }
        } else {
            for (itemIndex, item) in currCommunicationBoard[iconIndex].enumerated() {
                if item == oldKey {
                    currCommunicationBoard[iconIndex][itemIndex] = newKey
                }
            }
        }
    }
    saveCommunicationBoard(currCommunicationBoard)
    
    for (iconIndex, icon) in tappedIcons.enumerated() {
        if icon == oldKey {
            tappedIcons[iconIndex] = newKey
        }
    }
    saveTappedIcons(tappedIcons)
    
    for (sheetIndex, sheet) in currSheetArray.enumerated() {
        for (gridIndex, grid) in sheet.currGrid.enumerated() {
            for (iconIndex, icon) in grid.currIcons.enumerated() {
                if icon.currIcon == oldKey || icon.currIcon == altOldKey {
                    currSheetArray[sheetIndex].currGrid[gridIndex].currIcons[iconIndex].currIcon = newKey
                }
                for (detailIndex, detail) in (icon.currDetails ?? []).enumerated() {
                    if detail == oldKey || detail == altOldKey {
                        currSheetArray[sheetIndex].currGrid[gridIndex].currIcons[iconIndex].currDetails![detailIndex] = newKey
                    }
                }
            }
        }

        for (removedIconIndex, removedIcon) in sheet.removedIcons.enumerated() {
            if removedIcon.currIcon == oldKey  || removedIcon.currIcon == altOldKey {
                currSheetArray[sheetIndex].removedIcons[removedIconIndex].currIcon = newKey
            }
        }
        
        if (sheet.currLabelIcon ?? "") == oldKey || (sheet.currLabelIcon ?? "")  == altOldKey {
            currSheetArray[sheetIndex].currLabelIcon = newKey
        }
        
    }
    
    for (dataIndex, data) in currUsage.enumerated() {
        for (itemIndex, item)  in data.data.enumerated() {
            if item == oldKey  || item  == altOldKey {
                currUsage[dataIndex].data[itemIndex] = newKey
            }
        }
    }
    saveUsage(currUsage)
    
    saveSheetArray(sheetObjects: currSheetArray)
    return currSheetArray
}

func deleteCustomIcons(currIcon: String) -> [SheetObject] {
    var currSheetArray = loadSheetArray()
    var tappedIcons = loadTappedIcons()
    var customPECSAddreses = getCustomPECSAddresses()
    var currCommunicationBoard = loadCommunicationBoard()
    var currUsage = getUsage()
    
    for (iconIndex, icon) in currCommunicationBoard.enumerated() {
        if icon.count == 1 {
            if icon[0] == currIcon {
                currCommunicationBoard.remove(at: iconIndex)
            }
        } else {
            for (itemIndex, item) in currCommunicationBoard[iconIndex].enumerated() {
                if item == currIcon {
                    currCommunicationBoard[iconIndex].remove(at: itemIndex)
                }
            }
        }
    }
    saveCommunicationBoard(currCommunicationBoard)
    
    for (iconIndex, icon) in tappedIcons.enumerated() {
        if icon == currIcon {
            tappedIcons.remove(at: iconIndex)
        }
    }
    saveTappedIcons(tappedIcons)
    
    for (sheetIndex, sheet) in currSheetArray.enumerated() {
        for (gridIndex, grid) in sheet.currGrid.enumerated() {
            for (iconIndex, icon) in grid.currIcons.enumerated() {
                if icon.currIcon == currIcon {
                    currSheetArray[sheetIndex].currGrid[gridIndex].currIcons[iconIndex].currIcon = ""
                }
            }
        }

//        for (removedIconIndex, removedIcon) in sheet.removedIcons.enumerated() {
//            if removedIcon.currIcon == currIcon {
//                currSheetArray[sheetIndex].removedIcons.remove(at: removedIconIndex)
//            }
//        } TODO: fix this, doesnt always work right now for custom icons. Not sure why
        
        if (sheet.currLabelIcon ?? "") == currIcon {
            currSheetArray[sheetIndex].currLabelIcon = nil
        }
    }
    saveSheetArray(sheetObjects: currSheetArray)
    
    for icon in customPECSAddreses {
        if icon.key == currIcon {
            customPECSAddreses.removeValue(forKey: icon.key)
        }
    }
    saveCustomPECSAddresses(customPECSAddreses)
    
    for (dataIndex, data) in currUsage.enumerated() {
        for (itemIndex, item)  in data.data.enumerated() {
            if item == currIcon {
                currUsage[dataIndex].data.remove(at: itemIndex)
            }
            //check to see if item is or has one of the old custom icons, and remove if so
        }
    }
    saveUsage(currUsage)
    
    
    
    
    return currSheetArray
}
    

func customPECSToBoard() -> [[String]] {
    let customPECS = getCustomPECSAddresses().keys
    var sampleArray: [String] = []
    var endArray: [[String]] = []
    
    for icon in customPECS {
        sampleArray.append(icon)
        endArray.append(sampleArray)
        sampleArray.removeAll()
    }
    
    return endArray
}

func authenticateWithBiometrics() async -> Bool {
    let context = LAContext()
    var error: NSError?

    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
        return await withCheckedContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "You can disable Lock Buttons in Daysy Settings") { success, evaluateError in
                if success {
                    continuation.resume(returning: true)
                } else if let evaluateError = evaluateError as? LAError, evaluateError.code == .userFallback {
                    // Fallback to passcode authentication
                    Task {
                        let passcodeSuccess = await authenticateWithPasscode()
                        continuation.resume(returning: passcodeSuccess)
                    }
                } else {
                    continuation.resume(returning: false)
                }
            }
        }
    } else {
        // Biometric authentication not available, handle the error accordingly
        currSessionLog.append("biometrics not available")
        return await authenticateWithPasscode()
    }
}

private func authenticateWithPasscode() async -> Bool {
    let context = LAContext()
    var error: NSError?

    if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
        return await withCheckedContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "You can disable Lock Buttons in Daysy Settings") { success, evaluateError in
                if success {
                    continuation.resume(returning: true)
                } else {
                    continuation.resume(returning: false)
                }
            }
        }
    } else {
        // Device authentication not available, handle the error accordingly
        currSessionLog.append("device password not available")
        return false
    }
}

func tintedImage(image: UIImage, tintColor: UIColor) -> UIImage? {
    // Determine the longer side to make the image square
    let longerSide = max(image.size.width, image.size.height)
    let size = CGSize(width: longerSide, height: longerSide)
    
    // Calculate padding for centering the image
    let horizontalPadding = (longerSide - image.size.width) / 2
    let verticalPadding = (longerSide - image.size.height) / 2
    
    UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
    guard let context = UIGraphicsGetCurrentContext() else { return nil }
    context.translateBy(x: 0, y: size.height)
    context.scaleBy(x: 1.0, y: -1.0)
    context.setBlendMode(.normal)
    
    let rect = CGRect(x: horizontalPadding, y: verticalPadding, width: image.size.width, height: image.size.height)
    context.clip(to: rect, mask: image.cgImage!)
    tintColor.setFill()
    context.fill(rect)
    
    let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return tintedImage
}

func isConnectedToInternet() -> Bool {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "InternetConnectionMonitor")
    var isConnected = false
    
    let semaphore = DispatchSemaphore(value: 0)
    
    monitor.pathUpdateHandler = { path in
        if path.status == .satisfied {
            isConnected = true
        } else {
            isConnected = false
        }
        semaphore.signal()
        monitor.cancel()
    }
    
    monitor.start(queue: queue)
    
    _ = semaphore.wait(timeout: .now() + 5.0)
    
    return isConnected
}
func hapticFeedback(type: Int = 2, impactStyle: UIImpactFeedbackGenerator.FeedbackStyle = .medium, notificationStyle: UINotificationFeedbackGenerator.FeedbackType = .success) -> Void {
    
    if type == 0 {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: impactStyle)
        impactFeedbackGenerator.impactOccurred()
    } else if type == 1 {
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.notificationOccurred(notificationStyle)
    } else if type == 2 {
        let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
        selectionFeedbackGenerator.selectionChanged()
    }
}

func fetchCustomImage(queryText: String, completion: @escaping (UIImage?) -> Void) {
    let query = ImagesQuery(prompt: queryText, n: 1, size: ImagesQuery.Size._1024)
    
    Task {
        do {
            await imageStore.images(query: query)
            let fetchedImages = imageStore.images
            
            // Check if there are images in the store
            guard fetchedImages.count > 0,
                  let urlString = fetchedImages[0].url,
                  !urlString.isEmpty,
                  let url = URL(string: urlString) else {
                completion(nil)
                return
            }
            
            let image = await downloadImage(from: url)
            completion(image)
        }
    }
}

func openAiSpeak(from input: String) async {
    speechStore.audioObjects.removeAll()
    let speed = Double(defaults.float(forKey: "currVoiceRatio") == 0.0 ? 1.0 : defaults.float(forKey: "currVoiceRatio"))
    
    let voice = AudioSpeechQuery.AudioSpeechVoice(rawValue: defaults.string(forKey: "currAiVoice") ?? "")
    
    let query = AudioSpeechQuery(
        model: .tts_1,
        input: input,
        voice: voice ?? .nova,
        responseFormat: .mp3,
        speed: speed
    )
    
    do {
        await speechStore.createSpeech(query)
    }
}


func emptyIconFix() -> Void {
    var customPECSAddresses = getCustomPECSAddresses()
    var newIconText = ""
    
    
    for (key, value) in customPECSAddresses {
        newIconText = removeCustomIconObjectPrefix(key)
        if (key.isEmpty || key == "") && customPECSAddresses["0#id\(key)"] == nil {
            newIconText = "0#id\(key)"
        } else if (key.isEmpty || key == "") && customPECSAddresses[key] != nil {
            newIconText = extractKey(from: key)
            var i = 1
            while customPECSAddresses[String("\(i)#id\(newIconText)")] != nil {
                i += 1
            }
            newIconText = String("\(i)#id\(newIconText)")
        }
        if key != newIconText {
            customPECSAddresses[newIconText] = value
            customPECSAddresses[key] = nil
            saveSheetArray(sheetObjects: updateCustomIcons(oldKey: key, newKey: newIconText))
        }
        if loadImageFromLocalURL(customPECSAddresses[newIconText] ?? "") == UIImage(named: "plus.viewfinder") {
            customPECSAddresses[key] = ""
        }
    }
    customPECSAddresses[""] = nil
    saveCustomPECSAddresses(customPECSAddresses)
    saveCommunicationBoard(
        customPECSToBoard() + [["Activities", "acousticguitar", "airplane", "ball", "bath", "bathtime", "blowing", "bus", "children", "clap", "climbing", "climbtree", "dancing", "drawing", "drum", "drumandcymbal", "drumsticks", "firetruck", "friends", "geography", "gettingdressed", "gift", "gifts", "halloween", "hide", "highfive", "horse", "jumpontrampoline", "listening", "look", "monkeybars", "motorcycle", "notebook", "playatbeach", "playcymbal", "playdrum", "playground", "playguitar", "playing", "playkeyboard", "playrecorder", "playvideogame", "puzzle", "quietmouth", "rideincar", "rideon", "sandbox", "singing", "sit", "sitcrisscross", "sitdown", "slide", "swing", "teacher", "television", "throwing", "tiesshoes", "time-out-corner", "time-out-floor", "timeout", "train", "trampoline", "walk", "watchingtv", "watchtv", "wave", "winner", "yawn"],
                               ["School", "backpack", "books", "bus", "calendar", "classroom", "drawing", "geography", "history", "listen", "listening", "math", "notebook", "pencil", "quietmouth", "school", "science", "scissors", "sitcrisscross", "students", "teacher"],
                               ["Emotions", "angry", "calmdown", "excited", "happy", "hide", "mad", "scared", "stubborn", "surprised", "wave", "wink", "yawn", "yeah", "yikes", "yucky"],
                               ["Body Parts", "back", "backache", "blownose", "bra", "brushhair", "brushteeth", "chew", "climbing", "climbtree", "clipnails", "cold", "crying", "elbow", "eyes", "feet", "foot", "haircut", "hairpulling", "hand", "hands", "headache", "heart", "knee", "listen", "owie", "pullinghair", "sick", "smell", "sneeze", "teeth", "thinking", "wipeface", "wipenose", "yawn"],
                               ["Clothing", "backpack", "baseballcap", "belt", "boots", "bra", "pants", "panties", "shirton", "shoeson", "shorts", "socks", "underwear"],
                               ["Food and Drink", "allgone", "apple", "applejuice", "bacon", "bagel", "banana", "bananas", "birthdaycake", "blackberry", "cheeseburger", "cheeseslice", "cheesewedge", "chew", "chickennuggets", "chips", "corndog", "cupcake", "doughnut", "friedegg", "grapes", "grilledcheese", "icecreamcone", "icecreamsundae", "lemon", "lollipop", "loafofbread", "muffin", "orange", "orangejuice", "pan", "pancakes", "pastasauce", "peanutbutter", "peanutbutterbread", "pear", "pie", "pineapple", "pizza", "pizzaslice", "popcorn", "pretzel", "raisins", "rasberry", "sandwhich", "soda", "sodacan", "spoon", "strawberry", "sugar", "waffles", "water", "watermelon"],
                               ["Seasons and Time", "january", "february", "march", "april", "june", "july", "august", "september", "october", "november", "december", "morning", "afternoon", "evening", "winter", "spring", "summer", "fall", "1oclock", "2oclock", "3oclock", "4oclock", "5oclock", "6oclock", "7oclock", "8oclock", "9oclock", "10oclock", "11oclock", "12oclock"],
                               ["Vehicles", "airplane", "ambulance", "bike", "bus", "sportscar", "firetruck", "limo", "minivan", "motorcycle", "pickuptruck", "policecar", "semitruck", "tank", "train", "van"],
                               ["Nature", "apple", "applejuice", "axe", "banana", "cat", "christmas", "christmastree", "cow", "dog", "duck", "fall", "fish", "goat", "grapes", "halloween", "lemon", "morning", "orange", "pear", "pineapple", "pumpkin", "rasberry", "spring", "strawberry", "summer", "swan", "turtle", "watermelon", "winter", "woodclamp"],
                               
                               ["1oclock"], ["2oclock"], ["3oclock"], ["4oclock"], ["5oclock"], ["6oclock"], ["7oclock"], ["8oclock"], ["9oclock"], ["10oclock"], ["11oclock"], ["12oclock"], ["a"], ["lowercase-a"], ["acousticguitar"], ["afternoon"], ["airplane"], ["allgone"], ["ambulance"], ["angry"], ["apple"], ["applejuice"], ["april"], ["august"], ["axe"], ["b"], ["lowercase-b"], ["back"], ["backache"], ["backpack"], ["bacon"], ["badsmell"], ["bagel"], ["ball"], ["banana"], ["bananas"], ["baseballcap"], ["bat"], ["bath"], ["bathtime"], ["belt"], ["bible"], ["bike"], ["birthdaycake"], ["biting"], ["blackberry"], ["blowing"], ["blownose"], ["books"], ["boots"], ["bottledwater"], ["bowl"], ["bra"], ["brownie"], ["brushhair"], ["brushteeth"], ["bubbles"], ["bus"], ["butterknife"], ["c"], ["lowercase-c"], ["calendar"], ["calmdown"], ["cat"], ["chair"], ["cheeseburger"], ["cheeseslice"], ["cheesewedge"], ["chest"], ["chew"], ["chickennuggets"], ["children"], ["chips"], ["choppingknife"], ["christmas"], ["christmastree"], ["church"], ["circle"], ["clap"], ["classroom"], ["cleanears"], ["cleanup"], ["clearears"], ["cleats"], ["climbing"], ["climbtree"], ["clipnails"], ["clotheshanger"], ["cold"], ["comb"], ["congratulations"], ["cooking"], ["corndog"], ["cottonswab"], ["couch"], ["cow"], ["cracker"], ["crying"], ["cupcake"], ["cymbal"], ["d"], ["lowercase-d"], ["dancing"], ["day"], ["december"], ["dentist"], ["dentistoffice"], ["deodorant"], ["dime"], ["doctor"], ["dog"], ["donttouch"], ["doughnut"], ["drawing"], ["drill"], ["drinking"], ["drinkingglass"], ["drive"], ["drum"], ["drumandcymbal"], ["drumsticks"], ["dryface"], ["duck"], ["e"], ["lowercase-e"], ["easter"], ["eat"], ["eatlunch"], ["elbow"], ["evening"], ["excited"], ["eye"], ["eyes"], ["f"], ["lowercase-f"], ["fall"], ["february"], ["feet"], ["firetruck"], ["fish"], ["fistbump"], ["foot"], ["fork"], ["frenchfries"], ["friedegg"], ["friends"], ["g"], ["lowercase-g"], ["geography"], ["gettingdressed"], ["gift"], ["gifts"], ["giraffe"], ["glue"], ["goat"], ["godownstairs"], ["goodbye"], ["goodjob"], ["goupstairs"], ["grapes"], ["grilledcheese"], ["h"], ["lowercase-h"], ["haircut"], ["hairdryer"], ["hairpulling"], ["halloween"], ["ham"], ["hammer"], ["hand"], ["hands"], ["happy"], ["hardboiledegg"], ["headache"], ["heart"], ["hello"], ["hide"], ["highfive"], ["history"], ["hitting"], ["horse"], ["hotdog"], ["hotdrink"], ["hotstove"], ["householdcleaner"], ["hug"], ["i"], ["lowercase-i"], ["icecreamcone"], ["icecreamsundae"], ["idea"], ["idontknow"], ["iwant"], ["j"], ["lowercase-j"], ["january"], ["july"], ["jumping"], ["jumpontrampoline"], ["june"], ["k"], ["lowercase-k"], ["ketchup"], ["keyboard"], ["kicking"], ["knee"], ["l"], ["lowercase-l"], ["lemon"], ["lightbulb"], ["limo"], ["listen"], ["listening"], ["loafofbread"], ["lollipop"], ["look"], ["lunch"], ["m"], ["lowercase-m"], ["mad"], ["man"], ["march"], ["math"], ["may"], ["men"], ["microphone"], ["milk"], ["minivan"], ["monkeybars"], ["morning"], ["motorcycle"], ["muffin"], ["mustard"], ["n"], ["lowercase-n"], ["nailclippers"], ["nickel"], ["nobiting"], ["nobitingnails"], ["noclimbing"], ["nohairpulling"], ["nohitting"], ["nojumping"], ["nokicking"], ["noon"], ["nopickingnose"], ["nopointing"], ["nopullinghair"], ["nopunching"], ["noscratching"], ["nosuckingthumb"], ["notebook"], ["nothrowing"], ["november"], ["nurse"], ["o"], ["lowercase-o"], ["october"], ["ok"], ["orange"], ["orangejuice"], ["oval"], ["owie"], ["p"], ["lowercase-p"], ["pan"], ["pancakes"], ["panties"], ["pants"], ["pantson"], ["paper"], ["papertowel"], ["park"], ["parrot"], ["pastasauce"], ["peace"], ["peanutbutter"], ["peanutbutterbread"], ["pear"], ["pen"], ["pencil"], ["penguin"], ["penny"], ["people"], ["petdog"], ["pick"], ["pickaxe"], ["pickingnose"], ["pickuptruck"], ["pie"], ["pig"], ["pineapple"], ["pitcher"], ["pizza"], ["pizzaslice"], ["playatbeach"], ["playcymbal"], ["playdrum"], ["playground"], ["playguitar"], ["playing"], ["playkeyboard"], ["playrecorder"], ["playvideogame"], ["please"], ["pliers"], ["pointing"], ["policecar"], ["policeman"], ["popcorn"], ["pot"], ["pretzel"], ["proud"], ["pullinghair"], ["pumpkin"], ["punching"], ["putbackpackon"], ["putinbackpack"], ["putondeodorant"], ["putsockson"], ["putstarontree"], ["puzzle"], ["q"], ["lowercase-q"], ["quarter"], ["quietmouth"], ["r"], ["lowercase-r"], ["raisins"], ["rasberry"], ["recorder"], ["rectangle"], ["refrigerator"], ["rideincar"], ["rideon"], ["rv"], ["s"], ["lowercase-s"], ["sacklunch"], ["sad"], ["sandbox"], ["sandwhich"], ["saw"], ["scared"], ["school"], ["science"], ["scissors"], ["scratching"], ["screwdriver"], ["seal"], ["semitruck"], ["september"], ["shakehands"], ["shark"], ["shirt"], ["shirton"], ["shoeson"], ["shorts"], ["shoulder"], ["shovel"], ["sick"], ["singing"], ["sit"], ["sitcrisscross"], ["sitdown"], ["sleep"], ["slide"], ["smell"], ["snake"], ["snapfingers"], ["sneakers"], ["sneeze"], ["snowplow"], ["soap"], ["socialstudies"], ["socks"], ["soda"], ["sodacan"], ["spoolofthread"], ["spoon"], ["sportscar"], ["spring"], ["square"], ["star"], ["steakknife"], ["stethoscope"], ["stocking"], ["stomachache"], ["stop"], ["stopsign"], ["stove"], ["strawberry"], ["stubborn"], ["students"], ["suckingthumb"], ["sugar"], ["summer"], ["sure"], ["surprised"], ["suv"], ["swan"], ["swing"], ["t"], ["lowercase-t"], ["tank"], ["teacher"], ["teddybear"], ["teeth"], ["television"], ["thanksgiving"], ["thinking"], ["thisone"], ["throwaway"], ["throwing"], ["tiesshoes"], ["timeout"], ["time-out-corner"], ["time-out-floor"], ["toast"], ["toaster"], ["toilet"], ["toiletopen"], ["toiletpaper"], ["toothbrush"], ["toothpasteclosed"], ["toothpasteopen"], ["touchhotstove"], ["toystore"], ["train"], ["trampoline"], ["trashcan"], ["trumpet"], ["turnoff"], ["turnon"], ["turtle"], ["tweezers"], ["u"], ["lowercase-u"], ["underwear"], ["usetoothpaste"], ["v"], ["lowercase-v"], ["van"], ["w"], ["lowercase-w"], ["waffles"], ["wagon"], ["wait"], ["walk"], ["washhands"], ["watchingtv"], ["watchtv"], ["water"], ["waterfountain"], ["watermelon"], ["wave"], ["week"], ["wink"], ["winner"], ["winter"], ["wintercoat"], ["wipeface"], ["wipenose"], ["woman"], ["women"], ["woodclamp"], ["wreath"], ["wrench"], ["x"], ["lowercase-x"], ["y"], ["lowercase-y"], ["yawn"], ["yeah"], ["yikes"], ["yucky"], ["yummy"], ["z"], ["lowercase-z"], ["zipper"], ["zipup"]
                              ]
    )
}
