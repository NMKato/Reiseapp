//
//  AddTripSheet.swift
//  Reiseapp
//
//  Created by Waldemar Dietler on 08.09.25.
//

import SwiftUI

struct AddTripSheet: View {
    var onSave: (String, String) async -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var destination = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Titel")       { TextField("z. B. Sommerurlaub", text: $title) }
                Section("Reiseziel")   { TextField("z. B. Barcelona",    text: $destination) }
            }
            .navigationTitle("Neue Reise")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        Task {
                            await onSave(title, destination)
                            dismiss()
                        }
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty ||
                              destination.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
