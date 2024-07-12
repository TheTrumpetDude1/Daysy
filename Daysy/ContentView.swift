

//
//  ContentView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 10/19/23.
//

import SwiftUI
import StoreKit
import Pow

struct ContentView: View {
    
    @Namespace private var animation
    
    @StateObject private var speechDelegate = SpeechSynthesizerDelegate()
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @AppStorage("communicationDefaultMode") private var showCommunication: Bool = false
    @AppStorage("buttonsOn") private var lockButtonsOn: Bool = false
    @AppStorage("speakOn") private var speakIcons: Bool = true
    @AppStorage("showCurrSlot") private var showCurrentSlot: Bool = false
    @AppStorage("currSheetIndex") private var currSheetIndex: Int = 0
    
    @State var currSheet = loadSheetArray()[defaults.integer(forKey: "currSheetIndex")]
    
    //for contentview
    @State var editMode = false
    @State var showIcons = false
    @State var showTime = false
    @State var showLabels = false
    @State var showMod = false
    @State var showSettings = false
    @State var showRemoved = false
    @State var removedSelected: [IconObject] = getAllRemoved()
    @State var removedSelectedLabel = "All Sheets"
    @State var showAllSheets = false
    @State var animate = false
    @State var unlockButtons = false
    @State var currGreenSlot = loadSheetArray()[defaults.integer(forKey: "currSheetIndex")].getCurrSlot()
    @State var renameSheet = false
    @State var currListIndex = 0
    @State var currSlotIndex = 0
    @State var pickIcon = false
    @State var addSheetIcon = false
    @State var showDetailsIcons = false
    @State var tempDetails: [String] = []
    @State var checkDetails: [String] = []
    @State var detailIconIndex = -1
    @State var showMore = false
    @State var isTextFieldActive = false
    @State var isTitleTextFieldActive = false
    @State var customIconPreviews: [String : UIImage] = [:]
    @State var wiggleAnimation = false
    
    @State var showCustomPassword = false
    
    //custom labels and times
    @State var currText = ""
    @State var currTitleText = ""
    @State var searchText = ""
    @State private var selectedDate = Date()
    
    //allsheetsview
    @State var newSheetSelection = 0 //0 for newSheetTime and 1 for newSheetLabel
    @State var createNewSheet = false
    @State var sheetArray = loadSheetArray()
    @State var sheetAnimate = false
    @State var currSheetText = ""
    @State var presentAlert = false
    
    @State var deleteAnimationFix = false
    @State private var suggestedWords: [String] = []
    @State var currCommunicationBoard: [[String]] = loadCommunicationBoard()
    
