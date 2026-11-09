//
//  GlassSearchBar.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/18/26.
//


import SwiftUI

struct GlassSearchBar: View {

    @Binding
    var text: String

    let color: Color

    var body: some View {

        HStack {

            Image(systemName: "magnifyingglass")

            TextField("Search", text: $text)

        }

        .padding()

        .background(.ultraThinMaterial)

        .overlay {

            RoundedRectangle(cornerRadius: 18)

                .stroke(color.opacity(0.25), lineWidth: 1)

        }

        .clipShape(

            RoundedRectangle(cornerRadius: 18)

        )

        .padding(.horizontal)

    }

}