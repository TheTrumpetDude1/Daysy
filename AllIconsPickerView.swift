//
//  AllIconsPickerView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 5/1/24.
//

import SwiftUI
import SwiftUI
import Pow

struct AllIconsPickerView: View {
    @State var currSheet: SheetObject = SheetObject()
    
    @State var currImage: String = ""
    var modifyIcon: (String) -> Void
    var modifyCustomIcon: () -> Void
    var modifyDetails: ([String]) -> Void
    var onDismiss: () -> Void
    var showCreateCustom: Bool = true
    var tutorialMode: Bool = false
    
    @State private var orientation = UIDeviceOrientation.unknown
    @State private var lastOrientation = UIDeviceOrientation.unknown
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var searchText = ""
    @State var isImagePickerPresented = false
    @State var selectedCustomImage: UIImage? = nil
    @State var currCustomIconText = ""
    @State var customPECSAddresses = getCustomPECSAddresses()
    @State var isCustomTextFieldActive = false
    @State var customAnimate = false
    @State var oldEditingIcon = ""
    @State var cameraPermission = false
    @State var showCamera = false
    @State var showImageMenu = false
    @State var showCustom = false
    @State var editCustom = false
    @State var customIconPreviews: [String : UIImage] = [:]
    @AppStorage("currSheetIndex") private var currSheetIndex: Int = 0
    
    var body: some View { //fullscreencover that has all the icons in it, used to set icons on a sheet
        var searchResults = searchIcons(searchText)
        
        ZStack { //main list of all the icons
            ScrollView {
                if horizontalSizeClass == .compact {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("\(Image(systemName: "square.grid.3x3")) All Icons")
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .padding(.bottom, 5)
                                .padding(.top)
                        }
                        .padding(.leading, horizontalSizeClass == .compact ? 20 : 0)
                        if horizontalSizeClass == .compact {
                            Spacer()
                            Button(action: {
                                onDismiss()
                            }) {
                                Text("\(Image(systemName: "xmark.circle.fill"))")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .foregroundStyle(.gray)
                                    .symbolRenderingMode(.hierarchical)
                                    .padding([.top, .trailing])
                            }
                        }
                    }
                }
                TextField("\(Image(systemName: "magnifyingglass")) Search", text: $searchText)
                    .multilineTextAlignment(.center)
                    .font(.system(size: horizontalSizeClass == .compact ? 35 : 65, weight: .bold, design: .rounded))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray4))
                    )
                    .padding([.leading, .trailing])
                    .padding(.top, horizontalSizeClass == .compact ? 0 : 10)
                Text(verbatim: "Daysy Icons provided by www.mypecs.com")
                    .lineLimit(1)
                    .minimumScaleFactor(0.01)
                    .font(.system(size: 25, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(.systemGray2))
                LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 100 : 150))], spacing: horizontalSizeClass == .compact ? 0 : 20) {
                    ForEach(0..<searchResults.count, id: \.self) { key in //first display custom icon results
                        if UIImage(named: searchResults[key]) != nil {
                            Button(action: {
                                modifyIcon(searchResults[key])
                                modifyDetails([])
                                updateUsage(searchResults[key])
                                onDismiss()
                                hapticFeedback()
                            }) {
                                Image(searchResults[key])
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
//                                    .draggable(Image(searchResults[key]))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.black, lineWidth: 3)
                                    )
                            }
                            .foregroundStyle(.primary)
                        } else {
                            Button(action: {
                                modifyIcon(searchResults[key])
                                modifyDetails([])
                                updateUsage(searchResults[key])
                                onDismiss()
                                hapticFeedback()
                            }) {
                                Image(uiImage: customIconPreviews[searchResults[key]] ?? UIImage(systemName: "square.fill")!)
                                    .resizable()
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.black, lineWidth: 3)
                                    )
                                    .scaledToFit()
                            }
                            .foregroundStyle(.primary)
                            //                            .padding(horizontalSizeClass == .compact ? 3 : 10)
                            .overlay(
                                VStack {
                                    HStack {
                                        Menu {
                                            Button {
                                                oldEditingIcon = searchResults[key]
                                                currCustomIconText = extractKey(from: searchResults[key])
                                                selectedCustomImage = loadImageFromLocalURL(customPECSAddresses[removeCustomIconObjectPrefix(searchResults[key])] ?? "")
                                                editCustom.toggle()
                                                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                                    showCustom.toggle()
                                                }
                                            } label: {
                                                Label("Edit", systemImage: "square.and.pencil")
                                            }
                                            
                                            Divider()
                                            
                                            Button(role: .destructive) {
                                                let newSheetArray = deleteCustomIcons(currIcon: searchResults[key])
                                                currSheet = newSheetArray[currSheetIndex]
                                                saveSheetArray(sheetObjects: newSheetArray)
                                                withAnimation(.snappy) {
                                                    customPECSAddresses = getCustomPECSAddresses()
                                                }
                                                hapticFeedback(type: 1)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        } label: {
                                            Image(systemName: "ellipsis.circle.fill")
                                                .resizable()
                                                .frame(width: horizontalSizeClass == .compact ? 30 : 40, height: horizontalSizeClass == .compact ? 30 : 40)
                                                .foregroundStyle(Color.accentColor)
                                        }
                                        Spacer()
                                    }
                                    Spacer()
                                }
                            )
                        }
                    }
                }
                .padding()
                
                if searchResults.count > 0 {
                    Divider()
                        .padding()
                        .padding(.bottom, 50)
                } else if !searchText.isEmpty {
                    Text("There are no matches for \(searchText), create your own icon or search for something else.")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .bold, design: .rounded))
                        .foregroundStyle(.gray)
                        .padding()
                        .padding()
                }
                if searchText.isEmpty {
                    if !tutorialMode {
                        if !(!showCreateCustom && customPECSAddresses.count == 0) {
                            Text("My Icons")
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                                .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                        }
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 100 : 150))], spacing: horizontalSizeClass == .compact ? 0 : 20) {
                            if showCreateCustom {
                                Button(action: {
                                    showCustom.toggle()
                                }) {
                                    VStack {
                                        Image(systemName: "plus.square.fill")
                                            .resizable()
                                            .scaledToFill()
                                            .symbolRenderingMode(.hierarchical)
                                        Text("Create Icon")
                                            .minimumScaleFactor(0.1)
                                            .lineLimit(1)
                                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 40, weight: .bold, design: .rounded))
                                    }
                                    .padding()
                                }
                                .foregroundStyle(.green)
