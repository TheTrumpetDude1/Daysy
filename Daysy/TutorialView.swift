//
//  TutorialView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 10/21/23.
//

//theres some navigation destinations and stuff commented out because this was originally built with NavigationStack, but had to fall back to NavigationView for compatability, lower deployment target

import SwiftUI
import Foundation
import Pow

struct WelcomeView: View { //main welcome page
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var beginSetup = false
    
    @State var showDaysy = false
    @State var showSheets = false
    @State var showBoard = false
    @State var showStarted = false
    
    var body: some View {
        NavigationView {
            VStack {
                if horizontalSizeClass != .compact {
                    Spacer()
                }
                VStack {
                    Image("logo-transparent")
                        .resizable()
                        .frame(width: 200, height: 200)
                    if showDaysy {
                        if horizontalSizeClass == .compact {
                            VStack {
                                Text("Welcome to")
                                    .lineLimit(1)
                                    .font(.system(size: 55, weight: .black, design: .rounded))
                                    .opacity(0.65)
                                    .transition(.movingParts.filmExposure)
                                Text("Daysy!")
                                    .lineLimit(1)
                                    .font(.system(size: 55, weight: .black, design: .rounded))
                                    .transition(.movingParts.filmExposure)
                            }
                        } else {
                            Text("Welcome to Daysy!")
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                                .font(.system(size: 100, weight: .black, design: .rounded))
                                .padding([.leading, .trailing, .bottom])
                                .transition(.movingParts.filmExposure)
                        }
                    }
                }
                Spacer()
                VStack(alignment: .leading) {
                    if showSheets {
                        HStack {
                            ZStack {
                                Color.clear.frame(width: 40, height: 40)
                                    .padding(.trailing)
                                Text("\(Image(systemName: "newspaper"))")
                                    .font(.system(size: 40, weight: .medium, design: .rounded))
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(.purple)
                            }
                            VStack(alignment: .leading) {
                                Text("Sheets")
                                    .font(.system(size: horizontalSizeClass == .compact ? 20 : 40, weight: .bold, design: .rounded))
                                Text("Show and schedule your routines and activities with Timeslots and Custom Labels.")
                                    .font(.system(size: horizontalSizeClass == .compact ? 14 : 25, weight: .medium, design: .rounded))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .opacity(0.75)
                            }
                        }
                        .padding()
                        .padding([.leading, .trailing], horizontalSizeClass == .compact ? 0 : 15)
                    }
                    if showBoard {
                        HStack {
                            ZStack {
                                Color.clear.frame(width: 40, height: 40)
                                    .padding(.trailing)
                                Text("\(Image(systemName: "hand.tap"))")
                                    .font(.system(size: 40, weight: .medium, design: .rounded))
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(.orange)
                            }
                            VStack(alignment: .leading) {
                                Text("Board")
                                    .font(.system(size: horizontalSizeClass == .compact ? 20 : 40, weight: .bold, design: .rounded))
                                Text("Communicate using Icons! Use Daysy’s Icons and Folders, or create your own.")
                                    .font(.system(size: horizontalSizeClass == .compact ? 14 : 25, weight: .medium, design: .rounded))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .opacity(0.75)
                            }
                        }
                        .padding()
                        .padding([.leading, .trailing], horizontalSizeClass == .compact ? 0 : 10)
                    }
                }
                .navigationBarTitle("", displayMode: .inline)
                
                Spacer()
                
                if showStarted {
                    NavigationLink(destination: GetStartedView()) {
                        Text("Get Started")
                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(horizontalSizeClass == .compact ? 20 : 30)
                            .padding([.leading, .trailing])
                            .background(.purple)
                            .cornerRadius(horizontalSizeClass == .compact ? 15 : 30)
                            .symbolRenderingMode(.hierarchical)
                    }
                    .padding([.top, .bottom])
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
        .statusBarHidden()
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { timer in
                withAnimation(.snappy) {
                    showDaysy = true
                }
                Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { timer in
                    withAnimation(.snappy) {
                        showSheets = true
                    }
                    Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { timer in
                        withAnimation(.snappy) {
                            showBoard = true
                        }
                        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { timer in
                            withAnimation(.snappy) {
                                showStarted = true
                            }
                        }
                    }
                }
            }
        }
    }
}

struct GetStartedView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.presentationMode) var presentation
    
