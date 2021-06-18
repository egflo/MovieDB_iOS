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
    @StateObject private var user = User()
    @StateObject var movie_api = MovieDB_API()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(user)
                .environmentObject(movie_api)

        }
    }
}
