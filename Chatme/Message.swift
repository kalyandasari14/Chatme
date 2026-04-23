//
//  Message.swift
//  Chatme
//
//  Created by kalyan on 3/30/26.
//

import Foundation
import FirebaseFirestore


struct Message: Identifiable, Codable{
    @DocumentID var id: String?
    var text: String
    var senderId: String
    var name: String
    var photoUrl: String?
    var timestamp: Date
    
}


struct ChatRoom: Identifiable, Codable, Hashable{
    
    @DocumentID var id: String?
    var name: String
    var createdAt: Date
}
