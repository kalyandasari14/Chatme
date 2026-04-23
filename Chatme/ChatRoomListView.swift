//
//  ChatRoomListView.swift
//  Chatme
//
//  Created by kalyan on 3/30/26.
//

import SwiftUI
import FirebaseAuth


struct ChatRoomListView: View {
    
    @State var viewModel = ChatViewModel()
    @AppStorage("isSignedIn") private var isSignedIn = false
    
    
    var body: some View {
        NavigationStack{
            Group {
                if viewModel.chatRooms.isEmpty {
                    ContentUnavailableView(
                        "No Chat Rooms",
                        systemImage: "bubble.left.and.bubble.right",
                        description: Text("Create a chat room in Firebase to get started")
                    )
                } else {
                    List(viewModel.chatRooms) { room in
                        NavigationLink(value: room){
                            Text(room.name)
                        }
                    }
                }
            }
            .toolbar {
                Button("Sign Out") {
                    do {
                        try Auth.auth().signOut()
                        isSignedIn = false
                    } catch {
                        print("❌ Sign out error: \(error.localizedDescription)")
                    }
                }
            }
            .navigationTitle("Chat Rooms")
            .navigationDestination(for: ChatRoom.self) { chat in
                ChatMessagesView(room: chat)
            }
            .onAppear {
               
                viewModel.fetchChatRooms()
            }
        }
    }
}


#Preview {
    ChatRoomListView()
}

