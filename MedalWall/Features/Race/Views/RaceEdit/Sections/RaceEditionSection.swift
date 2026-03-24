//
//  RaceEditionSection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-24.
//

import SwiftUI

struct RaceEditionSection: View {
  let editions: [RaceEdition]
  
  var body: some View {
    Section("Editions") {
      if editions.isEmpty {
        ContentUnavailableView {
          Text("No editions yet.")
            .font(.subheadline)
            .foregroundStyle(Color.Text.tertiary)
          
          Button {
            
          } label: {
            Label("Add Edition", systemImage: "plus")
              .labelStyle(.titleAndIcon)
          }
          .goldOutLineButtonStyle(
            fontWeight: .heavy,
            vPadding: 12,
            hPadding: 20
          )
          .padding(.top, 15)
        } // ContentUnavailableView
      } else {
        ForEach(editions, id: \.self) { edition in
          NavigationLink {
            RaceEditionEditView()
          } label: {
            HStack {
              Text("\(edition.year)")
                .font(.title2)
                .fontWeight(.heavy)
                .frame(width: 80, height: 80)
                .foregroundStyle(Color.Badge.Gold.primary)
                .background(Color.Card.Background.secondary)
                .overlay(
                  RoundedRectangle(cornerRadius: 12)
                    .stroke(.gray, style: StrokeStyle(lineWidth: 2, dash: [10, 2]))
                )
              
              VStack {
                Text(edition.startDate.formatted())
                  .font(.subheadline)
                
                VStack {
                  Text("Distance")
                  
                  HStack {
                    Text("42KM")
                    Text("42KM")
                    Text("42KM")
                    Text("42KM")
                    
                  }
                }
              }
              
              Spacer()
            }
            //            VStack(alignment: .leading) {
            //              HStack {
            //                VStack(alignment: .leading, spacing: 0) {
            //                  Text("\(edition.year)")
            //                    .font(.title2)
            //                    .fontWeight(.heavy)
            //                    .foregroundStyle(Color.Badge.Gold.primary)
            //                    .padding(.bottom, 5)
            //
            //                  Text(edition.startDate.formatted())
            //                    .font(.subheadline)
            //                    .foregroundStyle(Color.Text.tertiary)
            //                }
            //
            //                Spacer()
            //
            //                Button("Edit") {
            //
            //                }
            //                .goldFillButtonStyle()
            //              }
            //              .background(Color.Card.Background.secondary)
            //
            //              Divider()
            //
            //              ForEach(edition.distancesByTypeOrdered, id: \.type) { typeGroup in
            //                VStack(alignment: .leading, spacing: 10) {
            //                  Text(typeGroup.type.displayName)
            //                    .font(.headline)
            //                    .foregroundStyle(Color.Text.secondary)
            //
            //                  FlowLayout(spacing: 10) {
            //                    ForEach(typeGroup.distances) { distance in
            //                      Text(distance.category.description)
            //                        .secondaryButtonStyle()
            //                    }
            //                  }
            //                  .frame(maxWidth: .infinity, alignment: .leading)
            //                } // VStack
            //
            //                if typeGroup.type != edition.distancesByTypeOrdered.last?.type {
            //                  Divider()
            //                    .padding(.vertical, 5)
            //                }
            //              } // ForEach
            //            } // VStack
          }
        } // ForEach
        
        Button {
          
        } label: {
          Label("Add Another Edition", systemImage: "plus")
            .labelStyle(.titleAndIcon)
        }
        .goldOutLineButtonStyle(
          fontWeight: .heavy,
          vPadding: 12,
          hPadding: 20
        )
        .frame(maxWidth: .infinity)
      }
    } // Section
  }
}

#Preview {
  RaceEditionSection(editions: Race.sampleData.first!.editions)
  
  RaceEditionSection(editions: [])
}