    @State var showSetup = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                VStack {
                    Image(systemName: "person.fill.questionmark")
                        .resizable()
                        .frame(width: horizontalSizeClass == .compact ? 85 : 115, height: horizontalSizeClass == .compact ? 75 : 100)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.orange, .purple.opacity(0.5))
                    VStack {
                        Text("Learn the basics,")
                            .lineLimit(1)
                            .font(.system(size: horizontalSizeClass == .compact ? 35 : 55, weight: .bold, design: .rounded))
                        Text("or jump right in.")
                            .lineLimit(1)
                            .font(.system(size: horizontalSizeClass == .compact ? 35 : 55, weight: .bold, design: .rounded))
                    }
                }
                Spacer()
                VStack {
                    NavigationLink(destination: SheetTutorialView()) {
                        HStack {
                            ZStack {
                                Color.clear.frame(width: horizontalSizeClass == .compact ? 30 : 45, height: horizontalSizeClass == .compact ? 30 : 45)
                                    .padding()
                                Text("\(Image(systemName: "newspaper"))")
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 45, weight: .bold, design: .rounded))
                                    .symbolRenderingMode(.hierarchical)
                                    .opacity(0.75)
                            }
                            Text("Learn about Sheets")
                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                .lineLimit(1)
                            Spacer()
                            Text("\(Image(systemName: "chevron.forward"))")
                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                .opacity(0.4)
                                .padding(.trailing)
                        }
                        .foregroundStyle(.white)
                        .padding([.top, .bottom], horizontalSizeClass == .compact ? 10 : 20)
                        .background(Color.purple)
                        .cornerRadius(horizontalSizeClass == .compact ? 20 : 30)
                        .padding([.leading, .trailing])
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(destination: BoardTutorialView()) {
                        HStack {
                            ZStack {
                                Color.clear.frame(width: horizontalSizeClass == .compact ? 30 : 45, height: horizontalSizeClass == .compact ? 30 : 45)
                                    .padding()
                                Text("\(Image(systemName: "hand.tap"))")
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 45, weight: .bold, design: .rounded))
                                    .symbolRenderingMode(.hierarchical)
                                    .opacity(0.75)
                            }
                            Text("Learn about Board")
                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                .lineLimit(1)
                            Spacer()
                            Text("\(Image(systemName: "chevron.forward"))")
                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                .opacity(0.4)
                                .padding(.trailing)
                        }
                        .foregroundStyle(.white)
                        .padding([.top, .bottom], horizontalSizeClass == .compact ? 10 : 20)
                        .background(Color.orange)
                        .cornerRadius(horizontalSizeClass == .compact ? 20 : 30)
                        .padding([.leading, .trailing])
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .navigationBarTitle("", displayMode: .inline)
                
                Spacer()
                NavigationLink(destination: ContentView()) {
                    Text("\(Image(systemName: "checklist")) Begin Setup")
                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .padding(horizontalSizeClass == .compact ? 20 : 30)
                        .padding([.leading, .trailing])
                        .background(Color(.systemGray6))
                        .cornerRadius(horizontalSizeClass == .compact ? 15 : 30)
                        .symbolRenderingMode(.hierarchical)
                }
                .padding([.top, .bottom])
                .buttonStyle(PlainButtonStyle())
                .opacity(showSetup ? 1 : 0)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
        .statusBarHidden()
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
                withAnimation(.snappy) {
                    showSetup = true
                }
            }
        }
    }
}

struct SheetTutorialView: View {
    
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            TimeslotView()
                .tag(0)
                .onTapGesture {withAnimation{currentPage += 1}}
            AsyncView()
                .tag(1)
                .onTapGesture {withAnimation{currentPage += 1}}
            TryItView()
                .tag(2)
            ModIconView()
                .tag(3)
            ButtonsView()
                .tag(4)
                .onTapGesture {withAnimation{currentPage += 1}}
            GotItView()
                .tag(5)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}

struct BoardTutorialView: View { //main welcome page
    
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            IconView()
                .tag(0)
            TappedIconView()
                .tag(1)
            ButtonView()
                .tag(2)
            GotItView()
                .tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}

struct IconView: View {
    
    @StateObject private var speechDelegate = SpeechSynthesizerDelegate()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State var openFolder = false
    
    var body: some View {
        VStack {
            Text("\(Image(systemName: "hand.tap")) Folders and Icons")
                .minimumScaleFactor(0.01)
                .multilineTextAlignment(.center)
                .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .symbolRenderingMode(.hierarchical)
            Text("Your Communication Board has two main things: Folders and Icons. Daysy will speak aloud any Folder or Icon you tap.")
                .minimumScaleFactor(0.01)
                .multilineTextAlignment(.center)
                .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
            Spacer()
            Button(action: {
                speechDelegate.speak("School")
                openFolder.toggle()
            }) {
                VStack {
                    ZStack {
                        Image("school")
                            .resizable()
                            .scaledToFill()
                    }.mask(
                        Image(systemName: "folder.fill")
                            .resizable()
                            .scaledToFit()
                    )
                    .overlay(
                        ZStack {
                            Image(systemName: "folder")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.blue)
                            Image(systemName: "folder.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.blue)
                                .opacity(0.3)
                        }
                    )
                    Text("School")
                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 25, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                }
                    .frame(width: horizontalSizeClass == .compact ? 200 : 300, height: horizontalSizeClass == .compact ? 200 : 300)
                    .padding()
            }
            .buttonStyle(PlainButtonStyle())
            Button(action: {speechDelegate.speak("hello")}) {
                Image("hello")
                    .resizable()
                    .frame(width: horizontalSizeClass == .compact ? 200 : 300, height: horizontalSizeClass == .compact ? 200 : 300)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.black, lineWidth: 3)
                    )
                    .foregroundStyle(.primary)
                    .padding()
            }
            Spacer()
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
    }
}

struct TappedIconView: View {
    
    @StateObject private var speechDelegate = SpeechSynthesizerDelegate()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State var tappedIcons = activities
    @State var openFolder = false
    
