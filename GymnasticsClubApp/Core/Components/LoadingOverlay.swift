//
//  LoadingOverlay.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/13/26.
//


import SwiftUI

struct LoadingOverlay: View {

    var body: some View {

        ZStack {

            Color.black.opacity(0.15)
                .ignoresSafeArea()

            ProgressView()
                .controlSize(.large)

        }

    }

}