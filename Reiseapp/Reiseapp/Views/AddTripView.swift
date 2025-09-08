//
//  AddTripView.swift
//  Reiseapp
//
//  Created by Florica Girisci on 08.09.25.
//

import SwiftUI
import PhotosUI  // für PhotosPicker

struct AddTripView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = AddTripViewModel()

    var onSave: (Trip) -> Void

    @State private var photoItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Titel", text: $vm.title)
                    TextField("Start", text: $vm.startLocation)
                    TextField("Reiseziel", text: $vm.destination)
                    DatePicker("Abreisedatum", selection: $vm.departureDate, displayedComponents: .date)
                }

                Section("Foto") {
                    HStack(spacing: 12) {
                        PhotosPicker(selection: $photoItem, matching: .images) {
                            Label("Foto auswählen", systemImage: "photo.on.rectangle")
                        }
                        Spacer()
                        TripPhotoPreview(data: vm.photoData)
                    }
                }
                .onChange(of: photoItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            vm.photoData = data
                        }
                    }
                }

                Section("Personen") {
                    if vm.persons.isEmpty {
                        Text("Noch keine Personen hinzugefügt")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(vm.persons.enumerated()), id: \.offset) { _, person in
                            Text(person)
                        }
                        .onDelete(perform: vm.removePersons)
                    }
                    HStack {
                        TextField("Person hinzufügen", text: $vm.newPerson)
                        Button {
                            vm.addPerson()
                        } label: { Image(systemName: "plus.circle.fill") }
                        .disabled(vm.newPerson.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }

                Section("Kosten") {
                    TextField("Ticketpreis", text: $vm.ticketPriceText)
                        .keyboardType(.decimalPad)
                    HStack {
                        Text("Gesamtpreis")
                        Spacer()
                        Text(vm.totalPrice, format: .currency(code: Locale.current.currency?.identifier ?? "EUR"))
                            .bold()
                    }
                }
            }
            .navigationTitle("Neue Reise")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
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
private struct TripPhotoPreview: View {
    let data: Data?
    var body: some View {
        Group {
            if let data, let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "photo")
                    .imageScale(.large)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 64, height: 64)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityHidden(true)
    }
}
