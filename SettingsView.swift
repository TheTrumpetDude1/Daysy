//
//  SettingsView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 10/25/23.
//

import SwiftUI
import LocalAuthentication
import AVFoundation
import OpenAI
import StoreKit
import MessageUI

struct SettingsView: View {
    
    var onDismiss: () -> Void
    
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @StateObject private var volObserver = VolumeObserver()
    @StateObject private var speechDelegate = SpeechSynthesizerDelegate()
    
    
    @AppStorage("showCurrSlot") private var currSlotOn: Bool = false
    @AppStorage("emptyOn") private var emptyOn: Bool = false
    @AppStorage("toggleOn") private var toggleOn: Bool = false
    @AppStorage("statsOn") private var statsOn: Bool = false
    @AppStorage("currVoiceRatio") private var currVoiceRatio: Double = 1.0 
    @AppStorage("currVoice") private var currVoice: String = "com.apple.ttsbundle.Daniel-compact"
    @AppStorage("buttonsOn") private var buttonsOn: Bool = false
    @AppStorage("notificationsAllowed") private var notifsAllowed: Bool = false
    @AppStorage("notifsOn") private var notifsOn: Bool = false
    @AppStorage("aiOn") private var aiOn: Bool = false
    @AppStorage("speakOn") private var speakOn: Bool = false
    
    @State private var showNotifs = false
    @State private var showAlert = false
    
    @State var showButtons = false
    @State var exampleButtonsOn = false
    
    @State private var showSpeak = false
    @State private var suggestedLanguages = getSuggestedLanguages()
    @State private var otherLanguages = getOtherLanguages()
    @State private var aiLanguages = AudioSpeechQuery.AudioSpeechVoice.allCases
    @State private var currAiVoice = AudioSpeechQuery.AudioSpeechVoice(rawValue: defaults.string(forKey: "currAiVoice") ?? "")
    @State private var voiceRatioOptions: [String: Float] = ["Slowest" : 0.1, "Slow" : 0.4, "Normal" : 1.0, "Fast" : 1.1, "Fastest" : 1.3]
    
    @State private var showStats = false
    
    @State private var showBlank = false
    
    @State private var showEmpty = false
    @State private var exampleEmptyOn = false
    
    @State private var showCurrSlot = false
    @State private var exampleSlotOn = false
    
    @State private var showCustomPassword = false
    
    @State private var debugView = false
    @State private var statsView = false
    @State private var animate = false
    
    @State private var result: Result<MFMailComposeResult, Error>? = nil
    @State private var isShowingMailView = false
    @State var emailBody = "?"
    @State var isLoading = false
    
