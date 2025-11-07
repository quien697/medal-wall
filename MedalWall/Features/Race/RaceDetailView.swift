//
//  RaceDetailView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI
import SwiftData

struct RaceDetailView: View {
  @Environment(\.modelContext) private var modelContext
  @State private var isShowEditor = false
  @State private var isShowDeleteConfirm = false
  
  let race: Race
  
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 12) {
          ZStack {
            Image(race.photo ?? "")
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
            Image(systemName: "location.fill")
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
          
          if let url = race.url {
            Divider()
            
            HStack(alignment: .top) {
              Image(systemName: "globe")
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
        .cardStyle(paddingV: 15)
        
        VStack {
          HStack(alignment: .top) {
            Text("Last Updated:")
              .font(.footnote)
              .foregroundStyle(.secondary)
            
            Text(race.updateTime.formatted(date: .abbreviated, time: .standard))
              .font(.footnote)
              .foregroundColor(.secondary)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.vertical, 6)
        }
        .cardStyle(paddingV: 15)
      } // ScrollView
      .padding(.horizontal)
      .background(.ultraThinMaterial)
      .navigationTitle(race.name)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Menu("More Options", systemImage: "ellipsis") {
            Button {
              isShowEditor.toggle()
            } label: {
              Label("Edit Race", systemImage: "square.and.pencil")
            }
            
            Divider()
            
            Button(role: .destructive) {
              isShowDeleteConfirm = true
            } label: {
              Label("Delete Race", systemImage: "trash")
            }
          } // Menu
        } // ToolbarItem
      } // toolbar
      .sheet(isPresented: $isShowEditor) {
        RaceEditView(viewModel: RaceEditViewModel(
          race: race, context: modelContext))
      }
    } // NavigationStack
  }
}

#Preview(traits: .sampleData) {
  @Previewable @Query(sort: \Race.date) var races: [Race]
  
  RaceDetailView(race: races[0])
}
