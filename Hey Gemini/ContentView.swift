//
//  ContentView.swift
//  Hey Gemini
//
//  Created by Alex Logan on 14/12/2023.
//

import SwiftUI

struct ContentView: View {
    @State var selectedMessage: UUID? = nil
    @State var text: String = ""
    @State var model: ChatModel = .init()
    
    @FocusState private var focusedField: FocusedField?
    
    enum FocusedField {
        case message
    }

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(model.chats, id: \.id) { chat in
                    ChatBubble(message: chat)
                        .transition(
                            .opacity.combined(with: .scale(scale: 0.9, anchor: chat.type == .sent ? .topTrailing : .topLeading))
                        )
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .trailing)
            .scrollTargetLayout()
            .padding(.bottom, 60)
        }
        .animation(.bouncy, value: model.chats)
        .safeAreaInset(edge: .bottom, content: {
            textField
        })
        .scrollBounceBehavior(.basedOnSize)
        //.defaultScrollAnchor(.bottom)
        .scrollPosition(id: $selectedMessage, anchor: .bottom)
        .fontDesign(.rounded)
        .buttonStyle(BasicSquishyButtonStyle())
        .onChange(of: model.chats) {
            selectedMessage = model.chats.last?.id
        }
        .animation(.snappy, value: selectedMessage)
    }
    
    var textField: some View {
        HStack {
            TextField(text: $text, axis: .horizontal, label: { EmptyView() })
                .frame(maxWidth: .infinity)
                .padding(8)
                .focused($focusedField, equals: .message)
                .font(.headline)
                .fontWeight(.medium)
            
            if !text.isEmpty {
                Button(action: {
                    send()
                }, label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.headline)
                        .foregroundStyle(Color.teal)
                })
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.bouncy, value: text)
        .padding(.horizontal, 8)
        .background(Color.slightlyOffWhite, in: Capsule())
        .onAppear {
            focusedField = .message
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .padding()
        .background(
            Rectangle()
                .foregroundStyle(Color(uiColor: .systemBackground))
                .edgesIgnoringSafeArea(.bottom)
        )
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    func send() {
        model.send(text: text)
        text = ""
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        content
            .font(.subheadline.weight(.semibold))
            .multilineTextAlignment(message.type.textAlignment)
            .padding()
            .background(
                message.type.backgroundColor, in: RoundedRectangle(cornerRadius: 12)
            )
            .frame(maxWidth: .infinity, alignment: message.type.alignment)
            .foregroundStyle(message.type.foregroundColor)
    }
    
    @ViewBuilder
    var content: some View {
        if message == .loadingMessage {
            ProgressView()
        } else {
            Text(message.content)
        }
    }
}

struct ChatMessage: Identifiable, Hashable {
    let id: UUID = .init()
    let content: String
    let type: BubbleType
    
    static let loadingMessage = ChatMessage(content: "loading", type: .recieved)
    
    enum BubbleType {
        case sent, recieved
        
        var backgroundColor: Color {
            switch self {
            case .sent:
                return Color.accentColor
            case .recieved:
                return Color.slightlyOffWhite
            }
        }
        
        
        var foregroundColor: Color {
            switch self {
            case .sent:
                return Color.white
            case .recieved:
                return Color.primary
            }
        }
        
        var alignment: Alignment {
            switch self {
            case .sent:
                return .trailing
            case .recieved:
                return .leading
            }
        }
    
        var textAlignment: TextAlignment {
            switch self {
            case .sent:
                return .trailing
            case .recieved:
                return .leading
            }
        }
    }
}


#Preview {
    ContentView()
}

struct BasicSquishyButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.bouncy, value: configuration.isPressed)
    }
}
