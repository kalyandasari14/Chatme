//
//  ChatMessagesView.swift
//  Chatme
//
//  Created by kalyan on 4/7/26.
//

import SwiftUI

struct ChatMessagesView: View {
    var room: ChatRoom
    @State var viewModel = ChatViewModel()
    @State private var newMessageText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages list
            List(viewModel.messages) { message in
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.text)
                        .font(.body)
                    Text("\(message.name) · \(message.timestamp.formatted(date: .omitted, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Input area
            HStack(spacing: 12) {
                TextField("Message", text: $newMessageText)
                    .textFieldStyle(.roundedBorder)
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                }
                .disabled(newMessageText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .navigationTitle(room.name)
        .onAppear {
            viewModel.fetchMessages(for: room.id ?? "")
        }
    }
    
    func sendMessage() {
        let trimmedText = newMessageText.trimmingCharacters(in: .whitespaces)
        guard !trimmedText.isEmpty else { return }
        
        viewModel.sendMessage(to: room.id!, text: trimmedText)
        newMessageText = ""
    }
}

#Preview {
    NavigationStack {
        ChatMessagesView(room: ChatRoom(id: "1", name: "iOS Developers", createdAt: Date()))
    }
}
