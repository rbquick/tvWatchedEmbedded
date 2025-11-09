//
//  myButtonStyle.swift
//  tvWatchedEmbedded
//
//  Created by Brian Quick on 2025-11-08.
//

import SwiftUI
struct myButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 100, height: 37)
            .background(configuration.isPressed ? Color.gray.opacity(0.4) : Color.clear) // Gray background while pressed
                        .foregroundColor(configuration.isPressed ? Color.white : Color.black)      // White text when pressed, black otherwise
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0) // Optional pressed effect    }
    }
}
