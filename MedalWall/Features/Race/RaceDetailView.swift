//
//  RaceDetailView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI
import SwiftData

struct RaceDetailView: View {
  @Environment(\.modelContext) private var context
  @Bindable var race: Race
  
  var body: some View {
    ScrollView {
      VStack(spacing: 12) {
        ZStack {
          Image(.taipeiMarathon)
            .resizable()
            .scaledToFit()
            .clipShape(.rect(cornerRadius: 12))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 240)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        
        VStack {
          Text(race.name)
            .font(.headline)
            .multilineTextAlignment(.center)
          
          Text(race.location.formatted)
            .font(.subheadline)
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
      }
      .cardStyle()
      
      VStack {
        HStack(alignment: .top) {
          Image(systemName: "clock")
            .font(.subheadline)
            .foregroundStyle(.secondary)
          
          Text(race.date.formatted(date: .abbreviated, time: .omitted))
            .font(.subheadline)
            .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 6)
        
        Divider()
        
        HStack(alignment: .top) {
          Image(systemName: "mappin.and.ellipse")
            .font(.subheadline)
            .foregroundStyle(.secondary)
          
          Text(race.location.formatted)
            .font(.subheadline)
            .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 6)
        
        if race.categories.count != 0 {
          Divider()
          
          HStack(alignment: .top) {
            Image(systemName: "figure.run")
              .font(.subheadline)
              .foregroundStyle(.secondary)
            
            Text(race.categories
                .compactMap { $0.name }
                .joined(separator: ", ")
            )
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.vertical, 6)
        }
        
        Divider()
        
        
        if let url = race.url {
          HStack(alignment: .top) {
            Image(systemName: "arrow.up.right.square")
              .font(.subheadline)
              .foregroundStyle(.secondary)
            
            Link("Visit Website", destination: URL(string: url)!)
              .font(.subheadline)
              .foregroundColor(.blue)
              .underline(true, color: .blue.opacity(0.8))
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.vertical, 6)
        }
      }
      .cardStyle()
    } // ScrollView
    .padding(.horizontal)
    .background(.ultraThinMaterial)
    .navigationTitle(race.name)
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  let context = ModelContext(PreviewContainer.shared)
  let race = try! context.fetch(FetchDescriptor<Race>())[1]
  RaceDetailView(race: race)
    .modelContainer(PreviewContainer.shared)
}