    var body: some View {
        
        let offSet: CGFloat = horizontalSizeClass == .compact ? 18 : 36
        
        NavigationView {
            ZStack {
                ScrollView(showsIndicators: false) {
                    HStack(alignment: horizontalSizeClass == .compact ? .top : .center) {
                        Text("\(Image(systemName: "gear")) Settings")
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                        if horizontalSizeClass == .compact {
                            Spacer()
                            Button(action: {
                                onDismiss()
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
                    /*
                     HStack {
                     Button(action: {
                     showAI.toggle()
                     }) {
                     HStack {
                     Image(systemName: "brain.filled.head.profile")
                     .minimumScaleFactor(0.5)
                     .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                     .foregroundStyle(Color.accentColor)
                     .symbolRenderingMode(.hierarchical)
                     Text(" OpenAI Features")
                     .lineLimit(1)
                     .minimumScaleFactor(0.01)
                     .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                     }
                     }
                     .foregroundStyle(.primary)
                     .padding()
                     Spacer()
                     ZStack {
                     Capsule()
                     .frame(width: horizontalSizeClass == .compact ? 80 : 160,height: horizontalSizeClass == .compact ? 44 : 88)
                     .foregroundStyle(aiOn ? Color.accentColor : Color(.systemGray3))
                     ZStack{
                     Circle()
                     .frame(width: horizontalSizeClass == .compact ? 40 : 80, height: horizontalSizeClass == .compact ? 40 : 80)
                     .foregroundStyle(.white)
                     Image(systemName: aiOn ? "poweron" : "poweroff")
                     .font( horizontalSizeClass == .compact ? Font.title3.weight(.black) : Font.largeTitle.weight(.black))
                     .foregroundStyle(.gray)
                     }
                     .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
                     .offset(x:aiOn ? offSet : -offSet)
                     .padding(horizontalSizeClass == .compact ? 0 : 24)
                     .animation(.snappy, value: animate)
                     }
                     .padding()
                     .onTapGesture {
                     aiOn.toggle()
                     defaults.set(aiOn, forKey: "aiOn")
                     animate.toggle()
                     }
                     }
                     .background(Color(.systemGray5))
                     .cornerRadius(horizontalSizeClass == .compact ? 20 : 30)
                     */
                    
                    HStack { //speak icons setting, same format as the rest below here
                        Button(action: {
                            showSpeak.toggle()
                        }) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .minimumScaleFactor(0.5)
                                    .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                                    .foregroundStyle(.blue)
                                Text(" Speak Aloud")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                            }
                        }
                        .foregroundStyle(.primary)
                        .padding()
                        Spacer()
                        ZStack {
                            Capsule()
                                .frame(width: horizontalSizeClass == .compact ? 80 : 160,height: horizontalSizeClass == .compact ? 44 : 88)
                                .foregroundStyle(speakOn ? .green : Color(.systemGray3))
                            ZStack{
                                Circle()
                                    .frame(width: horizontalSizeClass == .compact ? 40 : 80, height: horizontalSizeClass == .compact ? 40 : 80)
                                    .foregroundStyle(.white)
                                Image(systemName: speakOn ? "poweron" : "poweroff")
                                    .font( horizontalSizeClass == .compact ? Font.title3.weight(.black) : Font.largeTitle.weight(.black))
                                    .foregroundStyle(.gray)
                            }
                            .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
                            //.offset(x:exampleEmptyOn ? (horizontalSizeClass == .compact ? 18 : -18) : (horizontalSizeClass == .compact ? offSet : -offSet))
                            .offset(x:speakOn ? offSet : -offSet)
                            .padding(horizontalSizeClass == .compact ? 0 : 24)
                            .animation(.snappy, value: animate)
                        }
                        .padding()
                        .onTapGesture {
                            speakOn.toggle()
                            //                            defaults.set(speakOn, forKey: "speakOn")
                            animate.toggle()
                        }
                    }
                    .background(Color(.systemGray5))
                    .cornerRadius(horizontalSizeClass == .compact ? 20 : 30)
                    .onTapGesture(count: 8) {
                        statsView.toggle()
                    }
                    
                    HStack { //curr timeslot setting, same format as the rest below here
                        Button(action: {
                            showCurrSlot.toggle()
                        }) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                                    .foregroundStyle(.blue)
                                Text(horizontalSizeClass == .compact ? "Highlight Time" : " Show Current Timeslot")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                            }
                        }
                        .foregroundStyle(.primary)
                        .padding()
                        Spacer()
                        ZStack {
                            Capsule()
                                .frame(width: horizontalSizeClass == .compact ? 80 : 160,height: horizontalSizeClass == .compact ? 44 : 88)
                                .foregroundStyle(currSlotOn ? .green : Color(.systemGray3))
                            ZStack{
                                Circle()
                                    .frame(width: horizontalSizeClass == .compact ? 40 : 80, height: horizontalSizeClass == .compact ? 40 : 80)
                                    .foregroundStyle(.white)
                                Image(systemName: currSlotOn ? "poweron" : "poweroff")
                                    .font( horizontalSizeClass == .compact ? Font.title3.weight(.black) : Font.largeTitle.weight(.black))
                                    .foregroundStyle(.gray)
                            }
                            .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
                            .offset(x:currSlotOn ? offSet : -offSet)
                            .padding(horizontalSizeClass == .compact ? 0 : 24)
                            .animation(.snappy, value: animate)
                        }
                        .padding()
                        .onTapGesture {
                            currSlotOn.toggle()
                            //                            defaults.set(currSlotOn, forKey: "showCurrSlot")
                            animate.toggle()
                        }
                    }
                    .background(Color(.systemGray5))
                    .cornerRadius(horizontalSizeClass == .compact ? 20 : 30)
                    
                    HStack { //lock buttons setting, same format as the rest below here
                        Button(action: {
                            showButtons.toggle()
                        }) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                                    .foregroundStyle(.blue)
                                Text(" Lock Buttons")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                            }
                        }
                        .foregroundStyle(.primary)
                        .padding()
                        Spacer()
                        ZStack {
                            Capsule()
                                .frame(width: horizontalSizeClass == .compact ? 80 : 160,height: horizontalSizeClass == .compact ? 44 : 88)
                                .foregroundStyle(buttonsOn ? .green : Color(.systemGray3))
                            ZStack{
                                Circle()
                                    .frame(width: horizontalSizeClass == .compact ? 40 : 80, height: horizontalSizeClass == .compact ? 40 : 80)
                                    .foregroundStyle(.white)
                                Image(systemName: buttonsOn ? "poweron" : "poweroff")
                                    .font( horizontalSizeClass == .compact ? Font.title3.weight(.black) : Font.largeTitle.weight(.black))
                                    .foregroundStyle(.gray)
                            }
                            .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
                            .offset(x:buttonsOn ? offSet : -offSet)
                            .padding(horizontalSizeClass == .compact ? 0 : 24)
                            .animation(.snappy, value: animate)
                        }
                        .padding()
                        .onTapGesture {
                            Task {
                                let result = await authenticateWithBiometrics()
                                if result {
                                    withAnimation(.snappy) {
                                        buttonsOn.toggle()
                                    }
                                }
                                //                                defaults.set(buttonsOn, forKey: "buttonsOn")
                            }
                            if !canUseBiometrics() && !canUsePassword() {
                                showCustomPassword.toggle()
                            }
                        }
                    }
                    .background(Color(.systemGray5))
                    .cornerRadius(horizontalSizeClass == .compact ? 20 : 30)
                    
                    HStack { //notifs setting
                        Button(action: {
                            showNotifs.toggle()
                        }) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                                    .foregroundStyle(.blue)
                                Text(" Notifications")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                            }
                        }
                        .foregroundStyle(.primary)
                        .padding()
                        Spacer()
                        ZStack { //custom toggle
                            Capsule()
                                .frame(width: horizontalSizeClass == .compact ? 80 : 160,height: horizontalSizeClass == .compact ? 44 : 88)
                                .foregroundStyle(notifsOn ? .green : Color(.systemGray3))
                            ZStack{
                                Circle()
                                    .frame(width: horizontalSizeClass == .compact ? 40 : 80, height: horizontalSizeClass == .compact ? 40 : 80)
                                    .foregroundStyle(.white)
                                Image(systemName: notifsOn ? "poweron" : "poweroff")
                                    .font( horizontalSizeClass == .compact ? Font.title3.weight(.black) : Font.largeTitle.weight(.black))
                                    .foregroundStyle(.gray)
                            }
                            .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
                            .offset(x:notifsOn ? offSet : -offSet)
                            .padding(horizontalSizeClass == .compact ? 0 : 24)
                            .animation(.snappy, value: animate)
                        }
                        .padding()
                        .onTapGesture { //actions for the custom toggle
                            requestNotificationPermission()
                            if defaults.bool(forKey: "notificationsAllowed") {
                                animate.toggle()
                                notifsOn.toggle()
                                //                                defaults.set(notifsOn, forKey: "notifsOn")
                            } else {
                                notifsOn = false
                            }
                            showAlert = !defaults.bool(forKey: "notificationsAllowed")
                            manageNotifications()
                        }
                    }
                    .background(Color(.systemGray5))
                    .cornerRadius(horizontalSizeClass == .compact ? 20 : 30)
                    .onTapGesture(count: 8) {
                        debugView.toggle()
                    }
                    .alert(isPresented: $showAlert) { //cant turn on notifications if theyre not allowed
                        Alert(
                            title: Text("Notifications Disabled"),
                            message: Text("Daysy notifications have been disabled, please change this in your iPad Settings"),
                            primaryButton: .default(Text("Notification Settings").bold(), action: {
                                if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                                    UIApplication.shared.open(appSettings)
                                }
                                
                            }), secondaryButton: .cancel()
                        )
                    }
                    /*
                     HStack { //empty slots setting, same format as the rest below here
                     Button(action: {
                     showEmpty.toggle()
                     }) {
                     HStack {
                     Image(systemName: "info.circle")
                     .lineLimit(1)
                     .minimumScaleFactor(0.5)
                     .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                     .foregroundStyle(.blue)
                     Text(" Organize Slots")
                     .lineLimit(1)
                     .minimumScaleFactor(0.5)
                     .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                     }
                     }
                     .foregroundStyle(.primary)
                     .padding()
                     Spacer()
                     ZStack {
                     Capsule()
                     .frame(width: horizontalSizeClass == .compact ? 80 : 160,height: horizontalSizeClass == .compact ? 44 : 88)
                     .foregroundStyle(emptyOn ? .green : Color(.systemGray3))
                     ZStack{
                     Circle()
                     .frame(width: horizontalSizeClass == .compact ? 40 : 80, height: horizontalSizeClass == .compact ? 40 : 80)
                     .foregroundStyle(.white)
                     Image(systemName: emptyOn ? "poweron" : "poweroff")
                     .font( horizontalSizeClass == .compact ? Font.title3.weight(.black) : Font.largeTitle.weight(.black))
                     .foregroundStyle(.gray)
                     }
                     .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
                     .offset(x:emptyOn ? offSet : -offSet)
                     .padding(horizontalSizeClass == .compact ? 0 : 24)
                     .animation(.snappy, value: animate)
                     }
                     .padding()
                     .onTapGesture {
                     emptyOn.toggle()
                     //                            defaults.set(emptyOn, forKey: "emptyOn")
                     animate.toggle()
                     }
                     }
                     .background(Color(.systemGray5))
                     .cornerRadius(horizontalSizeClass == .compact ? 20 : 30)
                     */
                    Divider().padding()
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 150 : 250))], spacing: horizontalSizeClass == .compact ? 5 : 10) {
                        NavigationLink(destination: SheetTutorialView()) {
                            ZStack {
                                Image(systemName: "app.fill")
                                    .resizable()
                                    .foregroundStyle(Color.accentColor)
                                    .scaledToFit()
                                VStack {
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
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(5)
                                .foregroundStyle(.primary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: BoardTutorialView()) {
                            ZStack {
                                Image(systemName: "app.fill")
                                    .resizable()
                                    .foregroundStyle(.orange)
                                    .scaledToFit()
                                VStack {
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
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(5)
                                .foregroundStyle(.primary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        /*
                        NavigationLink(destination: FaceMeshView()) {
                            ZStack {
                                Image(systemName: "app.fill")
                                    .resizable()
                                    .foregroundStyle(.cyan)
                                    .scaledToFit()
                                VStack {
                                    ZStack {
                                        Color.clear.frame(width: horizontalSizeClass == .compact ? 30 : 45, height: horizontalSizeClass == .compact ? 30 : 45)
                                            .padding()
                                        Text("\(Image(systemName: "face.dashed"))")
                                            .font(.system(size: horizontalSizeClass == .compact ? 30 : 45, weight: .bold, design: .rounded))
                                            .symbolRenderingMode(.hierarchical)
                                            .opacity(0.75)
                                    }
                                    Text("Facial Decisions Beta")
                                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(5)
                                .foregroundStyle(.primary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        */
                        if !buttonsOn {
                            NavigationLink(destination: HiddenIconsView()) {
                                ZStack {
                                    Image(systemName: "app.fill")
                                        .resizable()
                                        .foregroundStyle(Color(.systemGray5))
                                        .scaledToFit()
                                    VStack {
                                        ZStack {
                                            Color.clear.frame(width: horizontalSizeClass == .compact ? 30 : 45, height: horizontalSizeClass == .compact ? 30 : 45)
                                                .padding()
                                            Text("\(Image(systemName: "eye.slash"))")
                                                .font(.system(size: horizontalSizeClass == .compact ? 30 : 45, weight: .bold, design: .rounded))
                                                .symbolRenderingMode(.hierarchical)
                                                .opacity(0.75)
                                        }
                                        Text("Hidden Icons")
                                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                            .lineLimit(2)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding(5)
                                    .foregroundStyle(.primary)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.bottom, 150)
                }
                .padding([.leading, .trailing])
                .ignoresSafeArea(.all)
                .animation(.default, value: animate)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        HStack { //bottom row of buttons for settings
                            if horizontalSizeClass != .compact {
                                Button(action: {
                                    onDismiss()
                                    self.presentation.wrappedValue.dismiss()
                                }) {
                                    HStack {
                                        Text("\(Image(systemName: "arrow.backward")) ")
                                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                            .lineLimit(1)
                                            .padding([.top, .bottom, .leading], horizontalSizeClass == .compact ? 5 : 10)
                                            .foregroundStyle(.gray)
                                        Text("Back")
                                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                            .lineLimit(1)
                                            .padding([.top, .bottom, .trailing], horizontalSizeClass == .compact ? 5 : 10)
                                            .foregroundStyle(.primary)
                                        
                                    }
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(horizontalSizeClass == .compact ? 20 : 25)
                                    
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            HStack {
                                Button(action: {
                                    isLoading = true
                                    systemInfoString(isHTML: true) { deviceInfo in
                                        emailBody = deviceInfo
                                        isShowingMailView = true
                                        isLoading = false
                                    }
                                }) {
                                    HStack {
                                        if isLoading {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle())
                                                .frame(width: horizontalSizeClass == .compact ? 20 : 25, height: horizontalSizeClass == .compact ? 20 : 25)
                                        } else {
                                            Text("\(Image(systemName: "exclamationmark.bubble")) ")
                                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                                .lineLimit(1)
                                                .padding([.top, .bottom, .leading], horizontalSizeClass == .compact ? 5 : 10)
                                                .foregroundStyle(Color.accentColor)
                                                .symbolRenderingMode(.hierarchical)
                                        }
                                        Text("Feedback")
                                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                            .lineLimit(1)
                                            .padding([.top, .bottom, .trailing], horizontalSizeClass == .compact ? 5 : 10)
                                            .foregroundStyle(.primary)
                                        
                                    }
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(horizontalSizeClass == .compact ? 20 : 25)
                                    
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: {
                                    if let windowScene = UIApplication.shared.connectedScenes
                                        .compactMap({ $0 as? UIWindowScene })
                                        .first {
                                        SKStoreReviewController.requestReview(in: windowScene)
                                    } else if let url = URL(string: "https://apps.apple.com/us/app/daysy/id6473222359") {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    }
                                }) {
                                    HStack {
                                        Text("\(Image(systemName: "star"))")
                                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                            .lineLimit(1)
                                            .padding([.top, .bottom, .leading], horizontalSizeClass == .compact ? 5 : 10)
                                            .foregroundStyle(.orange)
                                        Text("Review")
                                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                            .lineLimit(1)
                                            .padding([.top, .bottom, .trailing], horizontalSizeClass == .compact ? 5 : 10)
                                            .foregroundStyle(.primary)
                                        
                                    }
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(horizontalSizeClass == .compact ? 20 : 25)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .navigationBarTitle("", displayMode: .inline)
                        }
                        .navigationViewStyle(StackNavigationViewStyle())
                        .navigationBarHidden(true)
                        Spacer()
                    }
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color(.systemBackground), Color(.systemBackground),  Color.clear]), startPoint: .bottom, endPoint: .top)
                            .ignoresSafeArea()
                    )
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarHidden(true)
            .padding(.top)
            .fullScreenCover(isPresented: $debugView) {
                DebugView()
            }
            .fullScreenCover(isPresented: $statsView) {
                StatisticsView()
            }
            .sheet(isPresented: $isShowingMailView) {
                MailView(result: $result, email: "daysypecsapp@gmail.com", subject: "Daysy Feedback", body: $emailBody)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $showCustomPassword) { //set and/or verify custom password if bioauth and password not set
                CustomPasswordView(dismissSheet: { result in
                    withAnimation(.snappy) {
                        buttonsOn = result
                    }
                    showCustomPassword = false
                }, fromSettings: true)
            }
            .sheet(isPresented: $showNotifs) { //notifs details sheet
                VStack {
                    HStack(alignment: .top) {
                        VStack(alignment: horizontalSizeClass == .compact ? .leading : .center) {
                            Text("\(Image(systemName: "bell")) Notifications")
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                                .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                .padding(.top)
                                .padding(.bottom, horizontalSizeClass == .compact ? 5 : 0)
                            Text("When using Timeslots, Daysy will send you a notification if you have uncompleted icons, when when your next timeslot starts.")
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
                                showNotifs.toggle()
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
                    .padding(.top)
                    Spacer()
                    Button(action: {
                        if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                            UIApplication.shared.open(appSettings)
                        }
                    }) {
                        Text("\(Image(systemName: "gear")) Open Settings App")
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .padding()
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(horizontalSizeClass == .compact ? 20 : 30)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding()
                    Spacer()
                    if notifsAllowed {
                        Text("\(Image(systemName: "moon"))\nIf you are not seeing notifications, check Do Not Disturb or enable notifications in settings.")
                            .minimumScaleFactor(0.01)
                            .multilineTextAlignment(.center)
                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                            .foregroundStyle(.orange)
                            .padding()
                    } else {
                        Text("\(Image(systemName: "bell.slash"))\nDaysy notifications have been disabled, please change this in your iPad Settings")
                            .minimumScaleFactor(0.01)
                            .multilineTextAlignment(.center)
                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                            .foregroundStyle(.pink)
                            .padding()
                    }
                    Spacer()
                }
                .onAppear {
                    requestNotificationPermission()
                    if defaults.bool(forKey: "notificationsAllowed") {
                        notifsAllowed = true
                    }
                }
            }
            .sheet(isPresented: $showButtons) { //lock buttons details sheet
                VStack {
                    HStack(alignment: .top) {
                        VStack(alignment: horizontalSizeClass == .compact ? .leading : .center) {
                            Text("\(Image(systemName: "lock")) Lock Buttons")
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                                .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                .padding(.top)
                                .padding(.bottom, horizontalSizeClass == .compact ? 5 : 0)
                            Text("The buttons to remove an icon, and the bottom buttons on a Sheet will be locked.")
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
                                showButtons.toggle()
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
                    .padding(.top)
                    Spacer()
                    HStack {
                        Text("Try it: ")
                            .minimumScaleFactor(0.01)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .padding()
                        ZStack {
                            Capsule()
                                .frame(width: horizontalSizeClass == .compact ? 80 : 160,height: horizontalSizeClass == .compact ? 44 : 88)
                                .foregroundStyle(exampleButtonsOn ? .green : Color(.systemGray3))
                            ZStack{
                                Circle()
                                    .frame(width: horizontalSizeClass == .compact ? 40 : 80, height: horizontalSizeClass == .compact ? 40 : 80)
                                    .foregroundStyle(.white)
                                Image(systemName: exampleButtonsOn ? "poweron" : "poweroff")
                                    .font( horizontalSizeClass == .compact ? Font.title3.weight(.black) : Font.largeTitle.weight(.black))
                                    .foregroundStyle(.gray)
                            }
                            .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
                            //.offset(x:exampleEmptyOn ? (horizontalSizeClass == .compact ? 18 : -18) : (horizontalSizeClass == .compact ? offSet : -offSet))
                            .offset(x:exampleButtonsOn ? offSet : -offSet)
                            .padding(horizontalSizeClass == .compact ? 0 : 24)
                            .animation(.snappy, value: animate)
                        }
                        .padding()
                        .onTapGesture {
                            exampleButtonsOn.toggle()
                            animate.toggle()
                        }
                    }
                    if exampleButtonsOn {
                        Button(action: {}) {
                            Image(systemName: "lock.square")
                                .resizable()
                                .padding()
                                .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                .foregroundStyle(.gray)
                        }
                        .padding()
                    } else {
                        if horizontalSizeClass == .compact {
                            VStack {
                                HStack {
                                    Button(action: {}) {
                                        ZStack {
                                            Image(systemName: "square.fill")
                                                .resizable()
                                                .frame(width: 65, height: 65)
                                                .foregroundStyle(.orange)
                                            Image(systemName: "hand.tap")
                                                .resizable()
                                                .frame(width: min(30, 75), height: min(35, 85))
                                                .foregroundStyle(Color(.systemBackground))
                                                .symbolRenderingMode(.hierarchical)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.leading)
                                    .padding(.trailing)
                                    
                                    Button(action: {}) {
                                        ZStack {
                                            Image(systemName: "square.fill")
                                                .resizable()
                                                .frame(width: 65, height: 65)
                                                .foregroundStyle(.blue)
                                            Image(systemName: "pencil")
                                                .resizable()
                                                .frame(width: min(30, 75), height: min(30, 75))
                                            //.fontWeight(.heavy)
                                                .foregroundStyle(Color(.systemBackground))
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding()
                                    
                                    Button(action: {}) {
                                        ZStack {
                                            Image(systemName: "square")
                                                .resizable()
                                                .frame(width: 65, height: 65)
                                            Image(systemName: "chevron.forward")
                                                .resizable()
                                                .frame(width: 20, height: 40)
                                                .rotationEffect(.degrees(90))
                                        }
                                    }
                                    .foregroundStyle(Color(.systemGray2))
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.leading)
                                    .padding(.trailing)
                                    
                                }
                                HStack {
                                    HStack {
                                        Button(action: {}) {
                                            ZStack {
                                                Image(systemName: "square.fill")
                                                    .resizable()
                                                    .frame(width: 65, height: 65)
                                                    .foregroundStyle(Color.accentColor)
                                                Image(systemName: "square.grid.2x2")
                                                    .resizable()
                                                    .frame(width: min(30, 75), height: min(30, 75))
                                                    .foregroundStyle(Color(.systemBackground))
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(.leading)
                                        .padding(.trailing)
                                        
                                        Button(action: {}) {
                                            ZStack {
                                                Image(systemName: "square.fill")
                                                    .resizable()
                                                    .frame(width: 65, height: 65)
                                                    .foregroundStyle(.pink)
                                                Image(systemName: "square.slash")
                                                    .resizable()
                                                    .frame(width: min(30, 75), height: min(30, 75))
                                                    .foregroundStyle(Color(.systemBackground))
                                                    .symbolRenderingMode(.hierarchical)
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding([.leading, .trailing])
                                        
                                        Button(action: {}) {
                                            ZStack {
                                                Image(systemName: "square.fill")
                                                    .resizable()
                                                    .frame(width: 65, height: 65)
                                                    .foregroundStyle(.gray)
                                                Image(systemName: "gear")
                                                    .resizable()
                                                    .frame(width: min(30, 75), height: min(30, 75))
                                                    .foregroundStyle(Color(.systemBackground))
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding([.leading, .trailing])
                                    }
                                }
                            }
                        } else {
                            HStack {
                                Button(action: {}) {
                                    ZStack {
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .frame(width: 75, height: 75)
                                            .foregroundStyle(.orange)
                                        Image(systemName: "hand.tap")
                                            .resizable()
                                            .frame(width: min(40, 100), height: min(60, 130))
                                            .foregroundStyle(Color(.systemBackground))
                                            .symbolRenderingMode(.hierarchical)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding()
                                
                                Button(action: {}) {
                                    ZStack {
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .frame(width: 75, height: 75)
                                            .foregroundStyle(.pink)
                                        Image(systemName: "square.slash")
                                            .resizable()
                                            .frame(width: min(40, 100), height: min(40, 100))
                                            .foregroundStyle(Color(.systemBackground))
                                            .symbolRenderingMode(.hierarchical)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding()
                                
                                Button(action: {}) {
                                    ZStack {
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .frame(width: 75, height: 75)
                                            .foregroundStyle(Color.accentColor)
                                        Image(systemName: "square.grid.2x2")
                                            .resizable()
                                            .frame(width: min(40, 100), height: min(40, 100))
                                            .foregroundStyle(Color(.systemBackground))
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding()
                                
                                Button(action: {}) {
                                    ZStack {
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .frame(width: 75, height: 75)
                                            .foregroundStyle(.gray)
                                        Image(systemName: "gear")
                                            .resizable()
                                            .frame(width: min(40, 100), height: min(40, 100))
                                            .foregroundStyle(Color(.systemBackground))
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding()
                                
                                Button(action: {}) {
                                    ZStack {
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .frame(width: 75, height: 75)
                                            .foregroundStyle(.blue)
                                        Image(systemName: "pencil")
                                            .resizable()
                                            .frame(width: min(40, 100), height: min(40, 100))
                                        //.fontWeight(.heavy)
                                            .foregroundStyle(Color(.systemBackground))
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding()
                            }
                            .padding()
                        }
                    }
                    Spacer()
                }
                .animation(.snappy, value: animate)
            }
            .sheet(isPresented: $showSpeak) { //speak icons details sheet
                VStack {
                    HStack(alignment: .top) {
                        VStack(alignment: horizontalSizeClass == .compact ? .leading : .center) {
                            Text("\(Image(systemName: "waveform")) Speak Aloud")
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                                .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                .padding(.top)
                                .padding(.bottom, horizontalSizeClass == .compact ? 5 : 0)
                            Text("When you tap an icon, Daysy will speak the name of the icon out loud.")
                                .minimumScaleFactor(0.01)
                                .font(.system(size: horizontalSizeClass == .compact ? 17 : 25, weight: .bold, design: .rounded))
                                .foregroundStyle(.gray)
                                .multilineTextAlignment(horizontalSizeClass == .compact ? .leading : .center)
                                .padding(.bottom)
                        }
                        .padding(.leading, horizontalSizeClass == .compact ? 15 : 0)
                        if horizontalSizeClass == .compact {
                            Spacer()
                            Button(action: {
                                showSpeak.toggle()
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
                    .padding(.top)
                    Spacer()
                    Text("Choose your voice:")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                        .padding()
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 100 : 150))], spacing: horizontalSizeClass == .compact ? 10 : 20) {
                        //                        if defaults.bool(forKey: "aiOn") && isConnectedToInternet() {
                        //                            ForEach(aiLanguages, id: \.self) { voice in
                        //                                Button(action: {
                        //                                    currAiVoice = voice
                        //                                    defaults.set(voice.rawValue, forKey: "currAiVoice")
                        //                                    speak("Hello, I'm \(voice.rawValue)")
                        //                                }) {
                        //                                    ZStack {
                        //                                        RoundedRectangle(cornerRadius: 10)
                        //                                            .fill(currAiVoice == voice ? Color.accentColor : Color(.systemGray5))
                        //                                            .aspectRatio(2, contentMode: .fit)
                        //                                        HStack {
                        //                                            if currAiVoice == voice  {
                        //                                                Text("\(Image(systemName: "checkmark.circle.fill"))")
                        //                                                    .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                        //                                                    .foregroundStyle(.white)
                        //                                            } else {
                        //                                                Text("\(Image(systemName: "circle"))")
                        //                                                    .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                        //                                                    .foregroundStyle(.gray)
                        //                                            }
                        //                                            Text(voice.rawValue.capitalized)
                        //                                                .font(.system(size: horizontalSizeClass == .compact ? 15 : 25, weight: .bold, design: .rounded))
                        //                                                .foregroundStyle(currAiVoice == voice  ? .white : .gray)
                        //                                                .lineLimit(1)
                        //                                                .minimumScaleFactor(0.1)
                        //                                                .opacity(currAiVoice == voice ? 1.0 : 0.8)
                        //                                        }
                        //                                        .padding(horizontalSizeClass == .compact ? 5 : 10)
                        //                                    }
                        //                                }
                        //                            }
                        //                        } else {
                        ForEach(suggestedLanguages, id: \.self) { item in
                            Button(action: {
                                currVoice = item[2]
                                //                                    defaults.set(item[2], forKey: "currVoice")
                                suggestedLanguages = getSuggestedLanguages()
                                otherLanguages = getOtherLanguages()
                                
                                speechDelegate.stopSpeaking()
                                speechDelegate.speak("Hello, I'm \(item[1])")
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(currVoice == item[2] ? Color.accentColor : Color(.systemGray5))
                                        .aspectRatio(2, contentMode: .fit)
                                    HStack {
                                        if currVoice == item[2] {
                                            Text("\(Image(systemName: "checkmark.circle.fill"))")
                                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                                .foregroundStyle(.white)
                                        } else {
                                            Text("\(Image(systemName: "circle"))")
                                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                                .foregroundStyle(.gray)
                                        }
                                        VStack(alignment: .leading) {
                                            Text(item[1])
                                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                                .foregroundStyle(currVoice == item[2] ? .white : .primary)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.1)
                                            Text(languageNames[item[0]]!)
                                                .font(.system(size: horizontalSizeClass == .compact ? 15 : 25, weight: .bold, design: .rounded))
                                                .foregroundStyle(currVoice == item[2] ? .white : .gray)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.1)
                                                .opacity(currVoice == item[2] ? 0.8 : 1.0)
                                        }
                                    }
                                    .padding(horizontalSizeClass == .compact ? 5 : 10)
                                }
                            }
                        }
                        //                        }
                    }
                    .padding()
                    Text("Speed:")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: horizontalSizeClass == .compact ? 10 : 20) {
                            ForEach(voiceRatioOptions.sorted(by: { $0.value < $1.value }), id: \.value) { key, value in
                                Button(action: {
                                    currVoiceRatio = Double(value)
                                    speechDelegate.stopSpeaking()
                                    if key == "Slowest" || key == "Fastest" {
                                        speechDelegate.speak("This is the \(key) I can speak")
                                    } else {
                                        speechDelegate.speak("I am speaking \(key)")
                                    }
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(currVoiceRatio == Double(value) ? Color.accentColor : Color(.systemGray5))
                                            .aspectRatio(2, contentMode: .fit)
                                        HStack {
                                            if currVoiceRatio == Double(value) {
                                                Text("\(Image(systemName: "checkmark.circle.fill"))")
                                                    .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                                    .foregroundStyle(.white)
                                            } else {
                                                Text("\(Image(systemName: "circle"))")
                                                    .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                                    .foregroundStyle(.gray)
                                            }
                                            Text(key)
                                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                                .foregroundStyle(currVoiceRatio == Double(value) ? .white : .primary)
                                                .minimumScaleFactor(0.1)
                                                .lineLimit(1)
                                                .opacity(currVoiceRatio == Double(value) ? 1.0 : 0.8)
                                        }
                                        .padding(horizontalSizeClass == .compact ? 5 : 10)
                                    }
                                }
                            }
                        }
                    }
                    .padding([.leading, .trailing])
                    Spacer()
                }
            }
            .sheet(isPresented: $showEmpty) { //empty slots detail view
                VStack {
                    HStack(alignment: .top) {
                        VStack(alignment: horizontalSizeClass == .compact ? .leading : .center) {
                            Text("\(Image(systemName: "rectangle.stack")) Organize")
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                                .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                .padding(.top)
                                .padding(.bottom, horizontalSizeClass == .compact ? 5 : 0)
                            Text("Daysy will automatically remove empty Slots from your Sheet, and organize the remaining icons.")
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
                                showEmpty.toggle()
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
                    .padding(.top)
                    Spacer()
                    if horizontalSizeClass != .compact {
                        HStack {
                            Text("Try it: ")
                                .minimumScaleFactor(0.01)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .padding()
                            ZStack {
                                Capsule()
                                    .frame(width: horizontalSizeClass == .compact ? 80 : 160,height: horizontalSizeClass == .compact ? 44 : 88)
                                    .foregroundStyle(exampleEmptyOn ? .green : .gray)
                                ZStack{
                                    Circle()
                                        .frame(width: horizontalSizeClass == .compact ? 40 : 80, height: horizontalSizeClass == .compact ? 40 : 80)
                                        .foregroundStyle(.white)
                                    Image(systemName: exampleEmptyOn ? "poweron" : "poweroff")
                                        .font( horizontalSizeClass == .compact ? Font.title3.weight(.black) : Font.largeTitle.weight(.black))
                                        .foregroundStyle(.gray)
                                }
                                .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
                                .offset(x:exampleEmptyOn ? offSet : -offSet)
                                .padding(horizontalSizeClass == .compact ? 0 : 24)
                            }
                            .onTapGesture {
                                exampleEmptyOn.toggle()
                                animate.toggle()
                            }
                        }
                        Spacer()
                        if exampleEmptyOn {
                            LazyVGrid(columns: Array(repeating: GridItem(), count: 5)) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.systemGray5))
                                        .scaledToFit()
                                    Text("Recess")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.01)
                                        .font(.system(size: 300, weight: .bold, design: .rounded))
                                        .padding()
                                        .foregroundStyle(.primary)
                                }
                                Image("putsockson")
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.black, lineWidth: 4)
                                    )
                                Image("dog")
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.black, lineWidth: 4)
                                    )
                                Image("cleanup")
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.black, lineWidth: 4)
                                    )
                                Image(systemName: "square.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color(.clear))
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(exampleSlotOn ? .green : Color(.systemGray5))
                                        .scaledToFit()
                                    Text("Home")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.01)
                                        .font(.system(size: 300, weight: .bold, design: .rounded))
                                        .padding()
                                        .foregroundStyle(.primary)
                                }
                                Image("brownie")
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(exampleSlotOn ? .green : .black, lineWidth: exampleSlotOn ? 7 : 4)
                                    )
                                Image("eatlunch")
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(exampleSlotOn ? .green : .black, lineWidth: exampleSlotOn ? 7 : 4)
                                    )
                                Image(systemName: "square.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color(.clear))
                                Image(systemName: "square.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color(.clear))
                                ZStack {
                                    Text("")
                                }
                                Image(systemName: "square.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color(.clear))
                                Image(systemName: "square.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color(.clear))
                                Image(systemName: "square.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color(.clear))
                                Image(systemName: "square.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color(.clear))
                            }
                        } else {
                            LazyVGrid(columns: Array(repeating: GridItem(), count: 5)) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.systemGray5))
                                        .scaledToFit()
                                    Text("Recess")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.01)
                                        .font(.system(size: 300, weight: .bold, design: .rounded))
                                        .padding()
                                        .foregroundStyle(.primary)
                                }
                                Image(systemName: "square.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color(.clear))
                                Image("putsockson")
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.black, lineWidth: 4)
                                    )
                                Image("dog")
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.black, lineWidth: 4)
                                    )
                                Image("cleanup")
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.black, lineWidth: 4)
                                    )
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.systemGray5))
                                        .scaledToFit()
                                    Text("Afternoon")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.01)
                                        .font(.system(size: 300, weight: .bold, design: .rounded))
                                        .padding()
                                        .foregroundStyle(.primary)
                                }
                                Image(systemName: "square.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color(.clear))
                                Image(systemName: "square.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color(.clear))
                                Image(systemName: "square.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color(.clear))
                                Image(systemName: "square.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color(.clear))
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(exampleSlotOn ? .green : Color(.systemGray5))
                                        .scaledToFit()
                                    Text("Home")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.01)
                                        .font(.system(size: 300, weight: .bold, design: .rounded))
                                        .padding()
                                        .foregroundStyle(.primary)
                                }
                                Image("brownie")
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(exampleSlotOn ? .green : .black, lineWidth: exampleSlotOn ? 7 : 4)
                                    )
                                Image(systemName: "square.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color(.clear))
                                Image("eatlunch")
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(exampleSlotOn ? .green : .black, lineWidth: exampleSlotOn ? 7 : 4)
                                    )
                                Image(systemName: "square.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color(.clear))
                            }
                        }
                    } else {
                        VStack {
                            Text("\(Image(systemName: "signpost.left"))")
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                                .font(.system(size: 50, weight: .bold, design: .rounded))
                                .padding()
                                .foregroundStyle(Color.accentColor)
                                .opacity(0.4)
                            Text("Interactive Graphics and more details are coming soon!")
                                .minimumScaleFactor(0.01)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.accentColor)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }
                    Spacer()
                }
            }
            .sheet(isPresented: $showCurrSlot) { //show curr timeslot detail view
                VStack {
                    HStack(alignment: .top) {
                        VStack(alignment: horizontalSizeClass == .compact ? .leading : .center) {
                            Text(horizontalSizeClass == .compact ? "\(Image(systemName: "rectangle.lefthalf.inset.filled.arrow.left")) Highlight Time" : "\(Image(systemName: "rectangle.lefthalf.inset.filled.arrow.left")) Show Current Timeslot")
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                                .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                .padding(.top)
                                .padding(.bottom, horizontalSizeClass == .compact ? 5 : 0)
                            Text("When viewing a sheet with Timeslots, Daysy will highlight the currently active Timeslot in green, making it easier to identify.")
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
                                showCurrSlot.toggle()
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
                    .padding(.top)
                    Spacer()
                    HStack {
                        Text("Try it: ")
                            .minimumScaleFactor(0.01)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .padding()
                        ZStack {
                            Capsule()
                                .frame(width: horizontalSizeClass == .compact ? 80 : 160,height: horizontalSizeClass == .compact ? 44 : 88)
                                .foregroundStyle(exampleSlotOn ? .green : Color(.systemGray3))
                            ZStack{
                                Circle()
                                    .frame(width: horizontalSizeClass == .compact ? 40 : 80, height: horizontalSizeClass == .compact ? 40 : 80)
                                    .foregroundStyle(.white)
                                Image(systemName: exampleSlotOn ? "poweron" : "poweroff")
                                    .font( horizontalSizeClass == .compact ? Font.title3.weight(.black) : Font.largeTitle.weight(.black))
                                    .foregroundStyle(.gray)
                            }
                            .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
                            //.offset(x:exampleEmptyOn ? (horizontalSizeClass == .compact ? 18 : -18) : (horizontalSizeClass == .compact ? offSet : -offSet))
                            .offset(x:exampleSlotOn ? offSet : -offSet)
                            .padding(horizontalSizeClass == .compact ? 0 : 24)
                            .animation(.snappy, value: animate)
                        }
                        .onTapGesture {
                            exampleSlotOn.toggle()
                            animate.toggle()
                        }
                    }
                    Spacer()
                    //Divider()
                    if horizontalSizeClass == .compact {
                        VStack {
                            Text(getTime(date: getDateTwoHoursPrior(from: getCurrentTimeRoundedToHalfHour())))
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
                        .background(exampleSlotOn ? .green : Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding([.leading, .trailing])
                        .padding([.leading, .trailing])
                    } else {
                        LazyVGrid(columns: Array(repeating: GridItem(), count: 5)) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemGray5))
                                    .scaledToFit()
                                Text(getTime(date: getDateTwoHoursPrior(from: getCurrentTimeRoundedToHalfHour())))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: 300, weight: .bold, design: .rounded))
                                    .padding()
                                    .foregroundStyle(.primary)
                            }
                            Image("putsockson")
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.black, lineWidth: 4)
                                )
                            Image("dog")
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.black, lineWidth: 4)
                                )
                            Image("lunch")
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.black, lineWidth: 4)
                                )
                            Image("cleanup")
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.black, lineWidth: 4)
                                )
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(exampleSlotOn ? .green : Color(.systemGray5))
                                    .scaledToFit()
                                Text(getTime(date: getCurrentTimeRoundedToHalfHour()))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: 300, weight: .bold, design: .rounded))
                                    .padding()
                                    .foregroundStyle(.primary)
                                    .shadow(color: exampleSlotOn ? Color(.systemBackground) : Color.clear, radius: 5)
                            }
                            Image("eatlunch")
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(exampleSlotOn ? .green : .black, lineWidth: exampleSlotOn ? 7 : 4)
                                )
                            Image("brownie")
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(exampleSlotOn ? .green : .black, lineWidth: exampleSlotOn ? 7 : 4)
                                )
                            Image("playground")
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(exampleSlotOn ? .green : .black, lineWidth: exampleSlotOn ? 7 : 4)
                                )
                            Image("school")
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(exampleSlotOn ? .green : .black, lineWidth: exampleSlotOn ? 7 : 4)
                                )
                        }
                        //Divider()
                    }
                    Spacer()
                }
                .animation(.snappy, value: animate)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
    }
}

struct CustomToggleStyle: ToggleStyle { //for the custom toggle switches
    var size: CGSize = CGSize(width: 50, height: 30)
    
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            RoundedRectangle(cornerRadius: size.height / 2)
                .fill(configuration.isOn ? Color.green : .gray)
                .frame(width: size.width, height: size.height)
                .overlay(
                    RoundedRectangle(cornerRadius: size.height / 2)
                        .stroke(Color.white, lineWidth: 4)
                )
        }
    }
}