    var body: some View {
        VStack {
            Text("\(Image(systemName: "square.stack.3d.down.right")) Tapped Icons")
                .minimumScaleFactor(0.01)
                .multilineTextAlignment(.center)
                .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .symbolRenderingMode(.hierarchical)
            Text("You can see all of the icons you have seelcted at the top of the screen. You can speak all of these icons, scroll through them, or clear them.")
                .minimumScaleFactor(0.01)
                .multilineTextAlignment(.center)
                .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
            Spacer()
            VStack {
                Text("View your Tapped Icons")
                    .minimumScaleFactor(0.01)
                    .multilineTextAlignment(.center)
                    .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text("\(Image(systemName: "arrow.left.arrow.right"))")
                    .minimumScaleFactor(0.01)
                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .symbolRenderingMode(.hierarchical)
            }.padding()
            HStack {
                Button(action: {
                    speechDelegate.speak("This button plays all of your tapped icons")
                }) {
                    Image(systemName: "play.square.fill")
                        .resizable()
                        .frame(width: horizontalSizeClass == .compact ? 50 : 100, height: horizontalSizeClass == .compact ? 50 : 100)
                        .foregroundStyle(.purple)
                        .symbolRenderingMode(.hierarchical)
                        .padding(.leading, 5)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(1..<tappedIcons.count, id: \.self) { icon in
                            Image(tappedIcons[icon])
                                .resizable()
                                .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.black, lineWidth: 3)
                                )
                                .padding(.trailing, 5)
                                .foregroundStyle(.primary)
                        }
                    }
                    .padding(.trailing, horizontalSizeClass == .compact ? 75 : 100)
                }
                Button(action: {
                    speechDelegate.speak("This button clears all of your tapped icons")
                }) {
                    Image(systemName: "delete.backward.fill")
                        .resizable()
                        .frame(width: horizontalSizeClass == .compact ? 57.5 : 115, height: horizontalSizeClass == .compact ? 50 : 100)
                        .foregroundStyle(.red)
                        .symbolRenderingMode(.hierarchical)
                        .padding(.trailing, 5)
                }
                
            }
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("\(Image(systemName: "arrow.up"))")
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                        .foregroundStyle(.purple)
                    Text("Speak your Tapped Icons")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                        .foregroundStyle(.purple)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(Image(systemName: "arrow.up"))")
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                        .foregroundStyle(.red)
                    Text("Clear your Tapped Icons")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                        .foregroundStyle(.red)
                }
            }.padding()
            Spacer()
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
    }
}

