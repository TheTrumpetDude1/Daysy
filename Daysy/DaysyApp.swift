//
//  DaysyApp.swift
//  Daysy
//
//  Created by Alexander Eischeid on 10/19/23.
//

import SwiftUI
import Supabase

@main
struct DaysyApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            //             DebugView()
            // /*
            if defaults.bool(forKey: "completedTutorial") {
                ContentView()
                    .task {
                        do {
                            try await client.auth.signInAnonymously()
                            updateUsage("action:open")
                        } catch {
                            currSessionLog.append(error.localizedDescription)
                        }
                    }
            } else {
                WelcomeView()
                    .task {
                        do {
                            try await client.auth.signInAnonymously()
                            updateUsage("action:open")
                        } catch {
                            currSessionLog.append(error.localizedDescription)
                        }
                    }
            }
            // */
        }
        .onChange(of: scenePhase) { newScenePhase in
            if newScenePhase == .active {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }
    }
}
