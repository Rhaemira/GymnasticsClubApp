//
//  DetailRow.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/18/26.
//


import SwiftUI

struct DetailRow: View {

    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {

        HStack {

            Label {

                Text(title)

            } icon: {

                Image(systemName: icon)

                    .foregroundStyle(color)

            }

            Spacer()

            Text(value)

                .font(.headline)

        }

    }

}