struct ButtonView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State var openMenu = false
    
    var body: some View {
        ZStack {
            if !openMenu {
                Text("Everything else you might need is in the bottom right corner. Tap it to learn more!")
                    .minimumScaleFactor(0.01)
                    .multilineTextAlignment(.center)
                    .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                    .padding()
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        HStack {
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Search")
                                    .font(.system(horizontalSizeClass == .compact ? .title3 : .largeTitle, design: .rounded))
                                    .fontWeight(.bold)
                                Text("Search through your Folders and Icons.")
                                    .font(.system(horizontalSizeClass == .compact ? .body : .headline, design: .rounded))
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        .foregroundStyle(.gray)
                        .frame(width: horizontalSizeClass == .compact ? 200 : 500, height: horizontalSizeClass == .compact ? 65 : 75)
                        
                        HStack {
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Type to Speak")
                                    .font(.system(horizontalSizeClass == .compact ? .title3 : .largeTitle, design: .rounded))
                                    .fontWeight(.bold)
                                Text("Type anything, and Daysy will speak it aloud.")
                                    .font(.system(horizontalSizeClass == .compact ? .body : .headline, design: .rounded))
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        .foregroundStyle(.gray)
                        .frame(width: horizontalSizeClass == .compact ? 200 : 500, height: horizontalSizeClass == .compact ? 65 : 75)
                        
                        HStack {
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Draw")
                                    .font(.system(horizontalSizeClass == .compact ? .title3 : .largeTitle, design: .rounded))
                                    .fontWeight(.bold)
                                Text("An open canvas to draw express yourself.")
                                    .font(.system(horizontalSizeClass == .compact ? .body : .headline, design: .rounded))
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        .foregroundStyle(.cyan)
                        .frame(width: horizontalSizeClass == .compact ? 200 : 500, height: horizontalSizeClass == .compact ? 65 : 75)
                        
                        HStack {
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Create Icon")
                                    .font(.system(horizontalSizeClass == .compact ? .title3 : .largeTitle, design: .rounded))
                                    .fontWeight(.bold)
                                Text("Create and add Icons to your Comunication Board.")
                                    .font(.system(horizontalSizeClass == .compact ? .body : .headline, design: .rounded))
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        .foregroundStyle(.green)
                        .frame(width: horizontalSizeClass == .compact ? 200 : 500, height: horizontalSizeClass == .compact ? 65 : 75)
                        
                        HStack {
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Create Folder")
                                    .font(.system(horizontalSizeClass == .compact ? .title3 : .largeTitle, design: .rounded))
                                    .fontWeight(.bold)
                                Text("Create and add Folders to your Communication Board.")
                                    .font(.system(horizontalSizeClass == .compact ? .body : .headline, design: .rounded))
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        .foregroundStyle(.blue)
                        .frame(width: horizontalSizeClass == .compact ? 200 : 500, height: horizontalSizeClass == .compact ? 65 : 75)
                        
                        HStack {
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Settings")
                                    .font(.system(horizontalSizeClass == .compact ? .title3 : .largeTitle, design: .rounded))
                                    .fontWeight(.bold)
                                Text("Customize Daysy to fit your personal needs and likes.")
                                    .font(.system(horizontalSizeClass == .compact ? .body : .headline, design: .rounded))
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        .foregroundStyle(.gray)
                        .frame(width: horizontalSizeClass == .compact ? 200 : 500, height: horizontalSizeClass == .compact ? 65 : 75)
                        
                        HStack {
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Sheets")
                                    .font(.system(horizontalSizeClass == .compact ? .title3 : .largeTitle, design: .rounded))
                                    .fontWeight(.bold)
                                Text("View all of your schedules and planned activities with Sheets.")
                                    .font(.system(horizontalSizeClass == .compact ? .body : .headline, design: .rounded))
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        .foregroundStyle(.purple)
                        .frame(width: horizontalSizeClass == .compact ? 200 : 500, height: horizontalSizeClass == .compact ? 65 : 75)
                        
                    }.opacity(openMenu ? 1.0 : 0.0)
                    if openMenu {
                        VStack {
                            Button(action: {
                                
                            }) {
                                VStack {
                                    ZStack {
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .frame(width: 65, height: 65)
                                            .foregroundStyle(.gray)
                                        Text("\(Image(systemName: "magnifyingglass"))")
                                            .font(.system(size: 30))
                                            .foregroundStyle(Color(.systemBackground))
                                    }
                                }
                            }
                            
                            Button(action: {
                                
                            }) {
                                VStack {
                                    ZStack {
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .frame(width: 65, height: 65)
                                            .foregroundStyle(.gray)
                                        Text("\(Image(systemName: "keyboard"))")
                                            .font(.system(size: 30))
                                            .foregroundStyle(Color(.systemBackground))
                                    }
                                }
                            }
                            
                            Button(action: {
                                
                            }) {
                                VStack {
                                    ZStack {
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .frame(width: 65, height: 65)
                                            .foregroundStyle(.cyan)
                                        Text("\(Image(systemName: "pencil.and.outline"))")
                                            .font(.system(size: 30))
                                            .foregroundStyle(Color(.systemBackground))
                                            .symbolRenderingMode(.hierarchical)
                                    }
                                }
                            }
                                Button(action: {
                                    
                                }) {
                                    VStack {
                                        ZStack {
                                            Image(systemName: "square.fill")
                                                .resizable()
                                                .frame(width: 65, height: 65)
                                                .foregroundStyle(.green)
                                            Text("\(Image(systemName: "plus.viewfinder"))")
                                                .font(.system(size: 30))
                                                .foregroundStyle(Color(.systemBackground))
                                                .symbolRenderingMode(.hierarchical)
                                        }
                                    }
                                }
                                
                                Button(action: {
                                    
                                }) {
                                    VStack {
                                        ZStack {
                                            Image(systemName: "square.fill")
                                                .resizable()
                                                .frame(width: 65, height: 65)
                                                .foregroundStyle(.blue)
                                            Text("\(Image(systemName: "folder.badge.plus"))")
                                                .font(.system(size: 30))
                                                .foregroundStyle(Color(.systemBackground))
                                        }
                                    }
                                }
                                
                                Button(action: {
                                    
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
                                    }
                                }
                                
                                Button(action: {
                                    
                                }) {
                                    VStack {
                                        ZStack {
                                            Image(systemName: "square.fill")
                                                .resizable()
                                                .frame(width: 65, height: 65)
                                                .foregroundStyle(.purple)
                                            Text("\(Image(systemName: "newspaper"))")
                                                .font(.system(size: 30))
                                                .foregroundStyle(Color(.systemBackground))
                                        }
                                    }
                                }
                        }
                        .transition(.move(edge: .trailing))
                        .padding()
                        .background(
                            .thinMaterial,
                            in: RoundedRectangle(cornerRadius: 20)
                        )
                    }
                }
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.snappy) {
                            openMenu.toggle()
                        }
                    }) {
                        ZStack {
                            Image(systemName: "square.fill")
                                .resizable()
                                .frame(width: horizontalSizeClass == .compact ? 65 : 75, height: horizontalSizeClass == .compact ? 65 : 75)
                                .foregroundStyle(.thickMaterial)
                                .shadow(color: Color(.systemBackground), radius: 15.0)
                            Text("\(Image(systemName: openMenu ? "menucard.fill" : "menucard"))")
                                .font(.system(size: horizontalSizeClass == .compact ? 30 : 40))
                                .foregroundStyle(.gray)
                                .symbolRenderingMode(openMenu ? .hierarchical : .monochrome)
                        }
                        .padding(.trailing)
                        .padding(.bottom, horizontalSizeClass == .compact ? 0 : 5)
                    }
                    .padding(.bottom)
                }
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .onTapGesture {
            withAnimation(.snappy) {
                openMenu.toggle()
            }
        }
    }
}

struct TimeslotView: View { //timeslot tutorial view
    @State var presentNext = false
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        VStack {
            Text("\(Image(systemName: "timer")) Timeslots")
                .lineLimit(1)
                .minimumScaleFactor(0.01)
                .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                .padding(horizontalSizeClass == .compact ? 5 : 15)
            Text("You can set up a Sheet using Timeslots. Daysy will automatically sort these to be in order, can show you the current Timeslot, and send you notifications.")
                .minimumScaleFactor(0.01)
                .multilineTextAlignment(.center)
                .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
            Spacer()
            //Divider()
            if horizontalSizeClass != .compact {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 5)) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray5))
                            .scaledToFit()
                        Text("12:00 PM")
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .font(.system(size: 300,  weight: .bold, design: .rounded))
                            .padding()
                            .foregroundStyle(.primary)
                    }
                    
                    Image("eatlunch")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.black, lineWidth: 6)
                        )
                    
                    Image("brownie")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.black, lineWidth: 6)
                        )
                    
                    Image("playground")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.black, lineWidth: 6)
                        )
                    
                    Image("school")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.black, lineWidth: 6)
                        )
                }
            } else {
                //iPhone grid here
                VStack {
                    Text("12:00 PM")
                        .lineLimit(1)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .padding(.top)
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                        Image("eatlunch")
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.black, lineWidth: 6)
                            )
                            .padding()
                        
                        Image("brownie")
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.black, lineWidth: 6)
                            )
                            .padding()
                        
                        Image("playground")
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.black, lineWidth: 6)
                            )
                            .padding()
                        
                        Image("school")
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.black, lineWidth: 6)
                            )
                            .padding()
                    }
                }
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding([.leading, .trailing])
                .padding([.leading, .trailing])
            }
            Spacer()
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
    }
}

