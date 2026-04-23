//
//  chatViewModel.swift
//  Chatme
//
//  Created by kalyan on 4/7/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth


@Observable


class ChatViewModel{
    var chatRooms: [ChatRoom] = []
    var messages: [Message] = []
    var isLoading = false
    var errorMessage = ""
    
    func fetchChatRooms() {
        let db = Firestore.firestore()
        
        db.collection("chatRooms").getDocuments { snapshot, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            Task { @MainActor in
                let rooms = snapshot?.documents.compactMap { document -> ChatRoom? in
                    var room = try? document.data(as: ChatRoom.self)
                    room?.id = document.documentID  // ← Add this line to set the correct ID
                    print("✅ Room: \(room?.name ?? ""), ID: \(document.documentID)")  // Debug print
                    return room
                }
                
                print("Fetched \(rooms?.count ?? 0) rooms")
                self.chatRooms = rooms ?? []
            }
        }
    }
    
    func fetchMessages(for roomId: String) {
        print("📩 Starting to fetch messages for room: \(roomId)")
        let db = Firestore.firestore()
        
        // Real-time listener for messages
        db.collection("chatRooms")
            .document(roomId)
            .collection("messages")
            .order(by: "timestamp", descending: false)  // Oldest first
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error fetching messages: \(error.localizedDescription)")
                    return
                }
                
                print("✅ Got message snapshot with \(snapshot?.documents.count ?? 0) documents")
                
                Task { @MainActor in
                    let fetchedMessages = snapshot?.documents.compactMap { document -> Message? in
                        print("📄 Message Document ID: \(document.documentID), Data: \(document.data())")
                        
                        do {
                            let message = try document.data(as: Message.self)
                            print("✅ Successfully decoded message: \(message.text)")
                            return message
                        } catch {
                            print("❌ Failed to decode message \(document.documentID): \(error)")
                            return nil
                        }
                    } ?? []
                    
                    print("📊 Fetched \(fetchedMessages.count) messages")
                    self.messages = fetchedMessages
                }
            }
    }
    
    func sendMessage(to roomId: String, text: String) {
        guard let user = Auth.auth().currentUser else {
            print("❌ No user signed in")
            return
        }
        
        let db = Firestore.firestore()
        
        let messageData: [String: Any] = [
            "text": text,
            "senderId": user.uid,
            "name": user.displayName ?? "Unknown",
            "photoUrl": user.photoURL?.absoluteString ?? "",
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("chatRooms")
            .document(roomId)
            .collection("messages")
            .addDocument(data: messageData) { error in
                if let error = error {
                    print("❌ Error sending message: \(error)")
                } else {
                    print("✅ Message sent!")
                }
            }
    }
}
