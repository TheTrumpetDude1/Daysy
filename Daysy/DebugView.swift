//
//  DebugView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 10/28/23.
//

import SwiftUI

struct DebugView: View {
    
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    let currAppGrid = allPECS
    @State var tutorialView = false
    @State var password = ""
    @State var showAlert = false
    @State var showLog = false
    @State var shareSheet = false
    @State var exportItem: Binding<UIImage>?
    @State var items = [UIImage(named: "hello")!]
    @State var importing = false
    
    private let devPassword = "071321!"
    
    var body: some View {
        VStack {
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
                Text("\(Image(systemName: "lock.open")) Developer Access Granted")
                    .minimumScaleFactor(0.01)
                    .multilineTextAlignment(.center)
                    .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                    .padding()
            }
        }
        .navigationBarHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
        if password == devPassword {
            ScrollView {
                VStack {
                    Text("Total Sheets")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                        .padding()
                    Text("\(loadSheetArray().count - 1)")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                }
                Divider()
                    .padding()
                VStack {
                    Text("Total Default Icons")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                        .padding()
                    Text("\(allPECS.count)")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                }
                Divider()
                    .padding()
                VStack {
                    Text("Total Custom Icons")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                        .padding()
                    Text("\(getCustomPECSAddresses().count)")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                }
                Divider()
                    .padding()
                VStack {
                    Text("Notification Permission")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                        .padding()
                    Text("\(String(defaults.bool(forKey : "notificationsAllowed")))")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                }
                Divider()
                    .padding()
                VStack {
                    Text("Camera Permission")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                        .padding()
                    Text("\(hasCameraPermission())")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                }
                Divider()
                    .padding()
                VStack {
                    Text("Total Usage")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                        .padding()
                    Text("\(getUsage().count)")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                }
                Divider()
                    .padding()
                VStack {
                    Text("Biometric Auth Available")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                        .padding()
                    Text("\(String(isBiometricAuthenticationAvailable()))")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                }
                Divider()
                    .padding()
                VStack {
                    Text("Password Auth Available")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                        .padding()
                    Text("\(String(isPasswordAuthenticationAvailable()))")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                }
                Divider()
                    .padding()
                VStack {
                    Text("Custom Password")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                        .padding()
                    if let customPassword = defaults.string(forKey: "customPassword") {
                        Text("\(customPassword)")
                            .minimumScaleFactor(0.01)
                            .multilineTextAlignment(.center)
                            .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .semibold, design: .rounded))
                            .foregroundColor(.gray)
                    } else {
                        Text("Password Not Set")
                            .minimumScaleFactor(0.01)
                            .multilineTextAlignment(.center)
                            .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .semibold, design: .rounded))
                            .foregroundColor(.gray)
                    }
                }
                Divider()
                    .padding()
                VStack {
                    Text("Completed Tutorial")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                        .padding()
                    Text("\(String(defaults.bool(forKey: "completedTutorial")))")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                }
                Divider()
                    .padding()
                VStack {
                    Text("Connected To Internet")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                        .padding()
                    Text("\(isConnectedToInternet())")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                }
                Divider()
                    .padding()
                VStack {
                    Text("Communication Board Items")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                        .padding()
                    Text("\(loadCommunicationBoard().count)")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                }
                Divider()
                    .padding()
                VStack {
                    Text("Total Removed Icons")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                        .padding()
                    Text("\(getAllRemoved().count)")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                }
                Divider()
                    .padding()
                VStack {
                    Text("Documents Folder Location")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                        .padding()
                    Text("\(documentsURL)")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                }
                Divider()
                    .padding()
                VStack {
                    Text("Items in Documents")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                        .padding()
                    Text("\(String(countItemsInDocuments()))")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                }
                Divider()
                    .padding()
                //                SupaTestView()
                VStack {
                    HStack {
                        Button(action: {
                            showLog.toggle()
                        }) {
                            Text("\(Image(systemName: "list.bullet.rectangle.portrait")) View Log")
                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                .lineLimit(1)
                                .padding([.top, .bottom, .trailing], horizontalSizeClass == .compact ? 5 : 10)
                                .padding()
                                .foregroundStyle(.green)
                        }
                        .background(.ultraThinMaterial)
                        .cornerRadius(horizontalSizeClass == .compact ? 20 : 25)
                        
                        Button(action: {
                            showAlert.toggle()
                        }) {
                            Text("\(Image(systemName: "trash")) Reset Daysy")
                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                .lineLimit(1)
                                .padding([.top, .bottom, .trailing], horizontalSizeClass == .compact ? 5 : 10)
                                .padding()
                        }
                        .foregroundStyle(.red)
                        .background(.red.opacity(0.2))
                        .cornerRadius(horizontalSizeClass == .compact ? 20 : 25)
                    }
                    
                    HStack {
                        
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
                        Button(action: {
                            shareSheet.toggle()
                        }) {
                            Text("\(Image(systemName: "square.and.arrow.up")) Share")
                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                .lineLimit(1)
                                .padding([.top, .bottom, .trailing], horizontalSizeClass == .compact ? 5 : 10)
                                .padding()
                        }
                        .background(.ultraThinMaterial)
                        .cornerRadius(horizontalSizeClass == .compact ? 20 : 25)
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .sheet(isPresented: $shareSheet) {
                ActivityViewController(activityItems: items)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $showLog) {
                ScrollView {
                    Text("Current Session Log")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                        .padding()
                    VStack {
                        ForEach(0..<currSessionLog.count, id: \.self) { index in
                            VStack {
                                Text("\(currSessionLog[index])")
                                    .minimumScaleFactor(0.01)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                    .foregroundColor(.gray)
                                Divider()
                                    .padding(.leading)
                                    .padding(.trailing)
                            }
                        }
                    }
                    Spacer()
                }
                .padding()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Reset Daysy?"),
                    message: Text("This will reset Daysy UserDefaults and clear Documents. Please close Daysy afterwards."),
                    primaryButton: .cancel(),
                    secondaryButton: .destructive(Text("Reset")) {
                        defaults.removePersistentDomain(forName: domain)
                        clearDocumentsDirectory()
                    }
                )
            }
        }
    }
}
