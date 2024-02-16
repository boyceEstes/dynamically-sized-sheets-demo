//
//  ContentView.swift
//  DynamicallySizedSheets
//
//  Created by Boyce Estes on 2/16/24.
//

import SwiftUI


struct ContentView: View {
    
    @State private var presentSheet = false
    @State private var sheetHeight: CGFloat = .zero
    
    var body: some View {
        VStack {
            Text("Is that World??")
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Button("Start conversation with World") {
                presentSheet = true
            }
        }
        .padding()
        .sheet(isPresented: $presentSheet, content: {

//            GeometryReader(content: { proxy in
//                ScrollView {
                    sheetyChatContent()//(size: proxy.size)
                    .background(Color.red)
//                }
//            })
            .presentationCornerRadius(30)
            .presentationDetents(sheetHeight == .zero ? [.medium] : [.height(sheetHeight)])
        })
    }
    
    
    func sheetyChatContent() -> some View {
        
        NavigationStack {
            VStack {
                Text("Hello World")
                    .messageBackground()
                Text("You're looking good. You come to this solar system often?")
                    .messageBackground()
                Text("Thank you for noticing. I've been doing something different with my dirt")
                    .messageBackground(isYou: false)
                Text("And no. Here for a little worlds-trip")
                    .messageBackground(isYou: false)
            }
            .padding(.horizontal)
            .padding(.vertical)
            .navigationTitle("Hello, World")
            .heightChangePreference(completion: { height in
                print("height: \(height)")
                sheetHeight = height
            })
        }
    }
}


extension View {
    
    func messageBackground(isYou: Bool = true) -> some View {
        
        modifier(MessageBackground(isYou: isYou))
    }
}

struct MessageBackground: ViewModifier {
    
    let isYou: Bool
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(isYou ? Color.blue : Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
            .frame(maxWidth: .infinity, alignment: isYou ? .trailing : .leading)
    }
}

#Preview {
    ContentView()
}
