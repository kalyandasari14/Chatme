//
//  ChatmeApp.swift
//  Chatme
//
//  Created by kalyan on 3/30/26.
//

import SwiftUI
import FirebaseCore

@main
struct ChatmeApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            SignInView()
        }
    }
}
