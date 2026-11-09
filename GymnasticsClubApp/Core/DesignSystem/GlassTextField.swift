//
//  GlassTextField.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/18/26.
//


import SwiftUI

enum GlassTextFieldType {
    case text
    case numeric
}

struct GlassTextField: View {

    let title: String

    @Binding
    var text: String

    let icon: String

    let color: Color

    var type: GlassTextFieldType = .text

    var body: some View {

        HStack(spacing: 14) {

            Image(systemName: icon)

                .font(.title3)

                .foregroundStyle(color.gradient)

                .frame(width: 24)

            TextField(title, text: $text)

                .keyboardType(
                    type == .numeric ? .numberPad : .default
                )

                .textInputAutocapitalization(.never)

                .autocorrectionDisabled()

                .onChange(of: text) { _, newValue in

                    guard type == .numeric else {

                        return

                    }

                    text = newValue.filter(\.isNumber)

                }

        }

        .padding()

        .background(.ultraThinMaterial)

        .overlay(

            RoundedRectangle(cornerRadius: 18)

                .stroke(
                    color.opacity(0.20),
                    lineWidth: 1
                )

        )

        .clipShape(
            RoundedRectangle(cornerRadius: 18)
        )

    }

}
