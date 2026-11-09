//
//  InfoRow.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/13/26.
//


import SwiftUI

struct InfoRow: View {

    let title: String
    let value: String
    let systemImage: String

    var body: some View {

        HStack {

            Label(title, systemImage: systemImage)

            Spacer()

            Text(value)
                .foregroundStyle(.secondary)

        }

    }

}