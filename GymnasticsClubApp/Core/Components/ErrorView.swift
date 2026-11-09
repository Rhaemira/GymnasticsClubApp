//
//  ErrorView.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/10/26.
//


import SwiftUI

struct ErrorView: View {

    let message: String

    let retry: () -> Void

    var body: some View {

        ContentUnavailableView {

            Label("Something went wrong",
                  systemImage: "wifi.slash")

        } description: {

            Text(message)

        } actions: {

            Button("Try Again") {

                retry()

            }

        }

    }

}