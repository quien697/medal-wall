//
//  PlaceSearchStatus.swift
//  MedalWall
//
//  Created by Quien on 2026-04-25.
//

enum PlaceSearchStatus: Equatable {
  case idle
  case searching
  case result
  case error(String)
}
