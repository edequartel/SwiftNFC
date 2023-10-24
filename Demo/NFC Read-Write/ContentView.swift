//
//  ContentView.swift
//  NFC Read-Write
//
//  Created by Ming on 1/1/2023.
//

import SwiftUI
import SwiftNFC
import Subsonic

struct ContentView: View {
    // MARK: - You can use either Reader / Writer or both in your application.
    @ObservedObject var NFCR = NFCReader()
    @ObservedObject var NFCW = NFCWriter()
    
    @StateObject private var sound = SubsonicPlayer(sound: "tap-resonant.aif")
    
    // MARK: - Editor for I/O Message
    var editor: some View {
        TextEditor(text: $NFCR.msg)
            .font(.title)
            .padding(.top, 50)
            .padding(15)
//            .background(Color.gray.opacity(0.5))
    }
    // MARK: - Show Read Message Raw Data
    var editorRaw: some View {
        TextEditor(text: $NFCR.raw)
            .padding(15)
//            .background(Color.red.opacity(0.5))
    }
    
    // MARK: - Detect whether the keyboard shown on screen or not.
    @State var keyboard: Bool = false
    
    // MARK: - Main App Content
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                    editor
                        .scrollContentBackground(.hidden)
//                    option
//                    editorRaw
//                        .scrollContentBackground(.hidden)
                
                VStack{
                Slider(value: $sound.volume)
                    HStack(spacing: 50) {
                        Button("Start") {
                            sound.play()
                        }
                        Button("Stop") {
                            sound.stop()
                        }
                    }
                    .padding(10)
                }
                .padding(20)
                
                
            }
            action
                .frame(height: 40)
        }
//        .ignoresSafeArea(.all)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            keyboard = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboard = false
        }
        .onTapGesture(count: 2) {
            // MARK: Double Tap anywhere can hide the keyboard
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    // MARK: - Select NFC Option(s)
    @AppStorage("type") private var type = "T"
    var option: some View {
        HStack {
            Picker(selection: $type, label: Text("Type Picker")) {
                Text("Text").tag("T")
                Text("Link").tag("U")
            }
            .onAppear {
                NFCW.type = type
            }
            .onChange(of: type) { newType in
                NFCW.type = newType
            }
            Spacer()
            if keyboard {
                Button(action: {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Text("Close Keyboard")
                }
            }
        }.padding(.horizontal)
    }
    
    // MARK: - Action Buttons
    var action: some View {
        HStack(spacing: 50) {
            Button (action: { read() }) {
                    Label("Read", systemImage: "wave.3.left.circle.fill")

            }
            Button (action: { write() }) {
                    Label("Write", systemImage: "wave.3.left.circle.fill")
                }
        }
    }
    
    // MARK: - Sample I/O Functions
    func read() {
        NFCR.read()
    }

    func write() {
        NFCW.msg = NFCR.msg
        NFCW.write()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