struct AsyncView: View { //custom labels tutorial view
    @State var presentNext = false
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        VStack {
            Text("\(Image(systemName: "tag")) Custom Labels")
                .lineLimit(1)
                .minimumScaleFactor(0.01)
                .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                .padding(horizontalSizeClass == .compact ? 5 : 15)
            Text("You can also set up a Sheet that uses your own custom labels. These will not be sorted by Daysy.")
                .minimumScaleFactor(0.01)
                .multilineTextAlignment(.center)
                .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
            Spacer()
            //Divider()
            if horizontalSizeClass != .compact {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 5)) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray5))
                            .scaledToFit()
                        Text("Jared")
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .font(.system(size: 300,  weight: .bold, design: .rounded))
                            .padding()
                            .padding()
                            .foregroundStyle(.primary)
                    }
                    Image("putsockson")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.black, lineWidth: 6)
                        )
                    
                    Image("dog")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.black, lineWidth: 6)
                        )
                    
                    Image("lunch")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.black, lineWidth: 6)
                        )
                    
                    Image("cleanup")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.black, lineWidth: 6)
                        )
                }
            } else {
                //iPhone grid here
                VStack {
                    Text("Jared")
                        .lineLimit(1)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .padding(.top)
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                        Image("putsockson")
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.black, lineWidth: 6)
                            )
                            .padding()
                        
                        Image("dog")
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.black, lineWidth: 6)
                            )
                            .padding()
                        
                        Image("lunch")
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.black, lineWidth: 6)
                            )
                            .padding()
                        
                        Image("cleanup")
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.black, lineWidth: 6)
                            )
                            .padding()
                    }
                }
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding([.leading, .trailing])
                .padding([.leading, .trailing])
            }
            //Divider()
            Spacer()
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
    }
}

struct TryItView: View { //interactive little mini sheet to play with
    
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    enum PickerOption: String, CaseIterable {
        case timeslots = "Timeslots"
        case customLabels = "Custom Labels"
    }
    @State var selectedOption = PickerOption.timeslots
    
    @State var presentNext = false
    