//                                .dropDestination(for: Data.self) { items, location in
//                                    showCustom.toggle()
//                                    customAnimate.toggle()
//                                    selectedCustomImage = UIImage(systemName: "square.fill")
//                                    guard let item = items.first else {
//                                        selectedCustomImage = nil
//                                        return false
//                                    }
//                                    guard let uiImage = UIImage(data: item) else {
//                                        selectedCustomImage = nil
//                                        return false
//                                    }
//                                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
//                                        selectedCustomImage = uiImage
//                                        currCustomIconText = labelImage(input: uiImage).components(separatedBy: ", ")[0]
//                                    }
//                                    return true
//                                }
                            }
                            ForEach(customPECSAddresses.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                Button(action: {
                                    modifyIcon(key)
                                    modifyDetails([])
                                    updateUsage(key)
                                    onDismiss()
                                    hapticFeedback()
                                }) {
                                    Image(uiImage: customIconPreviews[key] ?? UIImage(systemName: "square.fill")!)
                                        .resizable()
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(.black, lineWidth: 3)
                                        )
                                        .scaledToFit()
                                }
                                .transition(.movingParts.vanish(.red))
                                .foregroundStyle(.black)
                                //                            .padding()
                                .overlay(
                                    VStack {
                                        HStack {
                                            Menu {
                                                Button {
                                                    oldEditingIcon = key
                                                    currCustomIconText = extractKey(from: key)
                                                    selectedCustomImage = loadImageFromLocalURL(customPECSAddresses[removeCustomIconObjectPrefix(key)] ?? "")
                                                    editCustom.toggle()
                                                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                                        showCustom.toggle()
                                                    }
                                                } label: {
                                                    Label("Edit", systemImage: "square.and.pencil")
                                                }
                                                
                                                Divider()
                                                Button(role: .destructive) {
                                                    let newSheetArray = deleteCustomIcons(currIcon: key)
                                                    currSheet = newSheetArray[currSheetIndex]
                                                    saveSheetArray(sheetObjects: newSheetArray)
                                                    withAnimation(.snappy) {
                                                        customPECSAddresses = getCustomPECSAddresses()
                                                    }
                                                    hapticFeedback(type: 1)
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            } label: {
                                                Image(systemName: "ellipsis.circle.fill")
                                                    .resizable()
                                                    .frame(width: horizontalSizeClass == .compact ? 30 : 40, height: horizontalSizeClass == .compact ? 30 : 40)
                                                    .foregroundStyle(Color.accentColor)
                                            }
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                    ForEach(pecsCategories, id: \.self) { icon in //grid of default icons, also displays categories
                        VStack(alignment: .center) {
                            Text(icon[0])
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                                .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                .padding(.bottom, icon[0] == "All Icons" ? 5 : 0)
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 100 : 150))], spacing: horizontalSizeClass == .compact ? 0 : 20) {
                                ForEach(1..<icon.count, id: \.self) { sheeticonobject in
                                    Button(action: {
                                        modifyIcon(icon[sheeticonobject])
                                        modifyDetails([])
                                        updateUsage(icon[sheeticonobject])
                                        onDismiss()
                                        hapticFeedback()
                                    }) {
                                        Image(String(icon[sheeticonobject]))
                                            .resizable()
                                            .scaledToFill()
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
//                                            .draggable(Image(String(icon[sheeticonobject])))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(.black, lineWidth: 3)
                                            )
                                    }
                                    .foregroundStyle(.black)
                                }
                            }
                            .padding()
                        }
                    }
                } else {
                    VStack {
                        Text(allPECS[0])
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                            .padding(.bottom, allPECS[0] == "All Icons" ? 5 : 0)
                        Text(verbatim: "Daysy Icons provided by www.mypecs.com")
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .font(.system(size: 25, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(.systemGray2))
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 100 : 150))], spacing: horizontalSizeClass == .compact ? 0 : 20) {
                            ForEach(1..<allPECS.count, id: \.self) { icon in
                                Button(action: {
                                    modifyIcon(allPECS[icon])
                                    modifyDetails([])
                                    updateUsage(allPECS[icon])
                                    onDismiss()
                                    hapticFeedback()
                                }) {
                                    Image(allPECS[icon])
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
//                                        .draggable(Image(allPECS[icon]))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(.black, lineWidth: 3)
                                        )
                                }
                                .foregroundStyle(.black)
                            }
                        }
                        .padding()
                    }
                    .padding(.bottom, 100)
                }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    HStack { //bottom button row
                        if horizontalSizeClass != .compact {
                            Button(action: {
                                onDismiss()
                            }) {
                                Image(systemName: "xmark.square.fill")
                                    .resizable()
                                    .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.gray, Color(.systemGray6))
                                
                            }
                            .padding()
                            .foregroundStyle(.gray)
                        }
                        
                        if currImage != "plus.viewfinder" && !currImage.isEmpty{
                            Button(action: {
                                onDismiss()
                                modifyIcon("")
                                modifyDetails([])
                                hapticFeedback(type: 1)
                            }) {
                                ZStack {
                                    if UIImage(named: currImage) == nil {
                                        Image(uiImage: customIconPreviews[currImage] ?? UIImage(systemName: "square.fill")!)
                                            .resizable()
                                            .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                            .opacity(0.25)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(.black, lineWidth: 3)
                                            )
                                    } else {
                                        Image(currImage)
                                            .resizable()
                                            .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                            .opacity(0.25)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                        //                                            .draggable(Image(currImage))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(.black, lineWidth: 3)
                                            )
                                    }
                                    Image(systemName: "trash.square.fill")
                                        .resizable()
                                        .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                        .symbolRenderingMode(.hierarchical)
                                    
                                }
                            }
                            .padding()
                            .foregroundStyle(.red)
                        }
                    }
                    Spacer()
                }
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color(.systemBackground), Color(.systemBackground), Color.clear]), startPoint: .bottom, endPoint: .top)
                        .ignoresSafeArea()
                )
            }
        }
        .onAppear {
            if customIconPreviews.isEmpty {
                Task {
                    do {
                        customIconPreviews = await getCustomIconPreviews()
                    }
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        .onRotate { newOrientation in
            orientation = newOrientation
            if !newOrientation.isFlat {
                lastOrientation = newOrientation
            }
        }
        .onAppear {
            let oldImage = currImage
            currImage = "square.fill"
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                currImage = oldImage
            }
        }
        .onChange(of: searchText, perform: { _ in
            searchResults = searchIcons(searchText)
            if searchResults.isEmpty {
                searchResults = searchIcons(autoCorrectComplete(text: searchText))
            }
        })
        .fullScreenCover(isPresented: $showCustom) { //fullscreencover for editing a custom icon
            CreateIconView(modifyCustomIcon: {
                modifyCustomIcon()
                customPECSAddresses = getCustomPECSAddresses()
                searchResults = searchIcons(searchText)
                Task {
                    do {
                        customIconPreviews = await getCustomIconPreviews()
                    }
                }
            }, selectedCustomImage: $selectedCustomImage, currCustomIconText: $currCustomIconText, oldEditingIcon: $oldEditingIcon, editCustom: $editCustom)
        }
    }
}
