//
//  AppScreen.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/13/26.
//


import SwiftUI

struct AppScreen<Content: View>: View {

    let title: String

    @ViewBuilder
    let content: Content

    var body: some View {

        NavigationStack {

            content
                .navigationTitle(title)

        }

    }

}