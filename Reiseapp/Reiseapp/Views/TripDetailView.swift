//
//  TripDetailView.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 08.09.25.
//

import SwiftUI

struct TripDetailView: View {
    let trip: Trip
    @State private var showingEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Image
                if let imageName = trip.imageName {
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    // Destination
                    Label(trip.destination, systemImage: "mappin.circle.fill")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    // Date Range
                    Label(trip.dateRangeText, systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Duration
                    if let duration = trip.duration {
                        Label("\(duration) Tage", systemImage: "clock")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Activities Count
                    if trip.hasActivities {
                        Label("\(trip.totalActivities) Aktivitäten geplant", systemImage: "star.fill")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                }
                .padding(.horizontal)
                
                // Day Plans Section
                if !trip.days.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tagesplanung")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        ForEach(trip.days) { day in
                            DayPlanCard(dayPlan: day)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
                
                Spacer(minLength: 50)
            }
        }
        .navigationTitle(trip.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Bearbeiten") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            // TODO: Implement EditTripView
            Text("Bearbeiten - Coming Soon")
        }
    }
}

struct DayPlanCard: View {
    let dayPlan: DayPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(dayPlan.date, style: .date)
                .font(.headline)
            
            if !dayPlan.activities.isEmpty {
                ForEach(dayPlan.activities) { activity in
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(.blue)
                        Text(activity.title)
                            .font(.subheadline)
                        Spacer()
                        if let time = activity.time {
                            Text(time, style: .time)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            if !dayPlan.checklist.isEmpty {
                Divider()
                ForEach(dayPlan.checklist) { item in
                    HStack {
                        Image(systemName: item.isDone ? "checkmark.square.fill" : "square")
                            .foregroundColor(item.isDone ? .green : .gray)
                        Text(item.title)
                            .font(.caption)
                            .strikethrough(item.isDone)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}