    @State var showIcons = false
    @State var showTime = false
    @State var currTime = "0:00"
    @State var currLabel = "Label"
    @State var showLabels = false
    @State var currSetIndex = 0
    @State var currGrid = [Image(systemName:"plus.viewfinder"), Image(systemName:"plus.viewfinder"), Image(systemName:"plus.viewfinder"), Image(systemName:"plus.viewfinder"), Image(systemName:"plus.viewfinder"), Image(systemName:"plus.viewfinder"), Image(systemName:"plus.viewfinder"), Image(systemName:"plus.viewfinder")]
    var body: some View {
        VStack {
            Spacer()
            Text("Practice setting up! The example below is fully interactive. You can try setting a time, setting a custom label, as well as adding icons.")
                .minimumScaleFactor(0.01)
                .multilineTextAlignment(.center)
                .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                .padding()
            Spacer()
            //Divider()
            ZStack {
                if horizontalSizeClass != .compact {
                    VStack {
                        LazyVGrid(columns: Array(repeating: GridItem(), count: 5)) {
                            Button(action: {showTime.toggle()}) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(.systemGray5))
                                        .scaledToFit()
                                    HStack {
                                        Image(systemName: "square.and.pencil")
                                            .resizable()
                                            .minimumScaleFactor(0.01)
                                            .frame(width: 30, height: 30)
                                            .padding(.leading)
                                            .foregroundStyle(.gray)
                                        
                                        Text(currTime)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.01)
                                            .font(.system(size: 300,  weight: .bold, design: .rounded))
                                            .padding(.trailing)
                                            .foregroundStyle(.primary)
                                    }
                                }
                            }
                            .foregroundStyle(.primary)
                            ForEach(0..<4, id: \.self) { index in
                                Button(action:{
                                    currSetIndex = index
                                    showIcons.toggle()}) {
                                        if currGrid[index] == Image(systemName:"plus.viewfinder") {
                                            Image(systemName: "plus.viewfinder")
                                                .resizable()
                                                .scaledToFit()
                                                .symbolRenderingMode(.hierarchical)
                                                .foregroundStyle(.gray)
                                                .padding()
                                        } else {
                                            currGrid[index]
                                                .resizable()
                                                .scaledToFit()
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(.black, lineWidth: 6)
                                                )
                                                .padding(5)
                                                .transition(.asymmetric(insertion: .movingParts.iris(blurRadius: 50), removal: .movingParts.vanish(.purple)))
                                        }
                                    }
                                    .foregroundStyle(.primary)
                                    .buttonStyle(PlainButtonStyle())
                            }
                        }
                        Divider()
                        LazyVGrid(columns: Array(repeating: GridItem(), count: 5)) {
                            Button(action: {showLabels.toggle()}) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(.systemGray5))
                                        .scaledToFit()
                                    HStack {
                                        Image(systemName: "square.and.pencil")
                                            .resizable()
                                            .minimumScaleFactor(0.01)
                                            .frame(width: 30, height: 30)
                                            .padding(.leading)
                                            .foregroundStyle(.gray)
                                        
                                        Text(currLabel)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.01)
                                            .font(.system(size: 300,  weight: .bold, design: .rounded))
                                            .padding(.trailing)
                                            .foregroundStyle(.primary)
                                    }
                                }
                            }
                            .foregroundStyle(.primary)
                            .buttonStyle(PlainButtonStyle())
                            ForEach(4..<8, id: \.self) { index in
                                Button(action:{
                                    currSetIndex = index
                                    showIcons.toggle()}) {
                                        if currGrid[index] == Image(systemName:"plus.viewfinder") {
                                            Image(systemName: "plus.viewfinder")
                                                .resizable()
                                                .scaledToFit()
                                                .symbolRenderingMode(.hierarchical)
                                                .foregroundStyle(.gray)
                                                .padding()
                                        } else {
                                            currGrid[index]
                                                .resizable()
                                                .scaledToFit()
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(.black, lineWidth: 6)
                                                )
                                                .padding(5)
                                        }
                                    }
                                    .foregroundStyle(.primary)
                                    .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                } else {
                    //iPhone grid here
                    VStack {
                        Picker("Options", selection: $selectedOption) {
                            ForEach(PickerOption.allCases, id: \.self) { option in
                                Text(option.rawValue)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        if selectedOption == .timeslots {
                            VStack {
                                Button(action: {showTime.toggle()}) {
                                    HStack {
                                        Image(systemName: "square.and.pencil")
                                            .resizable()
                                            .minimumScaleFactor(0.01)
                                            .frame(width: 30, height: 30)
                                            .padding(.leading)
                                            .foregroundStyle(.gray)
                                        
                                        Text(currTime)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.01)
                                            .font(.system(size: 30,  weight: .bold, design: .rounded))
                                            .padding(.trailing)
                                            .foregroundStyle(.primary)
                                    }
                                    .padding(.top)
                                }
                                .buttonStyle(PlainButtonStyle())
                                LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                                    ForEach(0..<4, id: \.self) { index in
                                        Button(action:{
                                            currSetIndex = index
                                            showIcons.toggle()}) {
                                                if currGrid[index] == Image(systemName:"plus.viewfinder") {
                                                    Image(systemName: "plus.viewfinder")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .symbolRenderingMode(.hierarchical)
                                                        .foregroundStyle(.gray)
                                                        .padding()
                                                } else {
                                                    currGrid[index]
                                                        .resizable()
                                                        .scaledToFit()
                                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 20)
                                                                .stroke(.black, lineWidth: 6)
                                                        )
                                                        .padding(5)
                                                }
                                            }
                                            .foregroundStyle(.primary)
                                            .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding([.leading, .trailing])
                            .padding([.leading, .trailing])
                        } else if selectedOption == .customLabels {
                            VStack {
                                Button(action: {showLabels.toggle()}) {
                                    HStack {
                                        Image(systemName: "square.and.pencil")
                                            .resizable()
                                            .minimumScaleFactor(0.01)
                                            .frame(width: 30, height: 30)
                                            .padding(.leading)
                                            .foregroundStyle(.gray)
                                        
                                        Text(currLabel)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.01)
                                            .font(.system(size: 30,  weight: .bold, design: .rounded))
                                            .padding(.trailing)
                                            .foregroundStyle(.primary)
                                    }
                                    .padding(.top)
                                }
                                .buttonStyle(PlainButtonStyle())
                                LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                                    ForEach(4..<8, id: \.self) { index in
                                        Button(action:{
                                            currSetIndex = index
                                            showIcons.toggle()}) {
                                                if currGrid[index] == Image(systemName:"plus.viewfinder") {
                                                    Image(systemName: "plus.viewfinder")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .symbolRenderingMode(.hierarchical)
                                                        .foregroundStyle(.gray)
                                                        .padding()
                                                } else {
                                                    currGrid[index]
                                                        .resizable()
                                                        .scaledToFit()
                                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 20)
                                                                .stroke(.black, lineWidth: 6)
                                                        )
                                                        .padding(5)
                                                }
                                            }
                                            .foregroundStyle(.primary)
                                    }
                                }
                            }
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding([.leading, .trailing])
                            .padding([.leading, .trailing])
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showIcons) {
                
                AllIconsPickerView(currSheet: SheetObject(), //no sheet to provide tutorial,
                                   currImage: "plus.viewfinder",
                                   modifyIcon: { newIcon in
                    currGrid[currSetIndex] = Image(newIcon)
                }, modifyCustomIcon: {
                    //can't modify custom icons in tutorial
                }, modifyDetails: { newDetails in
                    //no need to modify details here
                }, onDismiss: {
                    showIcons.toggle()
                }, showCreateCustom: false,
                tutorialMode: true)

            }
            .sheet(isPresented: $showTime) {
                TimeLabelPickerView(viewType: .time, saveItem: { item in
                    if item is Date {
                        currTime = getTime(date: item as!Date)
                    }
                }, oldDate: Date(), oldLabel: $currLabel)
            }
            .sheet(isPresented: $showLabels) {
                TimeLabelPickerView(viewType: .label, saveItem: { item in
                    if item is String {
                        currLabel = item as!String
                    }
                }, oldLabel: $currLabel)
            }
            Spacer()
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
    }
}

