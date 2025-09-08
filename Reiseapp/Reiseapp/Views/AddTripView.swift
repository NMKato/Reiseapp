//
//  AddTripView.swift
//  Reiseapp
//
//  Created by Florica Girisci on 08.09.25.
//

import SwiftUI

struct AddTripView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = AddTripViewModel()
    
    var onSave: (Trip) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Reisedetails") {
                    TextField("Titel", text: $vm.title)
                    TextField("Reiseziel", text: $vm.destination)
                    DatePicker("Startdatum", selection: $vm.startDate, displayedComponents: .date)
                    DatePicker("Enddatum", selection: $vm.endDate, displayedComponents: .date)
                }
                
                Section("Bild") {
                    HStack {
                        Text("Symbol")
                        Spacer()
                        Image(systemName: vm.imageName)
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
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
                        onSave(vm.buildTrip())
                        dismiss()
                    }
                    .disabled(!vm.canSave)
                }
            }
        }
    }
}