    var body: some View {
        ZStack {
            if showCommunication {
                CommunicationBoardView(onDismiss: {
                    showCommunication.toggle()
                    animate.toggle()
                    currCommunicationBoard = loadCommunicationBoard()
                    if showCurrentSlot {
                        currGreenSlot = currSheet.getCurrSlot()
                    }
                    Task {
                        customIconPreviews = await getCustomIconPreviews()
                        animate.toggle()
                    }
                    
                }, customIconPreviews: customIconPreviews, currCommunicationBoard: currCommunicationBoard)
                .transition(.movingParts.flip.combined(with: .opacity))
            }
            if !showCommunication {
                ZStack {
                    ScrollViewReader { proxy in
                        VStack {
                            ScrollView {
                                if currSheet.label != "Debug, ignore this page" { //always a sheet to render in the background, bug fix
                                    if editMode {
                                        HStack {
                                            Button(action: {
                                                pickIcon.toggle()
                                            }) {
                                                if currSheet.currLabelIcon != nil && !currSheet.currLabelIcon!.isEmpty {
                                                    if UIImage(named: currSheet.currLabelIcon!) == nil {
                                                        Image(uiImage: customIconPreviews[currSheet.currLabelIcon!] ?? UIImage(systemName: "square.fill")!)
                                                            .resizable()
                                                            .frame(width: horizontalSizeClass == .compact ? 50 : 100, height: horizontalSizeClass == .compact ? 50 : 100)
                                                            .clipShape(RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 8 : 16))
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 8 : 16)
                                                                    .stroke(.black, lineWidth: horizontalSizeClass == .compact ? 1 : 3)
                                                            )
                                                            .padding(horizontalSizeClass == .compact ? 2 : 10)
                                                            .matchedGeometryEffect(id: "SheetLabelIcon", in: animation)
                                                            .transition(.asymmetric(insertion: .opacity.combined(with: .scale), removal: .opacity.combined(with: .scale)))
                                                    } else if !currSheet.currLabelIcon!.isEmpty {
                                                        Image(currSheet.currLabelIcon!)
                                                            .scaledToFit()
                                                            .frame(width: horizontalSizeClass == .compact ? 50 : 100, height: horizontalSizeClass == .compact ? 50 : 100)
                                                            .scaleEffect(horizontalSizeClass == .compact ? 0.125 : 0.25)
                                                            .clipShape(RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 8 : 16))
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 8 : 16)
                                                                    .stroke(.black, lineWidth: horizontalSizeClass == .compact ? 1 : 3)
                                                            )
                                                            .padding(horizontalSizeClass == .compact ? 2 : 10)
                                                            .matchedGeometryEffect(id: "SheetLabelIcon", in: animation)
                                                            .transition(.asymmetric(insertion: .opacity.combined(with: .scale), removal: .opacity.combined(with: .scale)))
                                                    } else {
                                                        Image(systemName: "plus.square.dashed")
                                                            .resizable()
                                                            .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                                            .symbolRenderingMode(.hierarchical)
                                                            .foregroundStyle(.gray)
                                                            .matchedGeometryEffect(id: "SheetLabelIcon", in: animation)
                                                            .padding(horizontalSizeClass == .compact ? 2 : 10)
                                                    }
                                                } else {
                                                    Image(systemName: "plus.square.dashed")
                                                        .resizable()
                                                        .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                                        .symbolRenderingMode(.hierarchical)
                                                        .foregroundStyle(.gray)
                                                        .matchedGeometryEffect(id: "SheetLabelIcon", in: animation)
                                                        .padding(horizontalSizeClass == .compact ? 2 : 10)
                                                }
                                            }
                                            
                                            VStack {
                                                Spacer()
                                                TextField("Name Sheet", text: $currTitleText, onEditingChanged: { editing in
                                                    isTitleTextFieldActive = editing
                                                    animate.toggle()
                                                }, onCommit: {
                                                    currSheet.label = currTitleText
                                                    var newSheetArray = loadSheetArray()
                                                    newSheetArray[currSheetIndex] = currSheet
                                                    newSheetArray[currSheetIndex] = autoRemoveSlots(newSheetArray[currSheetIndex])
                                                    currSheet = newSheetArray[currSheetIndex]
                                                    saveSheetArray(sheetObjects: newSheetArray)
                                                })
                                                .multilineTextAlignment(.center)
                                                .font(.system(size: horizontalSizeClass == .compact ? 50 : 100, weight: .semibold, design: .rounded))
                                                .padding()
                                                .background(
                                                    Color(.systemGray4),
                                                    in: RoundedRectangle(cornerRadius: 20)
                                                )
                                                .onChange(of: currTitleText, perform: { _ in
                                                    suggestedWords = updateSuggestedWords(currLabel: currTitleText)
                                                })
                                                .matchedGeometryEffect(id: "SheetLabel", in: animation)
                                                .padding(horizontalSizeClass == .compact ? 2 : 10)
                                                
                                                if isTitleTextFieldActive {
                                                    ScrollView(.horizontal, showsIndicators: false) {
                                                        HStack {
                                                            ForEach(suggestedWords.prefix(horizontalSizeClass == .compact ? 10 : 20), id: \.self) { word in
                                                                Button(action: {
                                                                    currTitleText = word
                                                                    animate.toggle()
                                                                }) {
                                                                    Text(word)
                                                                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .medium, design: .rounded))
                                                                        .padding()
                                                                        .background(
                                                                            Color(.systemGray5),
                                                                            in: RoundedRectangle(cornerRadius: 20)
                                                                        )
                                                                        .foregroundStyle(.purple)
                                                                }
                                                            }
                                                        }
                                                        if suggestedWords.count == 0 {
                                                            Text("filler")
                                                                .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .medium, design: .rounded))
                                                                .padding(2)
                                                                .foregroundStyle(.clear)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    } else {
                                        HStack {
                                            if currSheet.currLabelIcon != nil && !currSheet.currLabelIcon!.isEmpty {
                                                if UIImage(named: currSheet.currLabelIcon!) == nil {
                                                    Image(uiImage: customIconPreviews[currSheet.currLabelIcon!] ?? UIImage(systemName: "square.fill")!)
                                                        .resizable()
                                                        .frame(width: horizontalSizeClass == .compact ? 50 : 100, height: horizontalSizeClass == .compact ? 50 : 100)
                                                        .clipShape(RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 8 : 16))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 8 : 16)
                                                                .stroke(.black, lineWidth: horizontalSizeClass == .compact ? 1 : 3)
                                                        )
                                                        .matchedGeometryEffect(id: "SheetLabelIcon", in: animation)
                                                        .padding(horizontalSizeClass == .compact ? 2 : 10)
                                                } else if !currSheet.currLabelIcon!.isEmpty {
                                                    Image(currSheet.currLabelIcon!)
                                                        .scaledToFit()
                                                        .frame(width: horizontalSizeClass == .compact ? 50 : 100, height: horizontalSizeClass == .compact ? 50 : 100)
                                                        .scaleEffect(horizontalSizeClass == .compact ? 0.125 : 0.25)
                                                        .clipShape(RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 8 : 16))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 8 : 16)
                                                                .stroke(.black, lineWidth: horizontalSizeClass == .compact ? 1 : 3)
                                                        )
                                                        .matchedGeometryEffect(id: "SheetLabelIcon", in: animation)
                                                        .padding(horizontalSizeClass == .compact ? 2 : 10)
                                                }
                                            }
                                            Text(currSheet.label)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.01)
                                                .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                                .matchedGeometryEffect(id: "SheetLabel", in: animation)
                                                .padding(horizontalSizeClass == .compact ? 2 : 10)
                                        }
                                    }
                                    if horizontalSizeClass == .compact { //this is the main grid for iPhone
                                        ForEach(0..<currSheet.currGrid.count, id: \.self) { list in
                                            VStack {
                                                //show the time or label
                                                if currSheet.gridType == "time" {
                                                    Button(action: {
                                                        if editMode {
                                                            currListIndex = list
                                                            selectedDate = currSheet.currGrid[list].currTime
                                                            showTime.toggle()
                                                        }
                                                    }) {
                                                        if editMode {
                                                            Image(systemName: "square.and.pencil")
                                                                .resizable()
                                                                .minimumScaleFactor(0.01)
                                                                .frame(width: 30, height: 30)
                                                                .foregroundStyle(.gray)
                                                                .padding(.trailing)
                                                        }
                                                        
                                                        Text(getTime(date: currSheet.currGrid[list].currTime))
                                                            .lineLimit(1)
                                                            .minimumScaleFactor(0.01)
                                                            .font(.system(size: 30, weight: .bold, design: .rounded))
                                                    }
                                                    .foregroundStyle(.primary)
                                                    .shadow(color: currGreenSlot == list && !editMode && showCurrentSlot ? Color(.systemBackground) : Color.clear, radius: 5)
                                                    .padding()
                                                    .contextMenu {
                                                        if lockButtonsOn && !unlockButtons {
                                                            Button {
                                                                if !canUseBiometrics() && !canUsePassword() {
                                                                    showCustomPassword = true
                                                                } else {
                                                                    Task {
                                                                        unlockButtons = await authenticateWithBiometrics()
                                                                        animate.toggle()
                                                                    }
                                                                    if unlockButtons {
                                                                        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
                                                                            unlockButtons = false
                                                                        }
                                                                    }
                                                                }
                                                            } label: {
                                                                Label("Unlock Buttons", systemImage: "lock.open")
                                                            }
                                                        } else {
                                                            Button {
                                                                currListIndex = list
                                                                selectedDate = currSheet.currGrid[list].currTime
                                                                showTime.toggle()
                                                            } label: {
                                                                Label("Edit Time", systemImage: "square.and.pencil")
                                                            }
                                                        }
                                                    }
                                                } else {
                                                    Button(action: {
                                                        if editMode {
                                                            currListIndex = list
                                                            showLabels.toggle()
                                                            currText = currSheet.currGrid[list].currLabel
                                                        }
                                                    }) {
                                                        if editMode {
                                                            Image(systemName: "square.and.pencil")
                                                                .resizable()
                                                                .minimumScaleFactor(0.01)
                                                                .frame(width: 30, height: 30)
                                                                .foregroundStyle(.gray)
                                                        }
                                                        
                                                        Text(currSheet.currGrid[list].currLabel)
                                                            .lineLimit(1)
                                                            .minimumScaleFactor(0.01)
                                                            .font(.system(size: 30, weight: .bold, design: .rounded))
                                                    }
                                                    .foregroundStyle(.primary)
                                                    .padding()
                                                    .contextMenu {
                                                        if lockButtonsOn && !unlockButtons {
                                                            Button {
                                                                if !canUseBiometrics() && !canUsePassword() {
                                                                    showCustomPassword = true
                                                                } else {
                                                                    Task {
                                                                        unlockButtons = await authenticateWithBiometrics()
                                                                        animate.toggle()
                                                                    }
                                                                    if unlockButtons {
                                                                        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
                                                                            withAnimation(.snappy) {
                                                                                unlockButtons = false
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            } label: {
                                                                Label("Unlock Buttons", systemImage: "lock.open")
                                                            }
                                                        } else {
                                                            Button {
                                                                currListIndex = list
                                                                showLabels.toggle()
                                                                currText = currSheet.currGrid[list].currLabel
                                                            } label: {
                                                                Label("Edit Label", systemImage: "square.and.pencil")
                                                            }
                                                        }
                                                    }
                                                }
                                                LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                                                    ForEach(0..<currSheet.currGrid[list].currIcons.count, id: \.self) { slot in //this loop displays the slots/images
                                                        Button(action: {
                                                            if editMode {
                                                                currListIndex = list
                                                                currSlotIndex = slot
                                                                showIcons.toggle()
                                                                searchText = ""
                                                            } else if !currSheet.currGrid[list].currIcons[slot].currIcon.isEmpty {
                                                                currListIndex = list
                                                                currSlotIndex = slot
                                                                withAnimation(.snappy) {
                                                                    showMod.toggle()
                                                                    unlockButtons = false
                                                                }
                                                                hapticFeedback()
                                                                tempDetails = []
                                                                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                                                    tempDetails = currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails ?? []
                                                                    checkDetails = currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails ?? []
                                                                    animate.toggle()
                                                                }
                                                                speechDelegate.stopSpeaking()
                                                                speechDelegate.speak(currSheet.currGrid[list].currIcons[slot].currIcon)
                                                            }
                                                        }) {
                                                            if getCustomPECSAddresses()[currSheet.currGrid[list].currIcons[slot].currIcon] == nil && UIImage(named: currSheet.currGrid[list].currIcons[slot].currIcon) == nil { //if there isnt an icon
                                                                if editMode {
                                                                    Image(systemName: "plus.viewfinder")
                                                                        .resizable()
                                                                        .scaledToFit()
                                                                        .symbolRenderingMode(.hierarchical)
                                                                        .foregroundStyle(.gray)
                                                                }
                                                            } else {
                                                                ZStack {
                                                                    if UIImage(named: currSheet.currGrid[list].currIcons[slot].currIcon) == nil {
                                                                        //check if default icon or custom icon and handle
                                                                        Image(uiImage: customIconPreviews[ currSheet.currGrid[list].currIcons[slot].currIcon] ?? UIImage(systemName: "square.fill")!)
                                                                            .resizable()
                                                                            .scaledToFit()
                                                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                                                            .overlay(
                                                                                RoundedRectangle(cornerRadius: 16)
                                                                                    .stroke(.black, lineWidth: 6)
                                                                            )
                                                                    } else {
                                                                        Image(currSheet.currGrid[list].currIcons[slot].currIcon)
                                                                            .resizable()
                                                                            .scaledToFit()
                                                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                                                            .overlay(
                                                                                RoundedRectangle(cornerRadius: 16)
                                                                                    .stroke(.black, lineWidth: 6)
                                                                            )
                                                                    }
                                                                    VStack {
                                                                        HStack {
                                                                            if (currSheet.currGrid[list].currIcons[slot].currDetails ?? []).count > 0 {
                                                                                Image(systemName: "\((currSheet.currGrid[list].currIcons[slot].currDetails ?? []).count).circle.fill")
                                                                                    .resizable()
                                                                                    .frame(width: horizontalSizeClass == .compact ? 20 : 40, height: horizontalSizeClass == .compact ? 20 : 40)
                                                                                    .foregroundStyle(Color(.systemGray2))
                                                                                    .padding(.trailing, horizontalSizeClass == .compact ? 5 : 10)
                                                                                    .padding(.bottom, horizontalSizeClass == .compact ? 5 : 10)
                                                                            }
                                                                            Spacer()
                                                                        }
                                                                        Spacer()
                                                                    }
                                                                }
                                                                .transition(.asymmetric(insertion: .opacity.combined(with: .scale), removal: .opacity.combined(with: .scale)))
                                                            }
                                                        }
                                                        .matchedGeometryEffect(id: "\(list)\(slot)", in: animation)
                                                        .contextMenu {
                                                            if lockButtonsOn && !unlockButtons {
                                                                Button {
                                                                    if !canUseBiometrics() && !canUsePassword() {
                                                                        showCustomPassword = true
                                                                    } else {
                                                                        Task {
                                                                            unlockButtons = await authenticateWithBiometrics()
                                                                            animate.toggle()
                                                                        }
                                                                        if unlockButtons {
                                                                            Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
                                                                                withAnimation(.snappy) {
                                                                                    unlockButtons = false
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                } label: {
                                                                    Label("Unlock Buttons", systemImage: "lock.open")
                                                                }
                                                            } else {
                                                                if currSheet.currGrid[list].currIcons[slot].currIcon.isEmpty {
                                                                    Button {
                                                                        currListIndex = list
                                                                        currSlotIndex = slot
                                                                        showIcons.toggle()
                                                                        searchText = ""
                                                                    } label: {
                                                                        Label("Add Icon", systemImage: "plus.viewfinder")
                                                                    }
                                                                } else {
                                                                    
                                                                    Button {
                                                                        currListIndex = list
                                                                        currSlotIndex = slot
                                                                        showIcons.toggle()
                                                                        searchText = ""
                                                                    } label: {
                                                                        Label("Change Icon", systemImage: "arrow.2.squarepath")
                                                                    }
                                                                    
                                                                    Button {
                                                                        tempDetails = [""] //hacky fix instead of binding, fixes not updating
                                                                        animate.toggle()
                                                                        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                                                            tempDetails = currSheet.currGrid[list].currIcons[slot].currDetails ?? []
                                                                            checkDetails = currSheet.currGrid[list].currIcons[slot].currDetails ?? []
                                                                        }
                                                                        currListIndex = list
                                                                        currSlotIndex = slot
                                                                        withAnimation(.snappy) {
                                                                            showMod.toggle()
                                                                        }
                                                                    } label: {
                                                                        Label("Add Details", systemImage: "plus.square.on.square")
                                                                    }
                                                                    
                                                                    Divider()
                                                                    
                                                                    if editMode {
                                                                        Button(role: .destructive) {
                                                                            currSheet.currGrid[list].currIcons[slot].currIcon = ""
                                                                            currSheet.currGrid[list].currIcons[slot].currDetails = []
                                                                            animate.toggle()
                                                                        } label: {
                                                                            Label("Delete Icon", systemImage: "trash")
                                                                        }
                                                                    } else {
                                                                        Button {
                                                                            unlockButtons = false
                                                                            currSheet.removedIcons.append(currSheet.currGrid[list].currIcons[slot])
                                                                            currSheet.currGrid[list].currIcons[slot].currIcon = ""
                                                                            currSheet.currGrid[list].currIcons[slot].currDetails = []
                                                                            var newArray = loadSheetArray()
                                                                            newArray[currSheetIndex] = currSheet
                                                                            newArray[currSheetIndex] = autoRemoveSlots(newArray[currSheetIndex])
                                                                            currSheet = newArray[currSheetIndex]
                                                                            saveSheetArray(sheetObjects: newArray)
                                                                            animate.toggle()
                                                                            if removedSelectedLabel == "All Sheets" {
                                                                                removedSelected = getAllRemoved()
                                                                            } else {
                                                                                removedSelected = getAllRemoved()
                                                                                currSheet = loadSheetArray()[currSheetIndex]
                                                                                
                                                                                removedSelected = currSheet.removedIcons
                                                                            }
                                                                            hapticFeedback(type: 1)
                                                                        } label: {
                                                                            Label("Remove Icon", systemImage: "square.slash")
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        .padding()
                                                    }
                                                }
                                                if editMode {
                                                    Button(action: {
                                                        if !deleteAnimationFix {
                                                            deleteAnimationFix = true
                                                            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
                                                                deleteAnimationFix = false
                                                            }
                                                            
                                                            withAnimation(.snappy) {
                                                                if currSheet.currGrid.count > 1 {
                                                                    animate.toggle()
                                                                    currSheet.currGrid.remove(at: list)
                                                                } else {
                                                                    currSheet.currGrid.removeAll()
                                                                    currSheet.currGrid.append(GridSlot(currLabel: currSheet.gridType))
                                                                }
                                                            }
                                                        }
                                                        //save array aka "autosave"
                                                        var newSheetArray = loadSheetArray()
                                                        newSheetArray[currSheetIndex] = currSheet
                                                        currSheet = newSheetArray[currSheetIndex]
                                                        saveSheetArray(sheetObjects: newSheetArray)
                                                        
                                                    }) {
                                                        Image(systemName: "trash.square.fill")
                                                            .resizable()
                                                            .frame(width: 75, height: 75)
                                                            .padding()
                                                            .symbolRenderingMode(.hierarchical)
                                                            .foregroundStyle(.red)
                                                    }
                                                    .padding(.leading)
                                                }
                                            }
                                            .background(
                                                currGreenSlot == list && !editMode && showCurrentSlot ? .green : Color(.systemGray6),
                                                in: RoundedRectangle(cornerRadius: 20)
                                            )
                                            .padding()
                                            
                                        }
                                    } else { //this is the main grid for iPad
                                        ZStack { //this is the left hand rectangle behind the labels
                                            GeometryReader { geometry in
                                                RoundedRectangle(cornerRadius: 20)
                                                    .frame(width: editMode ? (geometry.size.width / 6) - 7 : (geometry.size.width / 5) - 7, height: geometry.size.height)
                                                    .foregroundStyle(Color(.systemGray4))
                                            }
                                            VStack {
                                                LazyVGrid(columns: Array(repeating: GridItem(), count: editMode ? 6 : 5)) { //this is the main grid for the app
                                                    ForEach(0..<currSheet.currGrid.count, id: \.self) { list in
                                                        if currSheet.gridType == "time" {
                                                            ZStack {
                                                                RoundedRectangle(cornerRadius: 20)
                                                                    .foregroundStyle(currGreenSlot == list && !editMode && showCurrentSlot ? .green : .clear)
                                                                    .scaledToFill()
                                                                Button(action: {
                                                                    if editMode {
                                                                        currListIndex = list
                                                                        selectedDate = currSheet.currGrid[list].currTime
                                                                        showTime.toggle()
                                                                    }
                                                                }) {
                                                                    HStack {
                                                                        if editMode {
                                                                            Image(systemName: "square.and.pencil")
                                                                                .resizable()
                                                                                .minimumScaleFactor(0.01)
                                                                                .frame(width: 30, height: 30)
                                                                                .foregroundStyle(.gray)
                                                                        }
                                                                        
                                                                        Text(getTime(date: currSheet.currGrid[list].currTime))
                                                                            .lineLimit(1)
                                                                            .minimumScaleFactor(0.01)
                                                                            .font(.system(size: 100, weight: .bold, design: .rounded))
                                                                    }
                                                                }
                                                                .foregroundStyle(.primary)
                                                                .shadow(color: currGreenSlot == list && !editMode && showCurrentSlot ? Color(.systemBackground) : Color.clear, radius: 5)
                                                                .padding(horizontalSizeClass == .compact ? 3 : 10)
                                                                .contextMenu {
                                                                    if lockButtonsOn && !unlockButtons {
                                                                        Button {
                                                                            if !canUseBiometrics() && !canUsePassword() {
                                                                                showCustomPassword = true
                                                                            } else {
                                                                                Task {
                                                                                    unlockButtons = await authenticateWithBiometrics()
                                                                                    animate.toggle()
                                                                                }
                                                                                if unlockButtons {
                                                                                    Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
                                                                                        withAnimation(.snappy) {
                                                                                            unlockButtons = false
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        } label: {
                                                                            Label("Unlock Buttons", systemImage: "lock.open")
                                                                        }
                                                                    } else {
                                                                        Button {
                                                                            currListIndex = list
                                                                            selectedDate = currSheet.currGrid[list].currTime
                                                                            showTime.toggle()
                                                                        } label: {
                                                                            Label("Edit Time", systemImage: "square.and.pencil")
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            ZStack {
                                                                RoundedRectangle(cornerRadius: 20)
                                                                    .foregroundStyle(currGreenSlot == list && !editMode && showCurrentSlot ? .green : .clear)
                                                                    .scaledToFill()
                                                                Button(action: {
                                                                    if editMode {
                                                                        currListIndex = list
                                                                        showLabels.toggle()
                                                                        currText = currSheet.currGrid[list].currLabel
                                                                    }
                                                                }) {
                                                                    HStack {
                                                                        if editMode {
                                                                            Image(systemName: "square.and.pencil")
                                                                                .resizable()
                                                                                .minimumScaleFactor(0.01)
                                                                                .frame(width: 30, height: 30)
                                                                                .foregroundStyle(.gray)
                                                                        }
                                                                        
                                                                        Text(currSheet.currGrid[list].currLabel)
                                                                            .lineLimit(1)
                                                                            .minimumScaleFactor(0.01)
                                                                            .font(.system(size: 100, weight: .bold, design: .rounded))
                                                                    }
                                                                }
                                                                .foregroundStyle(.primary)
                                                                .shadow(color: currGreenSlot == list && !editMode && showCurrentSlot ? Color(.systemBackground) : Color.clear, radius: 5)
                                                                .padding(horizontalSizeClass == .compact ? 3 : 10)
                                                                .contextMenu {
                                                                    if lockButtonsOn && !unlockButtons {
                                                                        Button {
                                                                            if !canUseBiometrics() && !canUsePassword() {
                                                                                showCustomPassword = true
                                                                            } else {
                                                                                Task {
                                                                                    unlockButtons = await authenticateWithBiometrics()
                                                                                    animate.toggle()
                                                                                }
                                                                                if unlockButtons {
                                                                                    Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
                                                                                        unlockButtons = false
                                                                                    }
                                                                                }
                                                                            }
                                                                        } label: {
                                                                            Label("Unlock Buttons", systemImage: "lock.open")
                                                                        }
                                                                    } else {
                                                                        Button {
                                                                            currListIndex = list
                                                                            showLabels.toggle()
                                                                            currText = currSheet.currGrid[list].currLabel
                                                                        } label: {
                                                                            Label("Edit Label", systemImage: "square.and.pencil")
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        ForEach(0..<currSheet.currGrid[list].currIcons.count, id: \.self) { slot in //this loop displays the slots/images
                                                            Button(action: {
                                                                if editMode {
                                                                    currListIndex = list
                                                                    currSlotIndex = slot
                                                                    showIcons.toggle()
                                                                    searchText = ""
                                                                } else if !currSheet.currGrid[list].currIcons[slot].currIcon.isEmpty {
                                                                    currListIndex = list
                                                                    currSlotIndex = slot
                                                                    withAnimation(.snappy) {
                                                                        showMod.toggle()
                                                                        unlockButtons = false
                                                                    }
                                                                    tempDetails = []
                                                                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                                                        tempDetails = currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails ?? []
                                                                        checkDetails = currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails ?? []
                                                                        animate.toggle()
                                                                    }
                                                                    speechDelegate.stopSpeaking()
                                                                    speechDelegate.speak(currSheet.currGrid[list].currIcons[slot].currIcon)
                                                                }
                                                            }) {
                                                                if getCustomPECSAddresses()[currSheet.currGrid[list].currIcons[slot].currIcon] == nil && UIImage(named: currSheet.currGrid[list].currIcons[slot].currIcon) == nil { //if there isnt an icon
                                                                    if editMode {
                                                                        Image(systemName: "plus.viewfinder")
                                                                            .resizable()
                                                                            .scaledToFit()
                                                                            .padding(10)
                                                                            .symbolRenderingMode(.hierarchical)
                                                                            .foregroundStyle(.gray)
                                                                    }
                                                                } else {
                                                                    ZStack {
                                                                        if UIImage(named: currSheet.currGrid[list].currIcons[slot].currIcon) == nil {
                                                                            //check if default icon or custom icon and handle
                                                                            Image(uiImage: customIconPreviews[currSheet.currGrid[list].currIcons[slot].currIcon] ?? UIImage(systemName: "square.fill")!)
                                                                                .resizable()
                                                                                .scaledToFit()
                                                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                                                .overlay(
                                                                                    RoundedRectangle(cornerRadius: 16)
                                                                                        .stroke(currGreenSlot == list && !editMode && showCurrentSlot ? .green : .black, lineWidth: currGreenSlot == list && showCurrentSlot ? 10 : 6)
                                                                                )
                                                                                .padding(horizontalSizeClass == .compact ? 0 : 5)
                                                                        } else {
                                                                            Image(currSheet.currGrid[list].currIcons[slot].currIcon)
                                                                                .resizable()
                                                                                .scaledToFit()
                                                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                                                .overlay(
                                                                                    RoundedRectangle(cornerRadius: 16)
                                                                                        .stroke(currGreenSlot == list && !editMode && showCurrentSlot ? .green : .black, lineWidth: currGreenSlot == list && showCurrentSlot ? 10 : 6)
                                                                                )
                                                                                .padding(horizontalSizeClass == .compact ? 0 : 5)
                                                                        }
                                                                        VStack {
                                                                            HStack {
                                                                                if (currSheet.currGrid[list].currIcons[slot].currDetails ?? []).count > 0 {
                                                                                    Image(systemName: "\((currSheet.currGrid[list].currIcons[slot].currDetails ?? []).count).circle.fill")
                                                                                        .resizable()
                                                                                        .frame(width: horizontalSizeClass == .compact ? 20 : 40, height: horizontalSizeClass == .compact ? 20 : 40)
                                                                                        .foregroundStyle(Color(.systemGray2))
                                                                                        .padding(.trailing, horizontalSizeClass == .compact ? 5 : 10)
                                                                                        .padding(.bottom, horizontalSizeClass == .compact ? 5 : 10)
                                                                                }
                                                                                Spacer()
                                                                            }
                                                                            Spacer()
                                                                        }
                                                                    }
                                                                    .transition(.asymmetric(insertion: .opacity.combined(with: .scale), removal: .opacity.combined(with: .scale)))
                                                                }
                                                            }
                                                            .matchedGeometryEffect(id: "\(list)\(slot)", in: animation)
                                                            .contextMenu {
                                                                if lockButtonsOn && !unlockButtons {
                                                                    Button {
                                                                        if !canUseBiometrics() && !canUsePassword() {
                                                                            showCustomPassword = true
                                                                        } else {
                                                                            Task {
                                                                                unlockButtons = await authenticateWithBiometrics()
                                                                                animate.toggle()
                                                                            }
                                                                            if unlockButtons {
                                                                                Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
                                                                                    withAnimation(.snappy) {
                                                                                        unlockButtons = false
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    } label: {
                                                                        Label("Unlock Buttons", systemImage: "lock.open")
                                                                    }
                                                                } else {
                                                                    if currSheet.currGrid[list].currIcons[slot].currIcon.isEmpty {
                                                                        Button {
                                                                            currListIndex = list
                                                                            currSlotIndex = slot
                                                                            showIcons.toggle()
                                                                            searchText = ""
                                                                        } label: {
                                                                            Label("Add Icon", systemImage: "plus.viewfinder")
                                                                        }
                                                                    } else {
                                                                        
                                                                        Button {
                                                                            currListIndex = list
                                                                            currSlotIndex = slot
                                                                            showIcons.toggle()
                                                                            searchText = ""
                                                                        } label: {
                                                                            Label("Change Icon", systemImage: "arrow.2.squarepath")
                                                                        }
                                                                        
                                                                        Button {
                                                                            tempDetails = [""] //hacky fix instead of binding, fixes not updating
                                                                            animate.toggle()
                                                                            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                                                                tempDetails = currSheet.currGrid[list].currIcons[slot].currDetails ?? []
                                                                                checkDetails = currSheet.currGrid[list].currIcons[slot].currDetails ?? []
                                                                            }
                                                                            currListIndex = list
                                                                            currSlotIndex = slot
                                                                            withAnimation(.snappy) {
                                                                                showMod.toggle()
                                                                            }
                                                                        } label: {
                                                                            Label("Add Details", systemImage: "plus.square.on.square")
                                                                        }
                                                                        
                                                                        Divider()
                                                                        
                                                                        if editMode {
                                                                            Button(role: .destructive) {
                                                                                currSheet.currGrid[list].currIcons[slot].currIcon = ""
                                                                                currSheet.currGrid[list].currIcons[slot].currDetails = []
                                                                                animate.toggle()
                                                                            } label: {
                                                                                Label("Delete Icon", systemImage: "trash")
                                                                            }
                                                                        } else {
                                                                            Button {
                                                                                unlockButtons = false
                                                                                currSheet.removedIcons.append(currSheet.currGrid[list].currIcons[slot])
                                                                                currSheet.currGrid[list].currIcons[slot].currIcon = ""
                                                                                currSheet.currGrid[list].currIcons[slot].currDetails = []
                                                                                var newArray = loadSheetArray()
                                                                                newArray[currSheetIndex] = currSheet
                                                                                newArray[currSheetIndex] = autoRemoveSlots(newArray[currSheetIndex])
                                                                                currSheet = newArray[currSheetIndex]
                                                                                saveSheetArray(sheetObjects: newArray)
                                                                                animate.toggle()
                                                                                if removedSelectedLabel == "All Sheets" {
                                                                                    removedSelected = getAllRemoved()
                                                                                } else {
                                                                                    removedSelected = getAllRemoved()
                                                                                    currSheet = loadSheetArray()[currSheetIndex]
                                                                                    
                                                                                    removedSelected = currSheet.removedIcons
                                                                                }
                                                                                hapticFeedback(type: 1)
                                                                            } label: {
                                                                                Label("Remove Icon", systemImage: "square.slash")
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                            //                                                            }
                                                            //                                                            .scaledToFit()
                                                        }
                                                        if editMode {
                                                            Button(action: {
                                                                if !deleteAnimationFix {
                                                                    
                                                                    deleteAnimationFix = true //if you spam click delete on the last row on iPad, it will try to delete through the animation which results in a crash from attempting to delete an index that doesnt exist. This is just a hacky fix that doesnt let you delete things less than one second apart (which shouldnt be an issue anyways)
                                                                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
                                                                        deleteAnimationFix = false
                                                                    }
                                                                    
                                                                    withAnimation(.snappy) {
                                                                        if currSheet.currGrid.count > 1 {
                                                                            animate.toggle()
                                                                            currSheet.currGrid.remove(at: list)
                                                                        } else {
                                                                            currSheet.currGrid.removeAll()
                                                                            currSheet.currGrid.append(GridSlot(currLabel: currSheet.gridType))
                                                                        }
                                                                    }
                                                                    //save array aka "autosave"
                                                                    var newSheetArray = loadSheetArray()
                                                                    newSheetArray[currSheetIndex] = currSheet
                                                                    currSheet = newSheetArray[currSheetIndex]
                                                                    saveSheetArray(sheetObjects: newSheetArray)
                                                                }
                                                            }) {
                                                                Image(systemName: "trash.square.fill")
                                                                    .resizable()
                                                                    .scaledToFit()
                                                                    .padding()
                                                                    .symbolRenderingMode(.hierarchical)
                                                                    .foregroundStyle(.red)
                                                            }
                                                            .padding()
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                if editMode { //show the plus under the main grid while in edit mode
                                    Button(action: {
                                        withAnimation(.snappy) {
                                            currSheet.currGrid.append(GridSlot(currLabel: currSheet.currGrid.count < 1 ? "First" : "Then"))
                                        }
                                        //save array aka "autosave"
                                        var newSheetArray = loadSheetArray()
                                        newSheetArray[currSheetIndex] = currSheet
                                        currSheet = newSheetArray[currSheetIndex]
                                        saveSheetArray(sheetObjects: newSheetArray)
                                    }) {
                                        Image(systemName:"plus.square.fill")
                                            .resizable()
                                            .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                        
                                            .foregroundStyle(.green)
                                            .padding()
                                    }
                                }
                                Rectangle() //this was originally when plus and minus were in bottom row, you can id this rectangle and use it to scroll to button
                                    .foregroundStyle(.clear)
                                    .navigationBarHidden(true)
                                    .frame(width: 1, height: 1)
                                    .padding(.bottom, 150)
                            }
                        }
                        .navigationViewStyle(StackNavigationViewStyle())
                        .navigationBarHidden(true)
                        .onAppear{ //have to use timer because of a bug in NavigationView on ios 15 and older, displays too fast
                            defaults.set(true, forKey: "completedTutorial")
                            if showCurrentSlot {
                                let currentDate = Date()
                                let secondsUntilNextMinute = 60 - Calendar.current.component(.second, from: currentDate)
                                let delayInSeconds = TimeInterval(secondsUntilNextMinute)
                                
                                Timer.scheduledTimer(withTimeInterval: delayInSeconds, repeats: true) { _ in
                                    currGreenSlot = loadSheetArray()[currSheetIndex].getCurrSlot()
                                    animate.toggle()
                                }
                            }
                            if !defaults.bool(forKey: "communicationUpdate") { //something in here straight up deletes all the custom icons? not from usage or sheet label icon though
                                defaults.set(true, forKey: "speakOn")
                                defaults.set(true, forKey: "aiOn")
                                emptyIconFix()
                                currSheet = removePlusViewfinders()
                                currSheet = migrateRemoved()
                                removedSelected = getAllRemoved()
                                currCommunicationBoard = loadCommunicationBoard()
                                currSheet = removePrefixesFix()[currSheetIndex]
                                defaults.set(true, forKey: "communicationUpdate")
                            }
                            wiggleAnimation.toggle()
                            Timer.scheduledTimer(withTimeInterval: 90, repeats: true) { _ in
                                wiggleAnimation.toggle()
                            }
                        }
                        //end of the main grid
                    }
                    .opacity(showMod ? 0 : 1)
                    //bottom row here
                    VStack {
                        Spacer()
                        if sheetArray.count < 2 {
                            VStack {
                                Text("Hm, this feels a bit empty! You don't have any Sheets yet, create a new one below.")
                                    .minimumScaleFactor(0.01)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .bold, design: .rounded))
                                    .foregroundStyle(.gray)
                                    .padding()
                                    .padding()
                                //                                HStack {
                                Button(action: {
                                    showAllSheets.toggle()
                                    withAnimation(.snappy) {
                                        createNewSheet.toggle()
                                    }
                                }) {
                                    VStack {
                                        Image(systemName: "plus.square.fill.on.square.fill")
                                            .resizable()
                                            .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                        
                                            .foregroundStyle(.green)
                                            .symbolRenderingMode(.hierarchical)
                                            .padding()
                                        Text("Create Sheet")
                                            .minimumScaleFactor(0.01)
                                            .multilineTextAlignment(.center)
                                            .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .bold, design: .rounded))
                                            .foregroundStyle(.green)
                                    }
                                }
                                .changeEffect(
                                    .wiggle(rate: .fast), value: wiggleAnimation)
                            }
                            Spacer()
                        }
                        HStack {
                            Spacer()
                            if horizontalSizeClass == .compact { //bottom row of buttons for iPhone
                                if editMode { //show the bottom row of buttons for edit mode
                                    HStack {
                                        Button(action: {
                                            if sheetArray.count > 1 {
                                                presentAlert.toggle()
                                            }
                                        }) {
                                            Image(systemName:"trash.square.fill")
                                                .resizable()
                                                .frame(width: 75, height: 75)
                                            
                                                .foregroundStyle(.red)
                                                .padding()
                                        }
                                        
                                        Button(action: { //saves the array and disables edit mode
                                            if currSheet.gridType == "time" {
                                                currSheet.currGrid = sortSheet(currSheet.currGrid)
                                            }
                                            currSheet.label = currTitleText
                                            var newSheetArray = loadSheetArray()
                                            newSheetArray[currSheetIndex] = currSheet
                                            newSheetArray[currSheetIndex] = autoRemoveSlots(newSheetArray[currSheetIndex])
                                            currSheet = newSheetArray[currSheetIndex]
                                            saveSheetArray(sheetObjects: newSheetArray)
                                            animate.toggle()
                                            manageNotifications()
                                            editMode.toggle()
                                        }) {
                                            Image(systemName:"checkmark.square.fill")
                                                .resizable()
                                                .frame(width: 75, height: 75)
                                                .foregroundStyle(.green)
                                                .padding()
                                            //}
                                        }
                                    }
                                } else { //show the non edit mode buttons at the bottom
                                    if lockButtonsOn && !unlockButtons { //but dont show the buttons if lock buttons is on
                                        Button(action: {
                                            if !canUseBiometrics() && !canUsePassword() {
                                                showCustomPassword = true
                                            } else {
                                                Task {
                                                    unlockButtons = await authenticateWithBiometrics()
                                                    animate.toggle()
                                                }
                                                if unlockButtons {
                                                    Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
                                                        withAnimation(.snappy) {
                                                            unlockButtons = false
                                                        }
                                                    }
                                                }
                                            }
                                        }) {
                                            Text("\(Image(systemName: "lock.square.fill"))")
                                                .font(.system(size: horizontalSizeClass == .compact ? 75 : 100))
                                                .foregroundStyle(.regularMaterial)
                                        }
                                        .padding()
                                    } else {
                                        VStack {
                                            HStack {
                                                Button(action: {
                                                    showCommunication.toggle()
                                                    animate.toggle()
                                                    unlockButtons = false
                                                    speechDelegate.stopSpeaking()
                                                }) {
                                                    VStack {
                                                        ZStack {
                                                            Image(systemName: "square.fill")
                                                                .resizable()
                                                                .frame(width: 65, height: 65)
                                                                .foregroundStyle(.orange)
                                                            Text("\(Image(systemName: "hand.tap"))")
                                                                .font(.system(size: 30))
                                                                .foregroundStyle(Color(.systemBackground))
                                                                .symbolRenderingMode(.hierarchical)
                                                        }
                                                        Text("Board")
                                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                            .foregroundStyle(.orange)
                                                    }
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                .padding([.leading, .trailing])
                                                
                                                if sheetArray.count > 1 {
                                                    Button(action: {
                                                        editMode.toggle()
                                                        currTitleText = currSheet.label
                                                        animate.toggle()
                                                        unlockButtons = false
                                                        speechDelegate.stopSpeaking()
                                                    }) {
                                                        VStack {
                                                            ZStack {
                                                                Image(systemName: "square.fill")
                                                                    .resizable()
                                                                    .frame(width: 65, height: 65)
                                                                    .foregroundStyle(.blue)
                                                                Text("\(Image(systemName: "pencil"))")
                                                                    .font(.system(size: 30))
                                                                    .foregroundStyle(Color(.systemBackground))
                                                            }
                                                            Text("Edit")
                                                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                                .foregroundStyle(.blue)
                                                        }
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                    .padding([.leading, .trailing])
                                                    
                                                    Button(action: {
                                                        showMore.toggle()
                                                        animate.toggle()
                                                    }) {
                                                        VStack {
                                                            ZStack {
                                                                Image(systemName: "square")
                                                                    .resizable()
                                                                    .frame(width: 65, height: 65)
                                                                Text("\(Image(systemName: "chevron.forward"))")
                                                                    .font(.system(size: 30))
                                                                    .rotationEffect(showMore ? .degrees(90) : .degrees(-90))
                                                            }
                                                            Text(showMore ? "Less" : "More")
                                                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                        }
                                                    }
                                                    .foregroundStyle(Color(.systemGray3))
                                                    .buttonStyle(PlainButtonStyle())
                                                    .padding([.leading, .trailing])
                                                } else {
                                                    Button(action: {
                                                        showAllSheets.toggle()
                                                        sheetArray = loadSheetArray()
                                                        unlockButtons = false
                                                    }) {
                                                        VStack {
                                                            ZStack {
                                                                Image(systemName: "square.fill")
                                                                    .resizable()
                                                                    .frame(width: 65, height: 65)
                                                                    .foregroundStyle(.purple)
                                                                Text("\(Image(systemName: "square.grid.2x2"))")
                                                                    .font(.system(size: 30))
                                                                    .foregroundStyle(Color(.systemBackground))
                                                            }
                                                            Text("All Sheets")
                                                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                                .foregroundStyle(.purple)
                                                        }
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                    .padding([.leading, .trailing])
                                                    
                                                    Button(action: {
                                                        showSettings.toggle()
                                                        speechDelegate.stopSpeaking()
                                                    }) {
                                                        VStack {
                                                            ZStack {
                                                                Image(systemName: "square.fill")
                                                                    .resizable()
                                                                    .frame(width: 65, height: 65)
                                                                    .foregroundStyle(.gray)
                                                                Text("\(Image(systemName: "gear"))")
                                                                    .font(.system(size: 30))
                                                                    .foregroundStyle(Color(.systemBackground))
                                                            }
                                                            Text("Settings")
                                                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                                .foregroundStyle(.gray)
                                                        }
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                    .padding([.leading, .trailing])
                                                }
                                            }
                                            if showMore {
                                                HStack {
                                                    Button(action: {
                                                        showAllSheets.toggle()
                                                        sheetArray = loadSheetArray()
                                                        unlockButtons = false
                                                    }) {
                                                        VStack {
                                                            ZStack {
                                                                Image(systemName: "square.fill")
                                                                    .resizable()
                                                                    .frame(width: 65, height: 65)
                                                                    .foregroundStyle(.purple)
                                                                Text("\(Image(systemName: "square.grid.2x2"))")
                                                                    .font(.system(size: 30))
                                                                    .foregroundStyle(Color(.systemBackground))
                                                            }
                                                            Text("All Sheets")
                                                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                                .foregroundStyle(.purple)
                                                        }
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                    .padding([.leading, .trailing])
                                                    
                                                    Button(action: {
                                                        showRemoved.toggle()
                                                        unlockButtons = false
                                                        speechDelegate.stopSpeaking()
                                                    }) {
                                                        VStack {
                                                            ZStack {
                                                                Image(systemName: "square.fill")
                                                                    .resizable()
                                                                    .frame(width: 65, height: 65)
                                                                    .foregroundStyle(.pink)
                                                                Text("\(Image(systemName: "square.slash"))")
                                                                    .font(.system(size: 30))
                                                                    .foregroundStyle(Color(.systemBackground))
                                                                    .symbolRenderingMode(.hierarchical)
                                                            }
                                                            Text("Removed")
                                                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                                .foregroundStyle(.pink)
                                                        }
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                    .padding([.leading, .trailing])
                                                    
                                                    Button(action: {
                                                        showSettings.toggle()
                                                        speechDelegate.stopSpeaking()
                                                    }) {
                                                        VStack {
                                                            ZStack {
                                                                Image(systemName: "square.fill")
                                                                    .resizable()
                                                                    .frame(width: 65, height: 65)
                                                                    .foregroundStyle(.gray)
                                                                Text("\(Image(systemName: "gear"))")
                                                                    .font(.system(size: 30))
                                                                    .foregroundStyle(Color(.systemBackground))
                                                            }
                                                            Text("Settings")
                                                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                                .foregroundStyle(.gray)
                                                        }
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                    .padding([.leading, .trailing])
                                                }
                                            }
                                        }
                                    }
                                }
                            } else { //bottom row o buttons for iPad
                                if editMode { //show the bottom row of buttons for edit mode
                                    HStack {
                                        Button(action: {
                                            if sheetArray.count > 1 {
                                                presentAlert.toggle()
                                            }
                                        }) {
                                            Text("\(Image(systemName: "trash.square.fill"))")
                                                .font(.system(size: horizontalSizeClass == .compact ? 75 : 100))
                                                .foregroundStyle(.red)
                                                .padding()
                                        }
                                        
                                        Button(action: { //saves the array and disables edit mode
                                            if currSheet.gridType == "time" {
                                                currSheet.currGrid = sortSheet(currSheet.currGrid)
                                            }
                                            currSheet.label = currTitleText
                                            var newSheetArray = loadSheetArray()
                                            newSheetArray[currSheetIndex] = currSheet
                                            newSheetArray[currSheetIndex] = autoRemoveSlots(newSheetArray[currSheetIndex])
                                            currSheet = newSheetArray[currSheetIndex]
                                            saveSheetArray(sheetObjects: newSheetArray)
                                            animate.toggle()
                                            manageNotifications()
                                            editMode.toggle()
                                            
                                        }) { //sheetobject isnt equatable rn, this is the desired behavior:
                                            /*
                                             if currSheet == loadSheetArray()[currSheetIndex] {
                                             Image(systemName:"xmark.square.fill")
                                             .resizable()
                                             .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                             .foregroundStyle(.gray)
                                             .padding()
                                             } else { */
                                            Text("\(Image(systemName: "checkmark.square.fill"))")
                                                .font(.system(size: horizontalSizeClass == .compact ? 75 : 100))
                                                .foregroundStyle(.green)
                                                .padding()
                                            //}
                                        }
                                    }
                                } else { //show the non edit mode buttons at the bottom
                                    if lockButtonsOn && !unlockButtons { //but dont show the buttons if lock buttons is on
                                        Button(action: { //problem is in this button
                                            if !canUseBiometrics() && !canUsePassword() {
                                                showCustomPassword = true
                                            } else {
                                                Task {
                                                    unlockButtons = await authenticateWithBiometrics()
                                                    animate.toggle()
                                                }
                                                if unlockButtons {
                                                    Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
                                                        withAnimation(.snappy) {
                                                            unlockButtons = false
                                                        }
                                                    }
                                                }
                                            }
                                        }) {
                                            Text("\(Image(systemName: "lock.square.fill"))")
                                                .font(.system(size: horizontalSizeClass == .compact ? 75 : 100))
                                                .foregroundStyle(.regularMaterial)
                                                .padding()
                                        }
                                        .padding()
                                    } else {
                                        HStack {
                                            
                                            Button(action: {
                                                showCommunication.toggle()
                                                animate.toggle()
                                                unlockButtons = false
                                                //                                                defaults.set(true, forKey: "communicationDefaultMode")
                                                speechDelegate.stopSpeaking()
                                            }) {
                                                VStack {
                                                    ZStack {
                                                        Image(systemName: "square.fill")
                                                            .resizable()
                                                            .frame(width: 75, height: 75)
                                                            .foregroundStyle(.orange)
                                                        Text("\(Image(systemName: "hand.tap"))")
                                                            .font(.system(size: 40))
                                                            .foregroundStyle(Color(.systemBackground))
                                                            .symbolRenderingMode(.hierarchical)
                                                    }
                                                    Text("Board")
                                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                        .foregroundStyle(.orange)
                                                }
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .padding([.leading, .trailing])
                                            
                                            if sheetArray.count > 1 {
                                                Button(action: {
                                                    showRemoved.toggle()
                                                    unlockButtons = false
                                                    speechDelegate.stopSpeaking()
                                                }) {
                                                    VStack {
                                                        ZStack {
                                                            Image(systemName: "square.fill")
                                                                .resizable()
                                                                .frame(width: 75, height: 75)
                                                                .foregroundStyle(.pink)
                                                            Text("\(Image(systemName: "square.slash"))")
                                                                .font(.system(size: 40))
                                                                .foregroundStyle(Color(.systemBackground))
                                                                .symbolRenderingMode(.hierarchical)
                                                        }
                                                        Text("Removed")
                                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                            .foregroundStyle(.pink)
                                                    }
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                .padding([.leading, .trailing])
                                            }
                                            
                                            Button(action: {
                                                showAllSheets.toggle()
                                                sheetArray = loadSheetArray()
                                                unlockButtons = false
                                                speechDelegate.stopSpeaking()
                                            }) {
                                                VStack {
                                                    ZStack {
                                                        Image(systemName: "square.fill")
                                                            .resizable()
                                                            .frame(width: 75, height: 75)
                                                            .foregroundStyle(.purple)
                                                        Text("\(Image(systemName: "square.grid.2x2"))")
                                                            .font(.system(size: 40))
                                                            .foregroundStyle(Color(.systemBackground))
                                                    }
                                                    Text("All Sheets")
                                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                        .foregroundStyle(.purple)
                                                }
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .padding([.leading, .trailing])
                                            
                                            Button(action: {
                                                showSettings.toggle()
                                                speechDelegate.stopSpeaking()
                                            }) {
                                                VStack {
                                                    ZStack {
                                                        Image(systemName: "square.fill")
                                                            .resizable()
                                                            .frame(width: 75, height: 75)
                                                            .foregroundStyle(.gray)
                                                        Text("\(Image(systemName: "gear"))")
                                                            .font(.system(size: 40))
                                                            .foregroundStyle(Color(.systemBackground))
                                                    }
                                                    Text("Settings")
                                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                        .foregroundStyle(.gray)
                                                }
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .padding([.leading, .trailing])
                                            
                                            if sheetArray.count > 1 {
                                                Button(action: {
                                                    editMode.toggle()
                                                    currTitleText = currSheet.label
                                                    animate.toggle()
                                                    unlockButtons = false
                                                    speechDelegate.stopSpeaking()
                                                }) {
                                                    VStack {
                                                        ZStack {
                                                            Image(systemName: "square.fill")
                                                                .resizable()
                                                                .frame(width: 75, height: 75)
                                                                .foregroundStyle(.blue)
                                                            Text("\(Image(systemName: "pencil"))")
                                                                .font(.system(size: 40))
                                                                .foregroundStyle(Color(.systemBackground))
                                                        }
                                                        Text("Edit")
                                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                            .foregroundStyle(.blue)
                                                    }
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                .padding([.leading, .trailing])
                                            }
                                        }
                                    }
                                }
                            }
                            Spacer()
                        }
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color(.systemBackground), Color(.systemBackground),  Color.clear]), startPoint: .bottom, endPoint: .top)
                                .ignoresSafeArea()
                        )
                    }
                    .transition(.move(edge: .top))
                    .opacity(showMod ? 0 : 1)
                    .navigationViewStyle(StackNavigationViewStyle())
                    .navigationBarHidden(true)
                    .sheet(isPresented: $pickIcon) {
                        AllIconsPickerView(currSheet: currSheet,
                                           currImage: currSheet.currLabelIcon ?? "plus.viewfinder",
                                           modifyIcon: { newIcon in
                            withAnimation(.snappy) {
                                currSheet.currLabelIcon = newIcon
                            }
                            Task {
                                do {
                                    customIconPreviews = await getCustomIconPreviews()
                                }
                            }
                            currCommunicationBoard = loadCommunicationBoard()
                        }, modifyCustomIcon: {
                            Task {
                                do {
                                    customIconPreviews = await getCustomIconPreviews()
                                }
                            }
                            currCommunicationBoard = loadCommunicationBoard()
                            currSheet = loadSheetArray()[currSheetIndex]
                        }, modifyDetails: { newDetails in
                            //no need to modify details here
                        }, onDismiss: {
                            Task {
                                do {
                                    customIconPreviews = await getCustomIconPreviews()
                                }
                            }
                            pickIcon.toggle()
                            //save array aka "autosave"
                            var newSheetArray = loadSheetArray()
                            newSheetArray[currSheetIndex] = currSheet
                            currSheet = newSheetArray[currSheetIndex]
                            saveSheetArray(sheetObjects: newSheetArray)
                            currCommunicationBoard = loadCommunicationBoard()
                        }, showCreateCustom: false, customIconPreviews: customIconPreviews)
                    }
                    .sheet(isPresented: $showTime) { //sheet for setting times on a sheet
                        TimeLabelPickerView(viewType: .time, saveItem: { item in
                            if item is Date {
                                currSheet.currGrid[currListIndex].currTime = item as! Date
                                currSheet.currGrid = sortSheet(currSheet.currGrid)
                                var newSheetArray = loadSheetArray()
                                newSheetArray[currSheetIndex] = currSheet
                                saveSheetArray(sheetObjects: newSheetArray)
                                manageNotifications()
                                updateUsage("action:time")
                            }
                        }, oldDate: currSheet.currGrid[currListIndex].currTime, oldLabel: $currText)
                    }
                    .sheet(isPresented: $showLabels) { //sheet for setting a custom label in a sheet
                        TimeLabelPickerView(viewType: .label, saveItem: { item in
                            if item is String {
                                updateUsage("action:label")
                                currSheet.currGrid[currListIndex].currLabel = item as! String
                                var newSheetArray = loadSheetArray()
                                newSheetArray[currSheetIndex] = currSheet
                                saveSheetArray(sheetObjects: newSheetArray)
                            }
                        }, oldLabel: $currText)
                    }
                    .fullScreenCover(isPresented: $showIcons) {
                        AllIconsPickerView(currSheet: currSheet,
                                           currImage: currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currIcon,
                                           modifyIcon: { newIcon in
                            withAnimation() {
                                currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currIcon = newIcon
                            }
                            Task {
                                do {
                                    customIconPreviews = await getCustomIconPreviews()
                                }
                            }
                            currCommunicationBoard = loadCommunicationBoard()
                        }, modifyCustomIcon: {
                            Task {
                                do {
                                    customIconPreviews = await getCustomIconPreviews()
                                }
                            }
                            currCommunicationBoard = loadCommunicationBoard()
                            currSheet = loadSheetArray()[currSheetIndex]
                        }, modifyDetails: { newDetails in
                            currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails = newDetails
                        }, onDismiss: {
                            Task {
                                do {
                                    customIconPreviews = await getCustomIconPreviews()
                                }
                            }
                            showIcons.toggle()
                            //save array aka "autosave"
                            var newSheetArray = loadSheetArray()
                            newSheetArray[currSheetIndex] = currSheet
                            currSheet = newSheetArray[currSheetIndex]
                            saveSheetArray(sheetObjects: newSheetArray)
                            currCommunicationBoard = loadCommunicationBoard()
                        }, customIconPreviews: customIconPreviews)
                    }
                    .fullScreenCover(isPresented: $showSettings) { //fullscreencover for the settings page
                        SettingsView(onDismiss: {
                            //                        lockButtonsOn = defaults.bool(forKey: "buttonsOn")
                            //                        showCurrentSlot = defaults.bool(forKey: "showCurrSlot")
                            //                        speakIcons = defaults.bool(forKey: "speakOn")
                            unlockButtons = false
                            currSheet = autoRemoveSlots(currSheet)
                            if showCurrentSlot {
                                currGreenSlot = loadSheetArray()[currSheetIndex].getCurrSlot()
                                animate.toggle()
                            }
                        })
                    }
                    .onAppear{ //re-check for notification permission when settings opened
                        @State var notificationsAllowed: Bool?
                        if notificationsAllowed != nil {
                            currSessionLog.append("notification status has already been set")
                        } else {
                            defaults.set(true, forKey : "notificationsAllowed")
                        }
                    }
                    .fullScreenCover(isPresented: $showRemoved) { //fullscreencover for removed icons
                        ZStack {
                            ScrollView {
                                HStack(alignment: .top) {
                                    VStack(alignment: horizontalSizeClass == .compact ? .leading : .center) {
                                        Text("\(Image(systemName: "square.slash")) Removed Icons")
                                            .lineLimit(1)
                                        //.minimumScaleFactor(0.01)
                                            .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                            .padding(.top)
                                            .padding(.bottom, horizontalSizeClass == .compact ? 5 : 0)
                                            .symbolRenderingMode(.hierarchical)
                                        HStack {
                                            Text("From") .foregroundStyle(.gray)
                                                .minimumScaleFactor(0.01)
                                                .font(.system(size: horizontalSizeClass == .compact ? 17 : 25, weight: .bold, design: .rounded))
                                                .multilineTextAlignment(horizontalSizeClass == .compact ? .leading : .center)
                                                .padding(.bottom)
                                            Menu {
                                                Button {
                                                    removedSelected = getAllRemoved()
                                                    removedSelectedLabel = "All Sheets"
                                                } label: {
                                                    Label("All Sheets", systemImage: "square.on.square")
                                                }
                                                
                                                Button {
                                                    removedSelected = getAllRemoved()
                                                    currSheet = loadSheetArray()[currSheetIndex]
                                                    
                                                    removedSelected = currSheet.removedIcons
                                                    removedSelectedLabel = "This Sheet"
                                                } label: {
                                                    Label("This Sheet", systemImage: "square")
                                                }
                                            } label: {
                                                Text("\(removedSelectedLabel)\(Image(systemName: "chevron.up.chevron.down"))").foregroundStyle(.purple)
                                                    .font(.system(size: horizontalSizeClass == .compact ? 17 : 25, weight: .bold, design: .rounded))
                                                    .multilineTextAlignment(horizontalSizeClass == .compact ? .leading : .center)
                                                    .padding(.bottom)
                                            }
                                        }
                                    }
                                    .padding(.leading, horizontalSizeClass == .compact ? 20 : 0)
                                    if horizontalSizeClass == .compact {
                                        Spacer()
                                        Button(action: {
                                            showRemoved.toggle()
                                        }) {
                                            Text("\(Image(systemName: "xmark.circle.fill"))")
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.5)
                                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                                .foregroundStyle(Color(.systemGray3))
                                                .padding(.trailing)
                                        }
                                    }
                                }
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 100 : 150))], spacing: horizontalSizeClass == .compact ? 0 : 20) {
                                    ForEach(0..<removedSelected.count, id: \.self) { index in
                                        ZStack {
                                            if UIImage(named: removedSelected[index].currIcon) == nil {
                                                Image(uiImage: customIconPreviews[removedSelected[index].currIcon] ?? UIImage(systemName: "square.fill")!)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .stroke(.black, lineWidth: 3)
                                                    )
                                            } else {
                                                Image(removedSelected[index].currIcon)
                                                    .resizable()
                                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .stroke(.black, lineWidth: 3)
                                                    )
                                                    .scaledToFit()
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .padding(.bottom, 150)
                                Spacer()
                                if removedSelected.count == 0 {
                                    Text("You don't have any removed icons yet. Once you remove an icon from \(removedSelectedLabel == "All Sheets" ? "any Sheet" : (currSheet.label.isEmpty ? "the current sheet" : currSheet.label)), it will appear here.")
                                        .minimumScaleFactor(0.01)
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .bold, design: .rounded))
                                        .foregroundStyle(.gray)
                                        .padding()
                                        .padding()
                                    Spacer()
                                }
                            }
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    if horizontalSizeClass != .compact {
                                        Button(action: {
                                            showRemoved.toggle()
                                        }) {
                                            Image(systemName:"xmark.square.fill")
                                                .resizable()
                                                .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                                .foregroundStyle(.gray)
                                            
                                                .padding()
                                        }
                                    }
                                    Spacer()
                                }
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color(.systemBackground), Color(.systemBackground),  Color.clear]), startPoint: .bottom, endPoint: .top)
                                        .ignoresSafeArea()
                                )
                            }
                        }
                        .animation(.snappy, value: sheetAnimate)
                        .onChange(of: removedSelectedLabel, perform: { _ in
                            sheetAnimate.toggle()
                        })
                    }
                    
                    
                    .fullScreenCover(isPresented: $showAllSheets) { //fullscreencover that shows all the sheets created
                        ZStack {
                            if createNewSheet {
                                VStack {
                                    if !isTextFieldActive {
                                        HStack(alignment: .top) {
                                            if #available(iOS 16.0, *) {
                                                Text(newSheetSelection == 0 ? "\(Image(systemName: "timer")) Timeslot Sheet" : "\(Image(systemName: "tag")) Custom Labels Sheet")
                                                    .lineLimit(1)
                                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                                    .padding(.top)
                                                    .padding(.bottom, horizontalSizeClass == .compact ? 5 : 0)
                                                    .padding(.leading, horizontalSizeClass == .compact ? 20 : 0)
                                                    .animation(.snappy, value: newSheetSelection)
                                                    .contentTransition(.numericText(countsDown: true))
                                            } else {
                                                Text(newSheetSelection == 0 ? "\(Image(systemName: "timer")) Timeslot Sheet" : "\(Image(systemName: "tag")) Custom Labels Sheet")
                                                    .lineLimit(1)
                                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                                    .padding(.top)
                                                    .padding(.bottom, horizontalSizeClass == .compact ? 5 : 0)
                                                    .padding(.leading, horizontalSizeClass == .compact ? 20 : 0)
                                            }
                                            if horizontalSizeClass == .compact {
                                                Spacer()
                                                Spacer()
                                                Button(action: {
                                                    withAnimation(.snappy) {
                                                        createNewSheet.toggle()
                                                    }
                                                    if sheetArray.count < 2 {
                                                        showAllSheets.toggle()
                                                    }
                                                }) {
                                                    Text("\(Image(systemName: "xmark.circle.fill"))")
                                                        .lineLimit(1)
                                                        .minimumScaleFactor(0.5)
                                                        .font(.system(size: 30, weight: .bold, design: .rounded))
                                                        .foregroundStyle(Color(.systemGray3))
                                                        .padding([.top, .trailing])
                                                }
                                            }
                                        }
                                    }
                                    TextField("Name Sheet", text: $currSheetText, onEditingChanged: { editing in
                                        withAnimation(.snappy) {
                                            isTextFieldActive = editing
                                        }
                                    }, onCommit: {
                                    })
                                    .font(.system(size: horizontalSizeClass == .compact ? 40 : 65, weight: .bold, design: .rounded))
                                    .padding()
                                    .background(
                                        Color(.systemGray6),
                                        in: RoundedRectangle(cornerRadius: 20)
                                    )
                                    .minimumScaleFactor(0.01)
                                    .padding([.leading, .trailing])
                                    if !isTextFieldActive { //just to handle the content getting pushed off screen by the keybpoard on smaller devices
                                        Spacer()
                                        HStack {
                                            Button(action: {
                                                withAnimation(.snappy) {
                                                    newSheetSelection = 0
                                                }
                                            }) {
                                                VStack {
                                                    Image(systemName: "timer")
                                                        .resizable()
                                                        .foregroundStyle(newSheetSelection == 0 ? .white : .purple)
                                                        .scaledToFit()
                                                        .padding(horizontalSizeClass == .compact ? 15 : 30)
                                                        .foregroundStyle(.white)
                                                        .background(newSheetSelection == 0 ? .purple : Color(.systemGray6))
                                                        .cornerRadius(horizontalSizeClass == .compact ? 40 : 65)
                                                        .changeEffect(
                                                            .spray(origin: UnitPoint(x: 0.5, y: 0.1)) {
                                                                Image(systemName: "timer")
                                                                    .foregroundStyle(newSheetSelection == 0 ? .purple : .clear)
                                                            }, value: newSheetSelection)
                                                    Text("Timeslots")
                                                        .lineLimit(1)
                                                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                                        .foregroundStyle(newSheetSelection == 0 ? .primary : Color(.systemGray2))
                                                }
                                            }
                                            .padding(horizontalSizeClass == .compact ? 0 : 10)
                                            .padding(.bottom)
                                            
                                            Button(action: {
                                                withAnimation(.snappy) {
                                                    newSheetSelection = 1
                                                }
                                            }) {
                                                VStack {
                                                    Image(systemName: "tag")
                                                        .resizable()
                                                        .foregroundStyle(newSheetSelection == 1 ? .white : .purple)
                                                        .scaledToFit()
                                                        .padding(horizontalSizeClass == .compact ? 15 : 30)
                                                        .foregroundStyle(.white)
                                                        .background(newSheetSelection == 1 ? .purple : Color(.systemGray6))
                                                        .cornerRadius(horizontalSizeClass == .compact ? 40 : 65)
                                                        .changeEffect(
                                                            .spray(origin: UnitPoint(x: 0.5, y: 0.1)) {
                                                                Image(systemName: "tag")
                                                                    .foregroundStyle(newSheetSelection == 1 ? .purple : .clear)
                                                            }, value: newSheetSelection)
                                                    Text("Custom Labels")
                                                        .lineLimit(1)
                                                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                                        .foregroundStyle(newSheetSelection == 1 ? .primary : Color(.systemGray2))
                                                }
                                            }
                                            .padding(horizontalSizeClass == .compact ? 0 : 10)
                                            .padding(.bottom)
                                        }
                                        Spacer()
                                        HStack {
                                            if horizontalSizeClass != .compact {
                                                Button(action: {
                                                    withAnimation(.snappy) {
                                                        createNewSheet.toggle()
                                                    }
                                                    showAllSheets.toggle()
                                                    Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { timer in
                                                        self.presentation.wrappedValue.dismiss()
                                                    }
                                                }) {
                                                    Text("\(Image(systemName: "arrow.backward")) Back")
                                                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                                        .lineLimit(1)
                                                        .padding([.top, .bottom, .trailing], horizontalSizeClass == .compact ? 5 : 10)
                                                        .padding()
                                                        .background(Color(.systemGray6))
                                                        .cornerRadius(horizontalSizeClass == .compact ? 20 : 25)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                            Button(action: {
                                                sheetAnimate.toggle()
                                                editMode.toggle()
                                                withAnimation(.snappy) {
                                                    createNewSheet.toggle()
                                                }
                                                showAllSheets.toggle()
                                                
                                                defaults.set(true, forKey: "completedTutorial")
                                                newSheet(gridType: newSheetSelection == 0 ? "time" : "label", label: currSheetText)
                                                currTitleText = currSheetText
                                                currSheetIndex = loadSheetArray().count - 1
                                                sheetArray = loadSheetArray()
                                                currSheetText = ""
                                                currSheet = loadSheetArray()[currSheetIndex]
                                                updateUsage("action:create")
                                                currSessionLog.append(newSheetSelection == 0 ? "time" : "label")
                                            }) {
                                                Text("Next \(Image(systemName: "arrow.forward"))")
                                                    .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                                    .lineLimit(1)
                                                    .padding([.top, .bottom, .trailing], horizontalSizeClass == .compact ? 5 : 10)
                                                    .padding()
                                                    .background(Color(.systemGray6))
                                                    .cornerRadius(horizontalSizeClass == .compact ? 20 : 25)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .changeEffect(
                                                .wiggle(rate: .fast), value: newSheetSelection)
                                        }
                                        .padding()
                                    }
                                }
                                .transition(.movingParts.move(angle: .degrees(270)).combined(with: .opacity))
                            } else {
                                ScrollView {
                                    HStack(alignment: .top) {
                                        VStack(alignment: horizontalSizeClass == .compact ? .leading : .center) {
                                            Text("\(Image(systemName: "square.grid.2x2")) All Sheets")
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.01)
                                                .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                                .padding(.top)
                                                .padding(.bottom, horizontalSizeClass == .compact ? 5 : 0)
                                            Text("You have \(loadSheetArray().count - 1) Sheets. \(Image(systemName: "timer").resizable()) indicates Timeslots, and \(Image(systemName: "tag").resizable()) indicates Custom Labels.")
                                                .minimumScaleFactor(0.01)
                                                .font(.system(size: horizontalSizeClass == .compact ? 17 : 25, weight: .bold, design: .rounded))
                                                .foregroundStyle(.gray)
                                                .multilineTextAlignment(horizontalSizeClass == .compact ? .leading : .center)
                                                .padding(.bottom)
                                        }
                                        .padding(.leading, horizontalSizeClass == .compact ? 20 : 0)
                                        if horizontalSizeClass == .compact {
                                            Spacer()
                                            Button(action: {
                                                showAllSheets.toggle()
                                            }) {
                                                Text("\(Image(systemName: "xmark.circle.fill"))")
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.5)
                                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                                    .foregroundStyle(Color(.systemGray3))
                                                    .padding([.top, .trailing])
                                            }
                                        }
                                    }
                                    if sheetArray.count < 2 {
                                        Spacer()
                                        Spacer()
                                        Text("Hm, this feels a bit empty! You don't have any Sheets yet, create a new one below.")
                                            .minimumScaleFactor(0.01)
                                            .multilineTextAlignment(.center)
                                            .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .bold, design: .rounded))
                                            .foregroundStyle(.purple)
                                            .padding()
                                            .padding()
                                        Spacer()
                                    } else {
                                        LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 100 : 175))], spacing: horizontalSizeClass == .compact ? 5 : 10) {
                                            ForEach(0..<sheetArray.count, id: \.self) { sheet in
                                                if sheetArray[sheet].label != "Debug, ignore this page" {
                                                    Button(action: {
                                                        currSheetIndex = sheet
                                                        currSheet = loadSheetArray()[currSheetIndex]
                                                        showAllSheets.toggle()
                                                        if showCurrentSlot {
                                                            currGreenSlot = loadSheetArray()[currSheetIndex].getCurrSlot()
                                                            animate.toggle()
                                                        }
                                                    }) {
                                                        ZStack {
                                                            Image(systemName: "square.fill")
                                                                .resizable()
                                                                .foregroundStyle(Color(.systemGray5))
                                                            //.frame(width: horizontalSizeClass == .compact ? 125 : 200, height: horizontalSizeClass == .compact ? 125 : 200) this causes it to look strange on smaller iPads, not comapct screens but small enough to cause itemt to run un
                                                                .scaledToFit()
                                                            Image(systemName: "square.fill")
                                                                .resizable()
                                                                .foregroundStyle(currSheetIndex == sheet ? .purple : Color(.systemGray5))
                                                                .scaledToFit()
                                                                .opacity(0.5)
                                                            VStack {
                                                                
                                                                //check to see if there is a curc LabelIcon
                                                                //if sheetArray[sheet].currLabelIcon.isEmpty {
                                                                if sheetArray[sheet].currLabelIcon != nil && sheetArray[sheet].currLabelIcon != "" {
                                                                    if UIImage(named: sheetArray[sheet].currLabelIcon!) == nil {
                                                                        Image(uiImage: customIconPreviews[sheetArray[sheet].currLabelIcon!] ?? UIImage(systemName: "square.fill")!)
                                                                            .resizable()
                                                                            .resizable()
                                                                            .frame(width: horizontalSizeClass == .compact ? 65: 105, height: horizontalSizeClass == .compact ? 65: 105)
                                                                            .clipShape(RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 10 : 20))
                                                                            .overlay(
                                                                                RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 10 : 20)
                                                                                    .stroke(.black, lineWidth: horizontalSizeClass == .compact ? 1 : 3)
                                                                            )
                                                                            .padding(.top)
                                                                    } else if !sheetArray[sheet].currLabelIcon!.isEmpty && sheetArray[sheet].currLabelIcon! != "plus.viewfinder" {
                                                                        Image(sheetArray[sheet].currLabelIcon!)
                                                                            .scaledToFit()
                                                                            .frame(width: horizontalSizeClass == .compact ? 65: 105, height: horizontalSizeClass == .compact ? 65: 105)
                                                                            .scaleEffect(horizontalSizeClass == .compact ? 0.17 : 0.25)
                                                                            .clipShape(RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 10 : 20))
                                                                            .overlay(
                                                                                RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 10 : 20)
                                                                                    .stroke(.black, lineWidth: horizontalSizeClass == .compact ? 1 : 3)
                                                                            )
                                                                            .padding(.top)
                                                                    } else {
                                                                        if sheetArray[sheet].gridType == "time" {
                                                                            Image(systemName: "timer")
                                                                                .resizable()
                                                                                .frame(width: horizontalSizeClass == .compact ? 65: 105, height: horizontalSizeClass == .compact ? 65: 105)
                                                                                .foregroundStyle(.gray)
                                                                                .padding(.top, sheetArray[sheet].label.isEmpty ? 0 : 15)
                                                                        } else {
                                                                            Image(systemName: "tag")
                                                                                .resizable()
                                                                                .frame(width: horizontalSizeClass == .compact ? 65: 105, height: horizontalSizeClass == .compact ? 65: 105)
                                                                                .foregroundStyle(.gray)
                                                                                .padding(.top, sheetArray[sheet].label.isEmpty ? 0 : 15)
                                                                        }
                                                                    }
                                                                } else {
                                                                    if sheetArray[sheet].gridType == "time" {
                                                                        Image(systemName: "timer")
                                                                            .resizable()
                                                                            .frame(width: horizontalSizeClass == .compact ? 65: 105, height: horizontalSizeClass == .compact ? 65: 105)
                                                                            .foregroundStyle(.gray)
                                                                            .padding(.top, sheetArray[sheet].label.isEmpty ? 0 : 15)
                                                                    } else {
                                                                        Image(systemName: "tag")
                                                                            .resizable()
                                                                            .frame(width: horizontalSizeClass == .compact ? 65: 105, height: horizontalSizeClass == .compact ? 65: 105)
                                                                            .foregroundStyle(.gray)
                                                                            .padding(.top, sheetArray[sheet].label.isEmpty ? 0 : 15)
                                                                    }
                                                                }
                                                                //                                                if sheetArray[sheet].label.isEmpty {
                                                                //                                                    if sheetArray[sheet].currLabelIcon != nil && sheetArray[sheet].currLabelIcon != "plus.viewfinder" {
                                                                //                                                        if !sheetArray[sheet].currLabelIcon!.isEmpty && sheetArray[sheet].currLabelIcon! != "plus.viewfinder" {
                                                                //                                                            Spacer()
                                                                //                                                        }
                                                                //                                                    } else {
                                                                //                                                        Spacer()
                                                                //                                                    }
                                                                //                                                }
                                                                if !sheetArray[sheet].label.isEmpty {
                                                                    HStack {
                                                                        if sheetArray[sheet].currLabelIcon != nil && sheetArray[sheet].currLabelIcon != "plus.viewfinder" {
                                                                            if !sheetArray[sheet].currLabelIcon!.isEmpty && sheetArray[sheet].currLabelIcon! != "plus.viewfinder" {
                                                                                Text("\(Image(systemName: sheetArray[sheet].gridType == "time" ? "timer" : "tag" )) \(sheetArray[sheet].label)")
                                                                                    .lineLimit(1)
                                                                                    .font(.system(size: horizontalSizeClass == .compact ? 17 : 30, weight: .semibold, design: .rounded))
                                                                                    .foregroundStyle(.primary)
                                                                                    .padding(.bottom)
                                                                                    .padding(.leading, 2)
                                                                                    .padding(.trailing, 2)
                                                                            } else {
                                                                                Text(sheetArray[sheet].label)
                                                                                    .lineLimit(1)
                                                                                    .font(.system(size: horizontalSizeClass == .compact ? 17 : 30, weight: .semibold, design: .rounded))
                                                                                    .foregroundStyle(.primary)
                                                                                    .padding(.bottom)
                                                                            }
                                                                        } else {
                                                                            Text(sheetArray[sheet].label)
                                                                                .lineLimit(1)
                                                                                .font(.system(size: horizontalSizeClass == .compact ? 17 : 30, weight: .semibold, design: .rounded))
                                                                                .foregroundStyle(.primary)
                                                                                .padding(.bottom)
                                                                                .padding(.leading, 2)
                                                                                .padding(.trailing, 2)
                                                                        }
                                                                    }
                                                                    .padding(.leading, 2)
                                                                    .padding(.trailing, 2)
                                                                } else {
                                                                    if sheetArray[sheet].currLabelIcon != nil && sheetArray[sheet].currLabelIcon != "plus.viewfinder" {
                                                                        if !sheetArray[sheet].currLabelIcon!.isEmpty && sheetArray[sheet].currLabelIcon! != "plus.viewfinder" {
                                                                            Text("\(Image(systemName: sheetArray[sheet].gridType == "time" ? "timer" : "tag" ))")
                                                                                .lineLimit(1)
                                                                                .font(.system(size: horizontalSizeClass == .compact ? 17 : 30, weight: .semibold, design: .rounded))
                                                                                .foregroundStyle(.primary)
                                                                                .padding(.bottom)
                                                                                .padding(.leading, 2)
                                                                                .padding(.trailing, 2)
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        .contextMenu {
                                                            Button {
                                                                renameSheet.toggle()
                                                                currSheetIndex = sheet
                                                                currSheetText = sheetArray[sheet].label
                                                            } label: {
                                                                Label("Rename Sheet", systemImage: "pencil")
                                                            }
                                                            
                                                            Button {
                                                                currSheetIndex = sheet
                                                                addSheetIcon.toggle()
                                                            } label: {
                                                                if sheetArray[sheet].currLabelIcon != nil && sheetArray[sheet].currLabelIcon != "plus.viewfinder" {
                                                                    Label(sheetArray[sheet].currLabelIcon!.isEmpty || sheetArray[sheet].currLabelIcon! == "plus.viewfinder" ? "Add Icon" : "Change Icon", systemImage: sheetArray[sheet].currLabelIcon!.isEmpty ? "plus.square.dashed" : "arrow.2.squarepath")
                                                                } else {
                                                                    Label("Add Icon", systemImage: "plus.viewfinder")
                                                                }
                                                            }
                                                            
                                                            Divider()
                                                            Button(role: .destructive) {
                                                                currSheetIndex = sheet
                                                                currSheet = loadSheetArray()[currSheetIndex]
                                                                showAllSheets.toggle()
                                                                
                                                                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                                                    if sheetArray.count > 1 {
                                                                        presentAlert.toggle()
                                                                    }
                                                                }
                                                            } label: {
                                                                Label("Delete this Sheet", systemImage: "trash")
                                                            }
                                                        }
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                }
                                            }
                                        }
                                        .padding()
                                        .padding(.bottom, 150)
                                    }
                                }
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        HStack {
                                            if horizontalSizeClass != .compact {
                                                Button(action: {
                                                    showAllSheets.toggle()
                                                }) {
                                                    Image(systemName:"xmark.square.fill")
                                                        .resizable()
                                                        .frame(width:100, height: 100)
                                                    
                                                        .foregroundStyle(.gray)
                                                        .padding()
                                                }
                                            }
                                            Button(action: {
                                                withAnimation(.snappy) {
                                                    createNewSheet.toggle()
                                                }
                                            }) {
                                                Image(systemName: "plus.square.fill.on.square.fill")
                                                    .resizable()
                                                    .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                                
                                                    .foregroundStyle(.green)
                                                    .padding()
                                            }
                                        }
                                        Spacer()
                                    }
                                    .background(
                                        LinearGradient(gradient: Gradient(colors: [Color(.systemBackground), Color(.systemBackground),  Color.clear]), startPoint: .bottom, endPoint: .top)
                                            .ignoresSafeArea()
                                    )
                                }
                            }
                        }
                        .sheet(isPresented: $renameSheet) {
                            TimeLabelPickerView(viewType: .label, saveItem: { item in
                                if item is String {
                                    sheetArray[currSheetIndex].label = item as! String
                                    saveSheetArray(sheetObjects: sheetArray)
                                    renameSheet.toggle()
                                    if currSheetIndex == currSheetIndex {
                                        currSheet.label = item as! String
                                    }
                                    currSheetText = ""
                                }
                            }, oldLabel: $currSheetText)
                        }
                        .sheet(isPresented: $addSheetIcon) {
                            AllIconsPickerView(currSheet: currSheet,
                                               currImage: sheetArray[currSheetIndex].currLabelIcon ?? "",
                                               modifyIcon: { newIcon in
                                withAnimation(.snappy) {
                                    sheetArray[currSheetIndex].currLabelIcon = newIcon
                                }
                                Task {
                                    do {
                                        customIconPreviews = await getCustomIconPreviews()
                                    }
                                }
                                currCommunicationBoard = loadCommunicationBoard()
                            }, modifyCustomIcon: {
                                Task {
                                    do {
                                        customIconPreviews = await getCustomIconPreviews()
                                    }
                                }
                                currCommunicationBoard = loadCommunicationBoard()
                                currSheet = loadSheetArray()[currSheetIndex]
                            }, modifyDetails: { newDetails in
                                //no need to modify details here
                            }, onDismiss: {
                                Task {
                                    do {
                                        customIconPreviews = await getCustomIconPreviews()
                                    }
                                }
                                    addSheetIcon.toggle()
                                //save array aka "autosave"
                                var newSheetArray = loadSheetArray()
                                newSheetArray[currSheetIndex] = sheetArray[currSheetIndex]
                                currSheet = newSheetArray[currSheetIndex]
                                saveSheetArray(sheetObjects: newSheetArray)
                                currCommunicationBoard = loadCommunicationBoard()
                            }, showCreateCustom: false, customIconPreviews: customIconPreviews)
                            .transition(.movingParts.move(angle: .degrees(270)).combined(with: .opacity))
                        }
                    }
                }
                .navigationBarHidden(true)
                .sheet(isPresented: $showCustomPassword) { //set and/or verify custom password if bioauth and password not set
                    CustomPasswordView(dismissSheet: { result in
                        withAnimation(.snappy) {
                            unlockButtons = result
                        }
                        showCustomPassword = false
                    })
                }
                .animation(.snappy, value: true)
                .navigationBarHidden(true)
                .alert(isPresented: $presentAlert) { //this is the alert to confirm deleting an entire sheet
                    Alert(
                        title: Text(currSheet.label.isEmpty ? "Delete this Sheet?" : "Delete \(currSheet.label)?"),
                        message: Text("This cannot be undone."),
                        primaryButton: .destructive(Text("Delete \(currSheet.label)")) {
                            showMore = false
                            editMode = false
                            removeSheet(sheetIndex: currSheetIndex)
                            currSheet = SheetObject()
                            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                withAnimation(.snappy) {
                                    currSheetIndex = loadSheetArray().count - 1
                                    currSheet = loadSheetArray()[currSheetIndex]
                                }
                            }
                            sheetArray = loadSheetArray()
                            currTitleText = currSheet.label
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            if showMod {
                VStack {
                    if editMode {
                        Text("\(Image(systemName: "plus.square.on.square")) Add Details")
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                            .padding(.top)
                    } else {
                        Spacer()
                    }
                    
                    ModImageView(currSheet: $currSheet, modListIndex: $currListIndex, modSlotIndex: $currSlotIndex, hasDetails: tempDetails.isEmpty)
                        .matchedGeometryEffect(id: "\(currListIndex)\(currSlotIndex)", in: animation)
                    
                    
                    if editMode {
                        
                        Divider()
                            .padding()
                        
                        ZStack {
                            HStack {
                                ForEach(0..<tempDetails.count, id: \.self) { detail in
                                    Button(action: {
                                        detailIconIndex = detail
                                        searchText = ""
                                        showDetailsIcons.toggle()
                                    }) {
                                        //loadImage() or getCustomIcon() depending
                                        if UIImage(named: tempDetails[detail]) == nil {
                                            if horizontalSizeClass == .compact {
                                                Image(uiImage: customIconPreviews[tempDetails[detail]] ?? UIImage(systemName: "square.fill")!)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 15)
                                                            .stroke(.black, lineWidth: 6)
                                                    )
                                                    .padding(3)
                                            } else {
                                                Image(uiImage: customIconPreviews[tempDetails[detail]] ?? UIImage(systemName: "square.fill")!)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 15)
                                                            .stroke(.black, lineWidth: 10)
                                                    )
                                                    .padding(7)
                                            }
                                        } else {
                                            Image(tempDetails[detail])
                                                .resizable()
                                                .scaledToFit()
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(.black, lineWidth: (horizontalSizeClass == .compact ? 6 : 10))
                                                )
                                                .padding(horizontalSizeClass == .compact ? 3 : 7)
                                        }
                                    }
                                }
                                if tempDetails.count < (horizontalSizeClass == .compact ? 3 : 5) {
                                    Button(action: {
                                        detailIconIndex = -1
                                        searchText = ""
                                        showDetailsIcons.toggle()
                                    }) {
                                        Image(systemName: "plus.viewfinder")
                                            .resizable()
                                            .scaledToFit()
                                            .symbolRenderingMode(.hierarchical)
                                            .foregroundStyle(.gray)
                                            .padding()
                                    }
                                }
                            }
                        }
                        .sheet(isPresented: $showDetailsIcons) {
                            
                            AllIconsPickerView(currSheet: currSheet,
                                               currImage: detailIconIndex != -1 ? tempDetails[detailIconIndex] : "plus.viewfinder",
                                               modifyIcon: { newIcon in
                                withAnimation(.snappy) {
                                    if detailIconIndex != -1 {
                                        tempDetails[detailIconIndex] = newIcon
                                    } else {
                                        tempDetails.append(newIcon)
                                    }
                                    currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails = tempDetails
                                }
                                Task {
                                    do {
                                        customIconPreviews = await getCustomIconPreviews()
                                    }
                                }
                                currCommunicationBoard = loadCommunicationBoard()
                            }, modifyCustomIcon: {
                                Task {
                                    do {
                                        customIconPreviews = await getCustomIconPreviews()
                                    }
                                }
                                currCommunicationBoard = loadCommunicationBoard()
                                currSheet = loadSheetArray()[currSheetIndex]
                            }, modifyDetails: { newDetails in
                                //no need to modify details here
                            }, onDismiss: {
                                Task {
                                    do {
                                        customIconPreviews = await getCustomIconPreviews()
                                    }
                                }
                                showDetailsIcons.toggle()
                                //autosave
                                var newArray = loadSheetArray()
                                newArray[currSheetIndex] = autoRemoveSlots(currSheet)
                                currSheet = newArray[currSheetIndex]
                                saveSheetArray(sheetObjects: newArray)
                                currCommunicationBoard = loadCommunicationBoard()
                            }, showCreateCustom: false, customIconPreviews: customIconPreviews)
                            
                        }
                    } else {
                        if !tempDetails.isEmpty {
                            Divider()
                                .padding()
                        }
                        HStack {
                            ForEach(0..<tempDetails.count, id: \.self) { detail in
                                if lockButtonsOn && !unlockButtons {
                                    if UIImage(named: tempDetails[detail]) == nil {
                                        Image(uiImage: customIconPreviews[tempDetails[detail]] ?? UIImage(systemName: "square.fill")!)
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 15))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .stroke(.black, lineWidth: 10)
                                            )
                                            .padding()
                                    } else {
                                        Image(uiImage: customIconPreviews[tempDetails[detail]] ?? UIImage(systemName: "square.fill")!)
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 15))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .stroke(.black, lineWidth: horizontalSizeClass == .compact ? 6 : 10)
                                            )
                                            .padding()
                                    }
                                } else {
                                    Menu {
                                        Button(role: .destructive) {
                                            tempDetails.remove(at: detail)
                                            currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails = tempDetails
                                            var newArray = loadSheetArray()
                                            newArray[currSheetIndex] = currSheet
                                            newArray[currSheetIndex] = autoRemoveSlots(newArray[currSheetIndex])
                                            currSheet = newArray[currSheetIndex]
                                            saveSheetArray(sheetObjects: newArray)
                                            animate.toggle()
                                        } label: {
                                            Label("Delete from Details", systemImage: "trash")
                                        }
                                    } label: {
                                        //loadImage() or getCustomIcon() depending
                                        if UIImage(named: tempDetails[detail]) == nil {
                                            Image(uiImage: customIconPreviews[tempDetails[detail]] ?? UIImage(systemName: "square.fill")!)
                                                .resizable()
                                                .scaledToFit()
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(.black, lineWidth: 6)
                                                )
                                        } else {
                                            Image(tempDetails[detail])
                                                .resizable()
                                                .scaledToFit()
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(.black, lineWidth: horizontalSizeClass == .compact ? 6 : 10)
                                                )
                                        }
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                    
                    HStack(alignment: .top) {
                        if !editMode {
                            Button(action: {
                                withAnimation(.snappy) {
                                    showMod.toggle()
                                    unlockButtons = false
                                }
                                currListIndex = 0
                                currSlotIndex = 0
                            }) {
                                VStack {
                                    Image(systemName:"xmark.square.fill")
                                        .resizable()
                                        .frame(width: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500), height: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500))
                                    
                                    Text("Cancel")
                                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 25, weight: .semibold, design: .rounded))
                                }
                            }
                            .padding()
                            .foregroundStyle(.gray)
                            if lockButtonsOn && !unlockButtons {
                                Button(action: {
                                    if !canUseBiometrics() && !canUsePassword() {
                                        animate.toggle()
                                        showCustomPassword = true
                                        showMod = false
                                    } else {
                                        Task {
                                            unlockButtons = await authenticateWithBiometrics()
                                            animate.toggle()
                                        }
                                        if unlockButtons {
                                            Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
                                                withAnimation(.snappy) {
                                                    unlockButtons = false
                                                }
                                            }
                                        }
                                    }
                                }) {
                                    VStack {
                                        Image(systemName: "lock.square")
                                            .resizable()
                                            .frame(width: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500), height: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500))
                                        Text("Buttons Locked")
                                            .font(.system(size: horizontalSizeClass == .compact ? 15 : 25, weight: .semibold, design: .rounded))
                                    }
                                }
                                .padding()
                                .foregroundStyle(.gray)
                            } else {
                                Button(action: {
                                    if showMod {
                                        withAnimation(.snappy) {
                                            showMod.toggle()
                                            unlockButtons = false
                                        }
                                        updateUsage(currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currIcon)
                                        currSheet.removedIcons.append(currSheet.currGrid[currListIndex].currIcons[currSlotIndex])
                                        currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currIcon = ""
                                        currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails = []
                                        var newArray = loadSheetArray()
                                        newArray[currSheetIndex] = currSheet
                                        newArray[currSheetIndex] = autoRemoveSlots(newArray[currSheetIndex])
                                        currSheet = newArray[currSheetIndex]
                                        saveSheetArray(sheetObjects: newArray)
                                        animate.toggle()
                                        if removedSelectedLabel == "All Sheets" {
                                            removedSelected = getAllRemoved()
                                        } else {
                                            removedSelected = getAllRemoved()
                                            currSheet = loadSheetArray()[currSheetIndex]
                                            
                                            removedSelected = currSheet.removedIcons
                                        }
                                        hapticFeedback(type: 1)
                                        currListIndex = 0
                                        currSlotIndex = 0
                                    }
                                }) {
                                    VStack {
                                        ZStack {
                                            Image(systemName: "square.fill")
                                                .resizable()
                                                .frame(width: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500), height: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500))
                                            Image(systemName: "square.slash")
                                                .resizable()
                                                .frame(width: horizontalSizeClass == .compact ? min(75, 125) : min(100, 250), height: horizontalSizeClass == .compact ? min(75, 125) : min(100, 250))
                                                .foregroundStyle(Color(.systemBackground))
                                                .symbolRenderingMode(.hierarchical)
                                        }
                                        Text(tempDetails.isEmpty ? "Remove Icon" : "Remove All")
                                            .font(.system(size: horizontalSizeClass == .compact ? 15 : 25, weight: .semibold, design: .rounded))
                                    }
                                }
                                .padding()
                                .foregroundStyle(.pink)
                            }
                        } else {
                            Button(action: {
                                withAnimation(.snappy) {
                                    showMod.toggle()
                                    unlockButtons = false
                                }
                                checkDetails = []
                            }) {
                                if checkDetails == currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails ?? [] {
                                    Image(systemName:"xmark.square.fill")
                                        .resizable()
                                        .frame(width: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500), height: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500))
                                        .foregroundStyle(.gray)
                                } else {
                                    Image(systemName:"checkmark.square.fill")
                                        .resizable()
                                        .frame(width: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500), height: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500))
                                        .foregroundStyle(.green)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
        }
        .animation(.snappy, value: animate)
        .task {
            customIconPreviews = await getCustomIconPreviews()
            animate.toggle()
        }
        .onAppear {
            if (countItemsInDocuments() >= 3 || loadSheetArray().count >= 3) && !defaults.bool(forKey: "askedReview") {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: windowScene)
                    defaults.setValue(true, forKey: "askedReview")
                }
            }
        }
        .onDisappear {
            cleanUp()
        }
    }
    private func cleanUp() {
        // Reset states
        editMode = false
        showIcons = false
        showTime = false
        showLabels = false
        showMod = false
        showSettings = false
        showRemoved = false
        removedSelected = []
        removedSelectedLabel = "All Sheets"
        showAllSheets = false
        animate = false
        unlockButtons = false
        currGreenSlot = 0
        renameSheet = false
        currListIndex = 0
        currSlotIndex = 0
        pickIcon = false
        addSheetIcon = false
        showDetailsIcons = false
        tempDetails = []
        checkDetails = []
        detailIconIndex = -1
        showMore = false
        isTextFieldActive = false
        isTitleTextFieldActive = false
        customIconPreviews = [:]
        showCustomPassword = false
        currText = ""
        currTitleText = ""
        searchText = ""
        selectedDate = Date()
        newSheetSelection = 0
        createNewSheet = false
        sheetArray = []
        sheetAnimate = false
        currSheetText = ""
        presentAlert = false
        deleteAnimationFix = false
        suggestedWords = []
        currCommunicationBoard = []
        
        // Additional cleanup if necessary
        // For example, saving state, removing temporary files, etc.
    }
}
//#Preview {
//    ContentView()
//}
