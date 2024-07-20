//
//  SupaTestView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 6/12/24.
//


import SwiftUI
import Foundation
import Combine
import Pow
import UniformTypeIdentifiers
import AVFoundation
import Supabase
import Charts
import SlideOverCard

struct SupaTestView: View {
    
    //actual variables ------
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var jsonAccounts: [JSONAccount] = []
    @State var accounts: [Account] = []
    @State var currError = ""
    @State var isLoading = true
    @State var animate = false
    
    
    @State private var first_name: String = ""
    @State private var last_name: String = ""
    @State private var user_name: String = ""
    @State private var email: String = ""
    
    var body: some View {
        
            Text("no")
        

        
        /*
        VStack {
            HStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .opacity(isLoading ? 1.0 : 0.0)
                Text("Accounts")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(isLoading ? .gray : Color.accentColor)
                    .symbolRenderingMode(.hierarchical)
                Spacer()
            }
            .padding()
            Text(currError)
                .foregroundStyle(.red)
                .font(.system(size: horizontalSizeClass == .compact ? 17 : 25, weight: .bold, design: .rounded))
                .padding(currError.isEmpty ? 0 : 10)
            ScrollView {
                if accounts.isEmpty {
                    if isLoading {
                        LoadingIndicator(color: Color.accentColor)
                    } else {
                        Text("there are no accounts, add an account from the button below")
                            .font(.headline)
                            .foregroundStyle(.gray)
                    }
                } else {
                    VStack {
                        ForEach(0..<accounts.count, id: \.self) { accountIndex in
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("\(accounts[accountIndex].first_name) \(accounts[accountIndex].last_name)")
                                            .font(.headline)
                                        Text("(\(accounts[accountIndex].user_name))")
                                            .font(.headline)
                                            .lineLimit(1)
                                            .foregroundStyle(Color.accentColor)
                                        
                                    }
                                    Text("\(getBackupTime(accounts[accountIndex].created_at!))")
                                        .font(.headline)
                                        .foregroundStyle(.gray)
                                }
                                Spacer()
                                Button(action: {
                                    withAnimation(.snappy) {
                                        isLoading = true
                                        accounts.remove(at: accountIndex)
                                        Task {
                                            await deleteAccount(account: jsonAccounts[accountIndex].id!)
                                        }
                                    }
                                }) {
                                    Text("\(Image(systemName: "trash.square.fill"))")
                                        .font(.largeTitle)
                                        .foregroundStyle(.red)
                                        .symbolRenderingMode(.hierarchical)
                                        .padding()
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(.systemGray6))
                            )
                        }
                    }
                    .scaledToFit()
                }
                Form {
                    Section(header: Text("Add New Account")) {
                        TextField("First Name", text: $first_name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Last Name", text: $last_name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Username", text: $user_name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                        
                        HStack {
                            Button(action: {
                                if first_name.isEmpty || last_name.isEmpty || user_name.isEmpty || email.isEmpty {
                                    currError = "please fill out all fields"
                                } else {
                                    isLoading = true
                                    currError = ""
                                    Task {
                                        await upsertAccount(first_name: first_name, last_name: last_name, user_name: user_name, email: email)
                                        //                                    accounts = await getData()
                                        first_name = ""
                                        last_name = ""
                                        user_name = ""
                                        email = ""
                                    }
                                }
                            }) {
                                Text("\(Image(systemName: "plus.app.fill"))")
                                    .padding()
                                    .font(.title2)
                            }
                            Button(action: {
                                isLoading = true
                                currError = ""
                                withAnimation(.snappy) {
                                    Task {
                                        await insertRandomAccount()
                                        first_name = ""
                                        last_name = ""
                                        user_name = ""
                                        email = ""
                                    }
                                }
                            }) {
                                Text("\(Image(systemName: "goforward.plus"))")
                                    .padding()
                                    .font(.title2)
                            }
                        }
                    }
                }
                .scaledToFit()
            }
            .padding()
        }
        .task {
            await setupRealtimeChannel()
        }
    }
    
    func setupRealtimeChannel() async {
        do {
            jsonAccounts = try await client
                .from("jsonaccounts")
                .select()
                .execute()
                .value
            //            withAnimation(.snappy) {
            var updatedAccounts: [Account] = []
            for jsonAccount in jsonAccounts {
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
                    updatedAccounts.append(account)
                }
            }
            
            // Then apply the animation to the update
            withAnimation(.snappy) {
                accounts = updatedAccounts
            }
            
            isLoading = false
        } catch {
            currSessionLog.append(error)
            isLoading = false
        }
        
        let channel = await client.realtimeV2.channel("public:jsonaccounts")
        
        
        let changes = await channel.postgresChange(
            AnyAction.self,
            schema: "public",
            table: "jsonaccounts"
        )
        
        
        await channel.subscribe()
        await currSessionLog.append("\(channel.status) to channel")
        
        for await change in changes {
            isLoading = true
            currSessionLog.append("detected change")
            //            currSessionLog.append(change.rawMessage.payload["data"]!)
            do {
                jsonAccounts = try await client
                    .from("jsonaccounts")
                    .select()
                    .execute()
                    .value
                // First decode and update accounts
                currSessionLog.append("updating account array")
                var updatedAccounts: [Account] = []
                for jsonAccount in jsonAccounts {
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
                        updatedAccounts.append(account)
                        currSessionLog.append("found and appended account")
                    }
                }
                
                // Then apply the animation to the update
                withAnimation(.snappy) {
                    accounts = updatedAccounts
                }
                
                isLoading = false
                currSessionLog.append("done updating")
            } catch {
                currSessionLog.append(error)
                isLoading = false
            }
        }
    }
    
    func insertRandomAccount() async -> Void {
        currSessionLog.append("generating random items")
        let first_name = allPECS.randomElement()!
        let last_name = allPECS.randomElement()!
        var user_name = "\(first_name)_\(last_name)"
        let password = accountEncryptionKey
        let email = "\(user_name)@apple.com"
        //    let sheetArray = loadSheetArray()
        //    let communicationBoard = defaultCommunicationBoard
        //    let usage = getUsage()
        //    let customPECSAddresses = getCustomPECSAddresses()
        
        accounts.append(Account(first_name: first_name, last_name: last_name, user_name: user_name, password: password, email: email, sheet_array: [], communication_board: [], usage: [], custom_pecs_addresses: [:], settings: [:], curr_voice_ratio: 0.0, curr_voice: "", custom_pecs_images: [:], created_at: Date()))
        currSessionLog.append("generating account")
        let jsonAccount = JSONAccount(first_name: first_name,
                                      last_name: last_name,
                                      user_name: user_name,
                                      password: password,
                                      email: email,
                                      sheet_array: try? encoder.encode(loadSheetArray()),
                                      communication_board: try? encoder.encode(loadCommunicationBoard()),
                                      usage: try? encoder.encode(getUsage()),
                                      custom_pecs_addresses: try? encoder.encode(getCustomPECSAddresses()),
                                      custom_pecs_images: try? encoder.encode(getCustomPECSImagesData()),
                                      settings: try? encoder.encode(getSettings()),
                                      curr_voice_ratio: defaults.double(forKey: "currVoiceRatio") == 0.0 ? 1.0 : defaults.double(forKey: "currVoiceRatio"),
                                      curr_voice: defaults.string(forKey: "currVoice") == nil ? "com.apple.ttsbundle.Daniel-compact" : defaults.string(forKey: "currVoice"),
                                      created_at: Date())
        currSessionLog.append("uploading account")
        do {
            try await client
                .from("jsonaccounts")
                .insert(jsonAccount)
                .execute()
        } catch {
            currSessionLog.append(error.localizedDescription)
            currError = error.localizedDescription
            isLoading = false
        }
    }
    
    func upsertAccount(first_name: String, last_name: String, user_name: String, email: String) async -> Void {
        let password = accountEncryptionKey
        //    let sheetArray = loadSheetArray()
        //    let communicationBoard = defaultCommunicationBoard
        //    let usage = getUsage()
        //    let customPECSAddresses = getCustomPECSAddresses()
        accounts.append(Account(first_name: first_name, last_name: last_name, user_name: user_name, password: password, email: email, sheet_array: [], communication_board: [], usage: [], custom_pecs_addresses: [:], settings: [:], curr_voice_ratio: 0.0, curr_voice: "", custom_pecs_images: [:], created_at: Date()))
        let jsonAccount = JSONAccount(first_name: first_name,
                                      last_name: last_name,
                                      user_name: user_name,
                                      password: password,
                                      email: email,
                                      sheet_array: try? encoder.encode(loadSheetArray()),
                                      communication_board: try? encoder.encode(loadCommunicationBoard()),
                                      usage: try? encoder.encode(getUsage()),
                                      custom_pecs_addresses: try? encoder.encode(getCustomPECSAddresses()),
                                      custom_pecs_images: try? encoder.encode(getCustomPECSImagesData()),
                                      settings: try? encoder.encode(getSettings()),
                                      curr_voice_ratio: defaults.double(forKey: "currVoiceRatio") ?? 1.0,
                                      curr_voice: defaults.string(forKey: "currVoice"),
                                      created_at: Date())
        do {
            try await client
                .from("jsonaccounts")
                .upsert(jsonAccount)
                .execute()
        } catch {
            currSessionLog.append(error.localizedDescription)
            currError = error.localizedDescription
            isLoading = false
        }
    }
    
    func deleteAccount(account: UUID) async -> Void {
        do {
            try await client
                .from("jsonaccounts")
                .delete()
                .eq("id", value: account)
                .execute()
        } catch {
            currSessionLog.append(error.localizedDescription)
            currError = error.localizedDescription
            isLoading = false
        }*/
    }
}