struct ModIconView: View { //tutorial view on completing or removing icon
    @State var presentNext = false
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var showMod = false
    @State var currSetIndex = 0
    @State var isModded = false
    @State var imageArray = [Image("zipup"), Image("trumpet"), Image("sitcrisscross"), Image("playkeyboard")]
    var body: some View {
        VStack {
            if isModded {
                Text("You have removed an icon!")
                    .lineLimit(1)
                    .minimumScaleFactor(0.01)
                    .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                    .padding(horizontalSizeClass == .compact ? 5 : 15)
                Text("Good job. You will be able to view all your removed icons for all your Sheets, or an individual Sheet, after setup. You can try it again, or move on.")
                    .minimumScaleFactor(0.01)
                    .multilineTextAlignment(.center)
                    .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
            } else {
                Text("Remove Your Icons")
                    .lineLimit(1)
                    .minimumScaleFactor(0.01)
                    .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                    .padding(horizontalSizeClass == .compact ? 5 : 15)
                Text("After you’re done setting up, you can tap any icon to remove it from the Sheet. Try it!")
                    .minimumScaleFactor(0.01)
                    .multilineTextAlignment(.center)
                    .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
            }
            Spacer()
            //Divider()
            ZStack {
                if horizontalSizeClass != .compact {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 5)) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray5))
                            .scaledToFit()
                        ForEach(0..<imageArray.count, id: \.self) { index in
                            Button(action:{
                                showMod.toggle()
                                currSetIndex = index}) {
                                    if imageArray[index] != Image(systemName:"plus.viewfinder") {
                                        imageArray[index]
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(.black, lineWidth: 6)
                                            )
                                            .padding(5)
                                    }
                                }
                                .foregroundStyle(.primary)
                                .transition(.asymmetric(insertion: .movingParts.iris(blurRadius: 50), removal: .movingParts.vanish(.purple)))
                        }
                    }
                } else {
                    VStack {
                        Text("12:00 PM")
                            .lineLimit(1)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .padding(.top)
                        LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                            ForEach(0..<imageArray.count, id: \.self) { index in
                                Button(action:{
                                    showMod.toggle()
                                    currSetIndex = index}) {
                                        if imageArray[index] != Image(systemName:"plus.viewfinder") {
                                            imageArray[index]
                                                .resizable()
                                                .scaledToFit()
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(.black, lineWidth: 6)
                                                )
                                                .padding()
                                        }
                                    }
                                    .foregroundStyle(.primary)
                            }
                            if imageArray.count < 3 {
                                HStack {
                                    Image(systemName: "square.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(.clear)
                                        .padding()
                                }
                            }
                        }
                    }
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding([.leading, .trailing])
                    .padding([.leading, .trailing])
                }
            }
            .fullScreenCover(isPresented: $showMod) {
                VStack {
                    TutorialModView(currImageArray: $imageArray, currIndex: $currSetIndex)
                    HStack(alignment: .top) {
                        Button(action: {
                            showMod.toggle()
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
                        
                        Button(action: {
                            showMod.toggle()
                            isModded = true
                            imageArray.remove(at: currSetIndex)
                            hapticFeedback(type: 1)
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
                                Text("Remove Icon")
                                    .font(.system(size: horizontalSizeClass == .compact ? 15 : 25, weight: .semibold, design: .rounded))
                            }
                        }
                        .padding()
                        .foregroundStyle(.pink)
                    }
                }
            }
            
            Spacer()
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
    }
}

struct ButtonsView: View { //view describing the buttons on a sheet
    @State var presentNext = false
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Spacer()
                HStack {
                    ZStack {
                        Image(systemName: "square.fill")
                            .resizable()
                            .padding()
                            .frame(width: min(100, 200), height: min(100, 200))
                            .foregroundStyle(.orange)
                        Image(systemName: "hand.tap")
                            .resizable()
                            .frame(width: min(42, 104), height: min(48, 118))
                            .foregroundStyle(Color(.systemBackground))
                            .symbolRenderingMode(.hierarchical)
                    }
                    VStack(alignment: .leading) {
                        Text("Communication Board")
                            .font(.system(horizontalSizeClass == .compact ? .title3 : .largeTitle, design: .rounded))
                            .fontWeight(.bold)
                        Text("Tap to view your Communication Board.")
                            .font(.system(horizontalSizeClass == .compact ? .body : .headline, design: .rounded))
                            .foregroundStyle(horizontalSizeClass == .compact ? .gray : .primary)
                    }
                }
                .padding(horizontalSizeClass == .compact ? [.leading, .trailing] : [.top, .bottom, .leading, .trailing], 10)
                
                HStack {
                    ZStack {
                        Image(systemName: "square.fill")
                            .resizable()
                            .padding()
                            .frame(width: min(100, 200), height: min(100, 200))
                            .foregroundStyle(.blue)
                        Image(systemName: "pencil")
                            .resizable()
                            .frame(width: min(40, 100), height: min(40, 100))
                            .padding()
                            .foregroundStyle(Color(.systemBackground))
                    }
                    VStack(alignment: .leading) {
                        Text("Edit Sheet")
                            .font(.system(horizontalSizeClass == .compact ? .title3 : .largeTitle, design: .rounded))
                            .fontWeight(.bold)
                        Text("Tap to edit your current Sheet.")
                            .font(.system(horizontalSizeClass == .compact ? .body : .headline, design: .rounded))
                            .foregroundStyle(horizontalSizeClass == .compact ? .gray : .primary)
                    }
                }
                .padding(horizontalSizeClass == .compact ? [.leading, .trailing] : [.top, .bottom, .leading, .trailing], 10)
                
                HStack {
                    ZStack {
                        Image(systemName: "square.fill")
                            .resizable()
                            .padding()
                            .frame(width: min(100, 200), height: min(100, 200))
                            .foregroundStyle(.gray)
                        Image(systemName: "gear")
                            .resizable()
                            .frame(width: min(40, 100), height: min(40, 100))
                            .padding()
                            .foregroundStyle(Color(.systemBackground))
                    }
                    VStack(alignment: .leading) {
                        Text("Settings")
                            .font(.system(horizontalSizeClass == .compact ? .title3 : .largeTitle, design: .rounded))
                            .fontWeight(.bold)
                        Text("Customize Daysy to fit your personal needs and likes.")
                            .font(.system(horizontalSizeClass == .compact ? .body : .headline, design: .rounded))
                            .foregroundStyle(horizontalSizeClass == .compact ? .gray : .primary)
                    }
                }
                .padding(horizontalSizeClass == .compact ? [.leading, .trailing] : [.top, .bottom, .leading, .trailing], 10)
                
