//
//  ChatModel.swift
//  Hey Gemini
//
//  Created by Alex Logan on 14/12/2023.
//

import Foundation
import GoogleGenerativeAI

@Observable class ChatModel {
    private let model: GenerativeModel
    var chats: [ChatMessage] = []
    
    init() {
        model  = .init(
            name: "gemini-pro",
            apiKey: "nicetry"
        )
    }
    
    // doesn't work in the uk yet 😭
    func send(text: String) {
        Task {
            await MainActor.run {
                chats.append(
                    .init(content: text, type: .sent)
                )
            }
            // for animation purposes. remove for better perf :)
            try? await Task.sleep(for: .milliseconds(300))
            do {
                await MainActor.run {
                    chats.append(.loadingMessage)
                }
                let response = try await model.generateContent(text)
                await MainActor.run {
                    chats[chats.endIndex-1] = .init(content: response.text ?? "", type: .recieved)
                }
            }
        }
    }
}
