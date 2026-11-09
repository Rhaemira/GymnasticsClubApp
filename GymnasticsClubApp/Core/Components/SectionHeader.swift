//
//  SectionHeader.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/13/26.
//


import SwiftUI

struct SectionHeader: View {

    let title: String

    var body: some View {

        HStack {

            Text(title)
                .font(.title2.bold())

            Spacer()

        }

    }

}