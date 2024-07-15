//
//  CreateIconView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 5/31/24.
//

import SwiftUI
import OpenAI
import Pow

struct CreateIconView: View {
    
    var modifyCustomIcon: () -> Void
    
    @State private var orientation = UIDeviceOrientation.unknown
    @State private var lastOrientation = UIDeviceOrientation.unknown
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @AppStorage("checkedCameraPermission") private var checkedCameraPermission: Bool = false
    @AppStorage("aiOn") private var aiOn: Bool = false
    
    @Binding var selectedCustomImage: UIImage?
    @Binding var currCustomIconText: String
    @Binding var oldEditingIcon: String
    @Binding var editCustom: Bool
    
    @State var isImagePickerPresented = false
    @State var isDocumentPickerPresented = false
    @State var showCamera = false
    @State var customPECSAddresses = getCustomPECSAddresses()
    @State var isCustomTextFieldActive = false
    @State var cameraPermission = false
    @State var showImageMenu = false
    @State var isLoading = false
    @State var isGenerating = false
    @State var showSymbols = false
    @State var selectedColor: Color = .black
    @State var searchText = ""
    @State var searchResults: [String] = []
    @State private var task: Task<Void, Error>?
    @State var customizedText = false
    
    @State var currCommunicationBoard = loadCommunicationBoard()
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: (lastOrientation.isLandscape && horizontalSizeClass != .compact) ? (isCustomTextFieldActive ? 25 : 50) : 50)
                .stroke(Color.black, lineWidth: 5)
                .background(
                    RoundedRectangle(cornerRadius: (lastOrientation.isLandscape && horizontalSizeClass != .compact) ? (isCustomTextFieldActive ? 25 : 50) : 50)
                        .fill(Color.white)
                )
                .aspectRatio((lastOrientation.isLandscape && horizontalSizeClass != .compact) ? (isCustomTextFieldActive ? 4 : 1) : 1, contentMode: .fill)
            //                        .clipShape(RoundedRectangle(cornerRadius: (lastOrientation.isLandscape && horizontalSizeClass != .compact) ? (isCustomTextFieldActive ? 25 : 50) : 50))
                .overlay(
                    VStack {
                        Spacer()
                        //new stuff start here
                        if !isCustomTextFieldActive || horizontalSizeClass == .compact || lastOrientation.isPortrait {
                            ZStack {
                                if selectedCustomImage == nil {
                                    if isLoading {
                                        ZStack {
                                            Image(systemName: "square.fill")
                                                .resizable()
                                                .aspectRatio(1, contentMode: .fit)
                                                .foregroundStyle(.purple)
                                                .opacity(0.25)
                                                .padding()
                                            VStack {
                                                LoadingIndicator(color: .white, size: .extraLarge)
                                                    .animation(.snappy, value: true)
                                                if isGenerating {
                                                    Button(action: {
                                                        task?.cancel()
                                                        withAnimation(.spring) {
                                                            isGenerating = false
                                                            isLoading = false
                                                        }
                                                    }) {
                                                        Text("\(Image(systemName: "xmark")) Stop Generating")
                                                            .minimumScaleFactor(0.1)
                                                            .lineLimit(1)
                                                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                            .foregroundStyle(.white)
                                                            .padding()
                                                    }
                                                }
                                            }
                                        }
                                    } else {
                                        TabView {
                                            Button(action: {
                                                isImagePickerPresented.toggle()
                                            }) {
                                                VStack {
                                                    Text("\(Image(systemName:"photo.badge.plus"))")
                                                        .font(.system(size: horizontalSizeClass == .compact ? 100 : 200, weight: .semibold, design: .rounded))
                                                        .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                        .symbolRenderingMode(.hierarchical)
                                                    
                                                    Text("Photos")
                                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                }
                                                .padding()
                                            }
                                            
                                            Button(action: {
                                                if hasCameraPermission() {
                                                    showCamera.toggle()
                                                    checkedCameraPermission = true
                                                } else {
                                                    if checkedCameraPermission {
                                                        if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                                                            UIApplication.shared.open(appSettings)
                                                        }
                                                    }
                                                }
                                            }) {
                                                VStack {
                                                    Text("\(Image(systemName:"camera.on.rectangle"))")
                                                        .font(.system(size: horizontalSizeClass == .compact ? 100 : 200, weight: .semibold, design: .rounded))
                                                        .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                        .symbolRenderingMode(.hierarchical)
                                                    
                                                    
                                                    Text("Take Picture")
                                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                }
                                                .padding()
                                            }
                                            
                                            Button(action: {
                                                showSymbols.toggle()
                                            }) {
                                                VStack {
                                                    Text("\(Image(systemName:"textformat.abc.dottedunderline"))")
                                                        .font(.system(size: horizontalSizeClass == .compact ? 100 : 200, weight: .semibold, design: .rounded))
                                                        .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                        .symbolRenderingMode(.hierarchical)
                                                    
                                                    Text("Symbols")
                                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                }
                                                .padding()
                                            }
                                            
                                            Button(action: {
                                                isDocumentPickerPresented.toggle()
                                            }) {
                                                VStack {
                                                    Text("\(Image(systemName:"doc.badge.plus"))")
                                                        .font(.system(size: horizontalSizeClass == .compact ? 100 : 200, weight: .semibold, design: .rounded))
                                                        .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                        .symbolRenderingMode(.hierarchical)
                                                    
                                                    Text("Documents")
                                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                }
                                                .padding()
                                            }
                                            
                                            if aiOn  && isConnectedToInternet() {
                                                Button(action: {
                                                    withAnimation(.snappy) {
                                                        isGenerating = true
                                                        isLoading = true
                                                    }
                                                    task = Task {
                                                        fetchCustomImage(queryText: currCustomIconText.isEmpty ? "a random, happy, realistic illustration" : currCustomIconText) { image in
                                                            withAnimation(.snappy) {
                                                                selectedCustomImage = image
                                                                isLoading = false
                                                                isGenerating = false
                                                            }
                                                        }
                                                    }
                                                }) {
                                                    VStack {
                                                        Text("\(Image(systemName:"wand.and.stars"))")
                                                            .font(.system(size: horizontalSizeClass == .compact ? 100 : 200, weight: .semibold, design: .rounded))
                                                            .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                            .symbolRenderingMode(.hierarchical)
                                                        
                                                        Text("Generate Image")
                                                            .lineLimit(1)
                                                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                    }
                                                    .foregroundStyle(.purple)
                                                    .padding()
                                                }
                                            }
                                            
                                        }
                                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                                        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                                    }
                                } else {
                                    Button(action: {
                                        showImageMenu.toggle()
                                    }) {
                                        if isLoading {
                                            ZStack {
                                                Image(systemName: "square.fill")
                                                    .resizable()
                                                    .aspectRatio(1, contentMode: .fit)
                                                    .foregroundStyle(.purple)
                                                    .opacity(0.25)
                                                    .padding()
                                                VStack {
                                                    LoadingIndicator(color: .white, size: .extraLarge)
                                                        .animation(.snappy, value: true)
                                                    if isGenerating {
                                                        Button(action: {
                                                            task?.cancel()
                                                            withAnimation(.spring) {
                                                                isGenerating = false
                                                                isLoading = false
                                                            }
                                                        }) {
                                                            Text("\(Image(systemName: "xmark")) Stop Generating")
                                                                .minimumScaleFactor(0.1)
                                                                .lineLimit(1)
                                                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                .foregroundStyle(.white)
                                                                .padding()
                                                        }
                                                    }
                                                }
                                            }
                                        } else {
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color.clear)
                                                .background (
                                                    selectedCustomImage?.asImage
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                )
                                                .transition(.movingParts.filmExposure)
                                                .aspectRatio(1, contentMode: .fit)
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                .padding()
                                        }
                                    }
                                }
                            }
                            .popover(isPresented: $showImageMenu) {
                                if horizontalSizeClass == .compact {
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 2), spacing: 0) {
                                        Button(action: {
                                            isImagePickerPresented.toggle()
                                            showImageMenu.toggle()
                                            task?.cancel()
                                        }) {
                                            VStack {
                                                Text("\(Image(systemName:"photo.badge.plus"))")
                                                    .font(.system(size: horizontalSizeClass == .compact ? 100 : 50, weight: .semibold, design: .rounded))
                                                    .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                    .symbolRenderingMode(.hierarchical)
                                                
                                                Text("Photos")
                                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                            }
                                            .padding()
                                        }
                                        
                                        Button(action: {
                                            if hasCameraPermission() {
                                                showCamera.toggle()
                                                showImageMenu.toggle()
                                                checkedCameraPermission = true
                                                task?.cancel()
                                            } else {
                                                if checkedCameraPermission {
                                                    if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                                                        UIApplication.shared.open(appSettings)
                                                    }
                                                }
                                            }
                                        }) {
                                            VStack {
                                                Text("\(Image(systemName:"camera.on.rectangle"))")
                                                    .font(.system(size: horizontalSizeClass == .compact ? 100 : 50, weight: .semibold, design: .rounded))
                                                    .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                    .symbolRenderingMode(.hierarchical)
                                                
                                                
                                                Text("Take Picture")
                                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                            }
                                            .padding()
                                        }
                                        
                                        Button(action: {
                                            showSymbols.toggle()
                                            showImageMenu.toggle()
                                            task?.cancel()
                                        }) {
                                            VStack {
                                                Text("\(Image(systemName:"textformat.abc.dottedunderline"))")
                                                    .font(.system(size: horizontalSizeClass == .compact ? 100 : 50, weight: .semibold, design: .rounded))
                                                    .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                    .symbolRenderingMode(.hierarchical)
                                                    .padding([.top, .bottom])
                                                
                                                Text("Symbols")
                                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                            }
                                            .padding()
                                        }
                                        
                                        Button(action: {
                                            isDocumentPickerPresented.toggle()
                                            task?.cancel()
                                        }) {
                                            VStack {
                                                Text("\(Image(systemName:"doc.badge.plus"))")
                                                    .font(.system(size: horizontalSizeClass == .compact ? 100 : 50, weight: .semibold, design: .rounded))
                                                    .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                    .symbolRenderingMode(.hierarchical)
                                                
                                                Text("Documents")
                                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                            }
                                            .padding()
                                        }
                                        
                                        if aiOn  && isConnectedToInternet() {
                                            Button(action: {
                                                showImageMenu = false
                                                withAnimation(.snappy) {
                                                    isGenerating = true
                                                    isLoading = true
                                                }
                                                task = Task {
                                                    fetchCustomImage(queryText: currCustomIconText.isEmpty ? "a random, happy, realistic illustration" : currCustomIconText) { image in
                                                        withAnimation(.snappy) {
                                                            selectedCustomImage = image
                                                            isLoading = false
                                                            isGenerating = false
                                                        }
                                                    }
                                                }
                                            }) {
                                                VStack {
                                                    Text("\(Image(systemName:"wand.and.stars"))")
                                                        .font(.system(size: horizontalSizeClass == .compact ? 100 : 50, weight: .semibold, design: .rounded))
                                                        .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                        .symbolRenderingMode(.hierarchical)
                                                    
                                                    Text("Generate Image")
                                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                }
                                                .padding()
                                            }
                                        }
                                        Button(action: {
                                            showImageMenu.toggle()
                                            withAnimation(.snappy) {
                                                selectedCustomImage = nil
                                            }
                                            task?.cancel()
                                        }) {
                                            if selectedCustomImage != nil {
                                                VStack {
                                                    ZStack {
                                                        selectedCustomImage?.asImage
                                                            .resizable()
                                                            .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)
                                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                                            .opacity(0.25)
                                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 8)
                                                                    .stroke(.black, lineWidth: 3)
                                                            )
                                                            .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                            .foregroundStyle(.red)
                                                        Image(systemName: "trash.square.fill")
                                                            .resizable()
                                                            .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)
                                                            .padding()
                                                            .symbolRenderingMode(.hierarchical)
                                                        
                                                    }
                                                    Text("Delete Image")
                                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                }
                                                .foregroundStyle(.red)
                                                .padding()
                                            }
                                        }
                                    }
                                } else {
                                    HStack {
                                        Button(action: {
                                            isImagePickerPresented.toggle()
                                            showImageMenu.toggle()
                                            task?.cancel()
                                        }) {
                                            VStack {
                                                Text("\(Image(systemName:"photo.badge.plus"))")
                                                    .font(.system(size: horizontalSizeClass == .compact ? 100 : 50, weight: .semibold, design: .rounded))
                                                    .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                    .symbolRenderingMode(.hierarchical)
                                                
                                                Text("Photos")
                                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                            }
                                            .padding()
                                        }
                                        
                                        Button(action: {
                                            if hasCameraPermission() {
                                                showCamera.toggle()
                                                showImageMenu.toggle()
                                                checkedCameraPermission = true
                                                task?.cancel()
                                            } else {
                                                if checkedCameraPermission {
                                                    if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                                                        UIApplication.shared.open(appSettings)
                                                    }
                                                }
                                            }
                                        }) {
                                            VStack {
                                                Text("\(Image(systemName:"camera.on.rectangle"))")
                                                    .font(.system(size: horizontalSizeClass == .compact ? 100 : 50, weight: .semibold, design: .rounded))
                                                    .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                    .symbolRenderingMode(.hierarchical)
                                                
                                                
                                                Text("Take Picture")
                                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                            }
                                            .padding()
                                        }
                                        
                                        Button(action: {
                                            showSymbols.toggle()
                                            showImageMenu.toggle()
                                            task?.cancel()
                                        }) {
                                            VStack {
                                                Text("\(Image(systemName:"textformat.abc.dottedunderline"))")
                                                    .font(.system(size: horizontalSizeClass == .compact ? 100 : 50, weight: .semibold, design: .rounded))
                                                    .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                    .symbolRenderingMode(.hierarchical)
                                                
                                                Text("Symbols")
                                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                            }
                                            .padding()
                                        }
                                        
                                        Button(action: {
                                            isDocumentPickerPresented.toggle()
                                            task?.cancel()
                                        }) {
                                            VStack {
                                                Text("\(Image(systemName:"doc.badge.plus"))")
                                                    .font(.system(size: horizontalSizeClass == .compact ? 100 : 50, weight: .semibold, design: .rounded))
                                                    .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                    .symbolRenderingMode(.hierarchical)
                                                
                                                Text("Documents")
                                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                            }
                                            .padding()
                                        }
                                        
                                        if aiOn  && isConnectedToInternet() {
                                            Button(action: {
                                                showImageMenu = false
                                                withAnimation(.snappy) {
                                                    isGenerating = true
                                                    isLoading = true
                                                }
                                                task = Task {
                                                    fetchCustomImage(queryText: currCustomIconText.isEmpty ? "a random, happy, realistic illustration" : currCustomIconText) { image in
                                                        withAnimation(.snappy) {
                                                            selectedCustomImage = image
                                                            isLoading = false
                                                            isGenerating = false
                                                        }
                                                    }
                                                }
                                            }) {
                                                VStack {
                                                    Text("\(Image(systemName:"wand.and.stars"))")
                                                        .font(.system(size: horizontalSizeClass == .compact ? 100 : 50, weight: .semibold, design: .rounded))
                                                        .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                        .symbolRenderingMode(.hierarchical)
                                                    
                                                    Text("Generate Image")
                                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                }
                                                .foregroundStyle(.purple)
                                                .padding()
                                            }
                                        }
                                        Button(action: {
                                            showImageMenu.toggle()
                                            withAnimation(.snappy) {
                                                selectedCustomImage = nil
                                            }
                                        }) {
                                            if selectedCustomImage != nil {
                                                VStack {
                                                    ZStack {
                                                        selectedCustomImage?.asImage
                                                            .resizable()
                                                            .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)
                                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                                            .opacity(0.25)
                                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 8)
                                                                    .stroke(.black, lineWidth: 3)
                                                            )
                                                            .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                            .foregroundStyle(.red)
                                                        Image(systemName: "trash.square.fill")
                                                            .resizable()
                                                            .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)
                                                            .padding()
                                                            .symbolRenderingMode(.hierarchical)
                                                        
                                                    }
                                                    Text("Delete Image")
                                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                }
                                                .foregroundStyle(.red)
                                                .padding()
                                            }
                                        }
                                    }
                                }
                            }
                            //                                .dropDestination(for: Data.self) { items, location in
                            //                                    isLoading.toggle()
                            //                                    guard let item = items.first else {
                            //                                        selectedCustomImage = nil
                            //                                        return false
                            //                                    }
                            //                                    guard let uiImage = UIImage(data: item) else {
                            //                                        selectedCustomImage = nil
                            //                                        return false
                            //                                    }
                            //                                    selectedCustomImage = uiImage
                            //                                    if currCustomIconText.isEmpty {
                            //                                        currCustomIconText = labelImage(input: uiImage).components(separatedBy: ", ")[0]
                            //                                    }
                            //                                    return true
                            //                                }
                            Spacer()
                        }
                        HStack {
                            ZStack { //zstack with gray is to workaround low contrast on dark mode despite white background
                                Text("Label")
                                    .minimumScaleFactor(0.1)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: horizontalSizeClass == .compact ? ((lastOrientation.isLandscape && horizontalSizeClass != .compact) ? 30 : 50) : ((lastOrientation.isLandscape && horizontalSizeClass != .compact) ? 75 : 135), weight: .semibold,  design: .rounded))
                                    .foregroundStyle(currCustomIconText.isEmpty ? .gray : .clear)
                                TextField("Label", text: $currCustomIconText, onEditingChanged: { editing in
                                    withAnimation(.snappy) {
                                        isCustomTextFieldActive = editing
                                    }
                                }, onCommit: {
                                    showImageMenu = false
                                })
                                .minimumScaleFactor(0.1)
                                .multilineTextAlignment(.center)
                                .font(.system(size: horizontalSizeClass == .compact ? ((lastOrientation.isLandscape && horizontalSizeClass != .compact) ? 30 : 50) : ((lastOrientation.isLandscape && horizontalSizeClass != .compact) ? 75 : 135), weight: .semibold,  design: .rounded))
                                .foregroundStyle(.black)
                            }
                            if !currCustomIconText.isEmpty && !isCustomTextFieldActive {
                                Spacer()
                                Spacer()
                            }
                        }
                        .padding()
                        if isCustomTextFieldActive && horizontalSizeClass != .compact || lastOrientation.isLandscape {
                            Spacer()
                        }
                    }
                )
                .scaledToFit()
                .padding()
            HStack { //bottom row of buttons
                Button(action: {
                    self.presentation.wrappedValue.dismiss()
                    currCustomIconText = ""
                    selectedCustomImage = nil
                    showImageMenu = false
                    task?.cancel()
                }) {
                    Image(systemName:"xmark.square.fill")
                        .resizable()
                        .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                        .foregroundStyle(.gray)
                        .symbolRenderingMode(!isLoading && (selectedCustomImage != nil || !currCustomIconText.isEmpty) ? .hierarchical : .monochrome)
                }
                .padding(horizontalSizeClass == .compact ? 0 : 5)
                
                if !isLoading && (selectedCustomImage != nil || !currCustomIconText.isEmpty) {
                    Button(action: {
                        var customPECSAddresses = getCustomPECSAddresses()
                        
                        if editCustom {  //problem in here somewhere
                            if currCustomIconText != oldEditingIcon { //if the text has changed
                                
                                if currCustomIconText.isEmpty { //if its empty then give it something to go off of
                                    if customPECSAddresses["0#id"] == nil {
                                        currCustomIconText = "0#id"
                                    } else {
                                        var i = 1
                                        while customPECSAddresses["\(i)#id"] != nil {
                                            i += 1
                                        }
                                        currCustomIconText = "\(i)#id"
                                    }
                                }
                                if customPECSAddresses[currCustomIconText] != nil { //if there is already something named the same thing then change it
                                    var i = 1
                                    while customPECSAddresses["\(i)#id\(currCustomIconText)"] != nil {
                                        i += 1
                                    }
                                    currCustomIconText = "\(i)#id\(currCustomIconText)"
                                }
                                
                                if loadImageFromLocalURL(customPECSAddresses[oldEditingIcon] ?? "") != nil { //if the old icon had an image
                                    deleteFile(at: customPECSAddresses[oldEditingIcon]!) //then delete the old image
                                }
                                customPECSAddresses[oldEditingIcon] = nil //remove the old key
                                if selectedCustomImage == nil {
                                    customPECSAddresses[currCustomIconText] = "" //if there is no image now then set the new value to be empty
                                } else {
                                    customPECSAddresses[currCustomIconText] = saveImageToDocumentsDirectory(selectedCustomImage!) //else save the new image
                                }
                                saveSheetArray(sheetObjects: updateCustomIcons(oldKey: oldEditingIcon, newKey: currCustomIconText))
                            } else if loadImageFromLocalURL(customPECSAddresses[currCustomIconText]!) != selectedCustomImage { //same text new image
                                if selectedCustomImage == nil {
                                    customPECSAddresses[currCustomIconText] = "" //if there is no image now then set the new value to be empty
                                } else {
                                    customPECSAddresses[currCustomIconText] = saveImageToDocumentsDirectory(selectedCustomImage!) //else save the new image
                                }
                            }
                            
                        } else {
                            if currCustomIconText.isEmpty {
                                if customPECSAddresses["0#id"] == nil {
                                    currCustomIconText = "0#id"
                                } else {
                                    var i = 1
                                    while customPECSAddresses["\(i)#id"] != nil {
                                        i += 1
                                    }
                                    currCustomIconText = "\(i)#id"
                                }
                            }
                            if customPECSAddresses[currCustomIconText] != nil {
                                var i = 1
                                while customPECSAddresses["\(i)#id\(currCustomIconText)"] != nil {
                                    i += 1
                                }
                                currCustomIconText =  "\(i)#id\(currCustomIconText)"
                            }
                            if selectedCustomImage == nil {
                                customPECSAddresses[currCustomIconText] = ""
                            } else {
                                customPECSAddresses[currCustomIconText] = saveImageToDocumentsDirectory(selectedCustomImage!)
                            }
                            var currCommunicationBoard = loadCommunicationBoard()
                            currCommunicationBoard.insert([currCustomIconText], at: 0)
                            saveCommunicationBoard(currCommunicationBoard)
                        }
                        
                        saveCustomPECSAddresses(customPECSAddresses)
                        modifyCustomIcon()
                        self.presentation.wrappedValue.dismiss()
                        updateUsage("action:editIcon")
                        selectedCustomImage = nil
                        currCustomIconText = ""
                        oldEditingIcon = ""
                        task?.cancel()
                    }) {
                        if selectedCustomImage == nil && currCustomIconText.isEmpty && editCustom {
                            Image(systemName:"trash.square.fill")
                                .resizable()
                                .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                .foregroundStyle(.red)
                                .symbolRenderingMode(.hierarchical)
                                .padding()
                        } else {
                            Image(systemName:"checkmark.square.fill")
                                .resizable()
                                .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                .foregroundStyle(.green)
                        }
                    }
                    .padding(horizontalSizeClass == .compact ? 0 : 5)
                }
                /*
                if !currCustomIconText.isEmpty && !isCustomTextFieldActive {
                    Button(action: {
                        withAnimation(.snappy) {
                            currCustomIconText = ""
                        }
                    }) {
                        Image(systemName: "delete.backward.fill")
                            .font(.system(size: horizontalSizeClass == .compact ? 75 : 100, weight: .regular,  design: .rounded))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.red)
                    }
                    .padding(horizontalSizeClass == .compact ? 0 : 5)
                } */
            }
            .ignoresSafeArea(.keyboard)
        }
        .onChange(of: isCustomTextFieldActive, perform: { _ in
            if isCustomTextFieldActive && !currCustomIconText.isEmpty {
                customizedText = true
            }
        })
        .onChange(of: selectedCustomImage, perform: { _ in
            if !customizedText && selectedCustomImage != nil {
                Task {
                    withAnimation(.snappy) {
                        currCustomIconText = await labelImage(input: selectedCustomImage!)
                    }
                }
            }
        })
        .sheet(isPresented: $isDocumentPickerPresented) {
            DocumentImagePicker(selectedCustomImage: $selectedCustomImage, isLoading: $isLoading)
                .ignoresSafeArea()
                .onDisappear {
                    isLoading = false
                }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            PHPickerView(selectedImage: $selectedCustomImage, isLoading: $isLoading)
                .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPickerView(selectedImage: $selectedCustomImage, isLoading: $isLoading)
        }
        .sheet(isPresented: $showSymbols) {
            VStack {
                HStack {
                    ForEach([Color.green, .orange, .blue, .red, .cyan, .purple, .black], id: \.self) { color in
                        Button(action: {
                            selectedColor = color
                        }) {
                            Text("\(Image(systemName: selectedColor == color ? "circle.fill" : "circle.circle"))")
                                .font(.system(size: horizontalSizeClass == .compact ? 25 : 50, weight: .bold, design: .rounded))
                                .foregroundStyle(color)
                        }
                    }
                    Button {
                        showSymbols.toggle()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 25, weight: .bold, design: .rounded))
                            .foregroundStyle(.gray)
                    }
                }
                TextField("\(Image(systemName: "magnifyingglass")) Search", text: $searchText)
                    .multilineTextAlignment(.center)
                    .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .bold, design: .rounded))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.black.opacity(0.25))
                    )
                ScrollView {
                    if !searchResults.isEmpty {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 75 : 130))], spacing: horizontalSizeClass == .compact ? 5 : 10) {
                            ForEach(0..<searchResults.count, id: \.self) { symbol in
                                Button(action: {
                                    customizedText = true
                                    showSymbols = false
                                    let selectedSymbol = UIImage(systemName: searchResults[symbol], withConfiguration: UIImage.SymbolConfiguration(pointSize: horizontalSizeClass == .compact ? 125 : 175, weight: .bold, scale: .large)) ?? UIImage(systemName: "square.fill")!
                                    selectedCustomImage = tintedImage(image: selectedSymbol, tintColor: UIColor(selectedColor))
                                }) {
                                    Text("\(Image(systemName: searchResults[symbol]))")
                                        .font(.system(size: horizontalSizeClass == .compact ? 75 : 45, weight: .bold, design: .rounded))
                                        .foregroundStyle(selectedColor)
                                }
                            }
                        }
                        Divider().padding()
                    } else if !searchText.isEmpty {
                        Text("There are no matches for \(searchText), try searching for something else.")
                            .minimumScaleFactor(0.01)
                            .multilineTextAlignment(.center)
                            .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .bold, design: .rounded))
                            .foregroundStyle(.gray)
                            .padding()
                            .padding()
                    }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 75 : 130))], spacing: horizontalSizeClass == .compact ? 5 : 10) {
                        ForEach(0..<symbols.count, id: \.self) { symbol in
                            if UIImage(systemName: symbols[symbol]) != nil {
                                Button(action: {
                                    showSymbols = false
                                    let selectedSymbol = UIImage(systemName: symbols[symbol], withConfiguration: UIImage.SymbolConfiguration(pointSize: horizontalSizeClass == .compact ? 125 : 175, weight: .medium, scale: .large)) ?? UIImage(systemName: "square.fill")!
                                    selectedCustomImage = tintedImage(image: selectedSymbol, tintColor: UIColor(selectedColor))
                                }) {
                                    Text("\(Image(systemName: symbols[symbol]))")
                                        .font(.system(size: horizontalSizeClass == .compact ? 75 : 45, weight: .medium, design: .rounded))
                                        .foregroundStyle(selectedColor)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.top)
            .background(.white)
            .onChange(of: searchText, perform: { _ in
                searchResults.removeAll()
                searchSymbols(searchText) { newItems in
                    searchResults.append(contentsOf: newItems)
                }
                if searchResults.isEmpty {
                    searchSymbols(autoCorrectComplete(text: searchText)) { newItems in
                        searchResults.append(contentsOf: newItems)
                    }
                }
            })
        }
    }
}
