//
//  AddTripSheet.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 08.09.25.
//

import SwiftUI

struct AddTripSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var destination = ""
    
    let onSave: (String, String) async -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Reisedetails") {
                    TextField("Titel", text: $title)
                    TextField("Reiseziel", text: $destination)
                }
            }
            .navigationTitle("Neue Reise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        Task {
                            await onSave(title, destination)
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty || destination.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddTripSheet { _,_ in }
}
