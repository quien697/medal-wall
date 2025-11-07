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
        CardSection(spacing: 12) {
          ZStack {
            Image(race.photo ?? "")
            .resizable()
            .scaledToFit()
            .clipShape(.rect(cornerRadius: 12))
          } // ZStack
          .frame(maxWidth: .infinity)
          .frame(height: 240)
          .clipShape(RoundedRectangle(cornerRadius: 12))
          
          VStack {
            Text(race.name)
              .font(.headline)
              .multilineTextAlignment(.center)
            
            Text(race.location.formatted)
              .font(.subheadline)
          } // VStack
          .padding(.horizontal, 12)
          .padding(.top, 12)
        } // CardSection
        
        CardSection(title: "Details") {
          CardListItem(systemName: "clock") {
            Text(race.date.formatted(date: .abbreviated, time: .omitted))
              .modifier(TextStyleModifier.Card.listText)
          }
          
          CardListItem(systemName: "location.fill") {
            Text(race.location.formatted)
              .modifier(TextStyleModifier.Card.listText)
          }
          
          if race.categories.count != 0 {
            CardListItem(systemName: "figure.run") {
              Text(race.categories
                .compactMap { $0.name }
                .joined(separator: ", ")
              )
            }
          }
          
          if let url = race.url {
            CardListItem(systemName: "globe") {
              Link("Visit Website", destination: URL(string: url)!)
                .modifier(TextStyleModifier.Card.listLink)
                .underline(true, color: .blue.opacity(0.8))
            }
          }
        } // CardSection
        
        CardSection(title: "Last Updated") {
          CardListItem() {
            Text(race.updateTime.formatted(date: .abbreviated, time: .standard))
              .cardTextStyle(color: .secondary, font: .footnote)
          }
        } // CardSection
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
