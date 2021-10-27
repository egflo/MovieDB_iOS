//
//  MovieDBApp.swift
//  MovieDB
//
//  Created by Emmanuel Flores on 5/15/21.
//

import SwiftUI

@main
struct MovieDBApp: App {
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var user = UserData()
    @StateObject private var alert = AlertViewModel()
    @StateObject private var popoverAlert = PopoverViewModel()

    var body: some Scene {
        WindowGroup {
                ContentView()
                                
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(user)
            .environmentObject(alert)
            .environmentObject(popoverAlert)

        }
    
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                print("background")
            }
            if phase == .inactive {
                print("inactive")

            }
            if phase == .active {
                print("active")

            }
        }
        
        
    }
}
