//
//  EntityListView.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/13/26.
//


import SwiftUI

struct EntityListView<
    Item: Identifiable,
    Row: View,
    EmptyContent: View
>: View {

    let items: [Item]

    let isLoading: Bool

    let errorMessage: String?

    let onRefresh: () async -> Void

    let onEdit: ((Item) -> Void)?

    let onDelete: ((Item) -> Void)?

    let emptyView: EmptyContent

    let row: (Item) -> Row

    var body: some View {

        if isLoading {

            LoadingView()

        } else if let error = errorMessage {

            ErrorView(message: error) {

                Task {

                    await onRefresh()

                }

            }

        } else if items.isEmpty {

            emptyView

        } else {

            List {

                ForEach(items) { item in

                    row(item)

                        .swipeActions(edge: .trailing) {

                            if let onDelete {

                                Button(role: .destructive) {

                                    onDelete(item)

                                } label: {

                                    Label(
                                        "Delete",
                                        systemImage: "trash"
                                    )

                                }

                            }

                        }

                        .swipeActions(edge: .leading) {

                            if let onEdit {

                                Button {

                                    onEdit(item)

                                } label: {

                                    Label(
                                        "Edit",
                                        systemImage: "pencil"
                                    )

                                }
                                .tint(.blue)

                            }

                        }

                }

            }
            .listStyle(.plain)

            .refreshable {

                await onRefresh()

            }

        }

    }

}
