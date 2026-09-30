//
//  GameModels.swift
//  HyperWerewolfSupporter
//
//  Created by Ichiro Miura on 2026/09/23.
//  Copyright © 2026 mycompany. All rights reserved.
//

import Foundation

/*
 ゲームステータスの構造化
 */
struct GameState: Codable {
    var players: [Player] = []
    var youPlayerId: UUID?
    var fortuneResults: [FortuneResult] = []
    var spiritResults: [SpiritResult] = []
    var roleCOs: [RoleCO] = []
    var currentDay: Int = 1
}

// 死因
enum DeathCause: Codable {
    // 吊り or 噛み or 溶け
    case hang, killed, melted, none
}

struct DeathInfo: Codable {
    let cause: DeathCause, day: Int
}

// 参加者情報
struct Player: Codable {
    let id: UUID
    var name: String
    var death: DeathInfo?
    // 死活フラグ
    var isAlive: Bool { death == nil }
}

enum Role: Codable {
    case fortune, hunter, sharer, madman, werewolf, spirit, none
}

// 誰がCOしたかを持つ
struct RoleCO: Codable {
    let playerId: UUID
    let role: Role
}

enum FortuneResultType: Codable {
    case white, black, melt
}

struct FortuneResult: Codable {
    let from: UUID
    let to: UUID
    let day: Int
    let result: FortuneResultType
}

enum SpiritResultType: Codable {
    case white, black
}

struct SpiritResult: Codable {
    let from: UUID
    let to: UUID
    let day: Int
    let result: SpiritResultType
}


