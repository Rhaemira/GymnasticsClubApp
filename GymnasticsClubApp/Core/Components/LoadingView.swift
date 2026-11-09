//
//  LoadingView.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/10/26.
//


import SwiftUI

struct LoadingView: View {

    var body: some View {

        VStack(spacing: AppSpacing.large) {

            ProgressView()

            Text("Loading...")
                .foregroundStyle(.secondary)

        }

        .frame(maxWidth: .infinity,
               maxHeight: .infinity)

    }

}