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
  @State var viewModel: RaceDetailViewModel
  
  var body: some View {
    ScrollView {
      CardSection(spacing: 12) {
        ZStack {
          Image(viewModel.race.photo ?? "")
            .resizable()
            .scaledToFit()
            .clipShape(.rect(cornerRadius: 12))
        } // ZStack
        .frame(maxWidth: .infinity)
        .frame(height: 240)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        
        VStack {
          Text(viewModel.race.name)
            .font(.headline)
            .multilineTextAlignment(.center)
          
          Text(viewModel.race.location.formatted)
            .font(.subheadline)
        } // VStack
        .padding(.horizontal, 12)
        .padding(.top, 12)
      } // CardSection
      
      CardSection(title: "Details") {
        CardListItem(systemName: "clock") {
          Text(viewModel.race.date.formatted(date: .abbreviated, time: .omitted))
            .modifier(TextStyleModifier.Card.listText)
        }
        
        CardListItem(systemName: "location.fill") {
          Text(viewModel.race.location.formatted)
            .modifier(TextStyleModifier.Card.listText)
        }
        
        if viewModel.race.distances.count != 0 {
          CardListItem(systemName: "figure.run",alignment: .top) {
            VStack(alignment: .leading) {
              ForEach(viewModel.distancesByType.keys.sorted(), id: \.self) { type in
                Text(type)
                  .modifier(TextStyleModifier.Card.listText)
                
                HStack {
                  ForEach((viewModel.distancesByType[type] ?? []).sortedByDistance()) { distance in
                    Text(distance.category.description)
                      .font(.subheadline)
                      .foregroundStyle(.primary)
                      .padding(.vertical, 7)
                      .padding(.horizontal)
                      .background(distance.category.color)
                      .clipShape(.rect(cornerRadius: 12))
                  } // ForEach
                } // HStack
              } // ForEach
            } // VStack
          } // CardListItem
        }
        
        if let url = viewModel.race.url {
          CardListItem(systemName: "globe") {
            Link("Visit Website", destination: URL(string: url)!)
              .modifier(TextStyleModifier.Card.listLink)
              .underline(true, color: .blue.opacity(0.8))
          }
        }
      } // CardSection
      
      CardSection(title: "Last Updated") {
        CardListItem() {
          Text(viewModel.race.updateTime.formatted(date: .abbreviated, time: .standard))
            .cardTextStyle(color: .secondary, font: .footnote)
        }
      } // CardSection
    } // ScrollView
    .padding(.horizontal)
    .background(.ultraThinMaterial)
    .navigationTitle(viewModel.race.name)
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
      NavigationStack {
        RaceEditView(viewModel: RaceEditViewModel(
          race: viewModel.race, context: modelContext))
      }
    } // sheet
  }
}

#Preview(traits: .sampleData) {
  @Previewable @Query(sort: \Race.date) var races: [Race]
  
  RaceDetailView(viewModel: RaceDetailViewModel(race: races[0]))
}