                HStack {
                    ZStack {
                        Image(systemName: "square.fill")
                            .resizable()
                            .padding()
                            .frame(width: min(100, 200), height: min(100, 200))
                            .foregroundStyle(.purple)
                        Image(systemName: "square.grid.2x2")
                            .resizable()
                            .frame(width: min(40, 100), height: min(40, 100))
                            .padding()
                            .foregroundStyle(Color(.systemBackground))
                    }
                    VStack(alignment: .leading) {
                        Text("View All Sheets")
                            .font(.system(horizontalSizeClass == .compact ? .title3 : .largeTitle, design: .rounded))
                            .fontWeight(.bold)
                        Text("Tap to view all your Sheets, and switch between them.")
                            .font(.system(horizontalSizeClass == .compact ? .body : .headline, design: .rounded))
                            .foregroundStyle(horizontalSizeClass == .compact ? .gray : .primary)
                    }
                }
                .padding(horizontalSizeClass == .compact ? [.leading, .trailing] : [.top, .bottom, .leading, .trailing], 10)
                
                HStack {
                    ZStack {
                        Image(systemName: "square.fill")
                            .resizable()
                            .padding()
                            .frame(width: min(100, 200), height: min(100, 200))
                            .foregroundStyle(.pink)
                        Image(systemName: "square.slash")
                            .resizable()
                            .frame(width: min(40, 100), height: min(40, 100))
                            .padding()
                            .foregroundStyle(Color(.systemBackground))
                            .symbolRenderingMode(.hierarchical)
                    }
                    VStack(alignment: .leading) {
                        Text("View Removed")
                            .font(.system(horizontalSizeClass == .compact ? .title3 : .largeTitle, design: .rounded))
                            .fontWeight(.bold)
                        Text("Tap to view all icons that were removed from your Sheets.")
                            .font(.system(horizontalSizeClass == .compact ? .body : .headline, design: .rounded))
                            .foregroundStyle(horizontalSizeClass == .compact ? .gray : .primary)
                    }
                }
                .padding(horizontalSizeClass == .compact ? [.leading, .trailing] : [.top, .bottom, .leading, .trailing], 10)
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .navigationBarTitle("", displayMode: .inline)
    }
}

struct GotItView: View { //confirmation to go back/create a sheet or to rewatch the tutorial
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Got all that?")
                    .lineLimit(1)
                    .minimumScaleFactor(0.01)
                    .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                    .padding(.leading)
                    .padding(.trailing)
                
                VStack {
                    NavigationLink(destination: SheetTutorialView()) {
                        HStack {
                            ZStack {
                                Color.clear.frame(width: horizontalSizeClass == .compact ? 30 : 45, height: horizontalSizeClass == .compact ? 30 : 45)
                                    .padding()
                                Text("\(Image(systemName: "newspaper"))")
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 45, weight: .bold, design: .rounded))
                                    .symbolRenderingMode(.hierarchical)
                                    .opacity(0.75)
                            }
                            Text("Learn about Sheets")
                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                .lineLimit(1)
                            Spacer()
                            Text("\(Image(systemName: "chevron.forward"))")
                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                .opacity(0.4)
                                .padding(.trailing)
                        }
                        .foregroundStyle(.white)
                        .padding([.top, .bottom], horizontalSizeClass == .compact ? 10 : 20)
                        .background(Color.purple)
                        .cornerRadius(horizontalSizeClass == .compact ? 20 : 30)
                        .padding([.leading, .trailing])
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(destination: BoardTutorialView()) {
                        HStack {
                            ZStack {
                                Color.clear.frame(width: horizontalSizeClass == .compact ? 30 : 45, height: horizontalSizeClass == .compact ? 30 : 45)
                                    .padding()
                                Text("\(Image(systemName: "hand.tap"))")
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 45, weight: .bold, design: .rounded))
                                    .symbolRenderingMode(.hierarchical)
                                    .opacity(0.75)
                            }
                            Text("Learn about Board")
                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                .lineLimit(1)
                            Spacer()
                            Text("\(Image(systemName: "chevron.forward"))")
                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                .opacity(0.4)
                                .padding(.trailing)
                        }
                        .foregroundStyle(.white)
                        .padding([.top, .bottom], horizontalSizeClass == .compact ? 10 : 20)
                        .background(Color.orange)
                        .cornerRadius(horizontalSizeClass == .compact ? 20 : 30)
                        .padding([.leading, .trailing])
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .navigationBarTitle("", displayMode: .inline)
                
                Divider().padding()
                
                if defaults.bool(forKey: "completedTutorial") {
                    NavigationLink(destination: ContentView()) {
                        Text(defaults.bool(forKey: "communicationDefaultMode") ? "\(Image(systemName: "hand.tap")) Return to Board" : "\(Image(systemName: "newspaper")) Return to Sheets")
                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .padding()
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(horizontalSizeClass == .compact ? 20 : 30)
                            .symbolRenderingMode(.hierarchical)
                    }
                    .padding()
                    .navigationViewStyle(StackNavigationViewStyle())
                    .navigationBarHidden(true)
                    .buttonStyle(PlainButtonStyle())
                } else {
                    NavigationLink(destination: ContentView()) {
                        Text("\(Image(systemName: "checklist")) Begin Setup")
                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .padding(horizontalSizeClass == .compact ? 20 : 30)
                            .padding([.leading, .trailing])
                            .background(Color(.systemGray5))
                            .cornerRadius(horizontalSizeClass == .compact ? 20 : 30)
                    }
                    .padding()
                    .navigationBarHidden(true)
                    .buttonStyle(PlainButtonStyle())
                }
                Spacer()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
    }
}

struct TutorialModView: View { //fix with binding variables to show the icon
    @Binding var currImageArray: [Image]
    @Binding var currIndex: Int
    var body: some View {
        if currIndex >= currImageArray.count {
            Image(systemName: "text.below.photo")
                .resizable()
                .scaledToFit()
                .padding()
        } else {
            currImageArray[currIndex]
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 40))
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(.black, lineWidth: 20)
                )
                .padding()
        }
    }
}

#Preview {
    WelcomeView()
}
