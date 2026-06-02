//
//  MirrorPriority.swift
//  Islamic Habits
//
//  Created by NASER ALALI on 02/06/2026.
//


import Foundation

enum MirrorPriority {
    case alert
    case nudge
    case progress
    case levelUp
    case quote
}

struct MirrorMessage {
    let priority: MirrorPriority
    let icon: String
    let title: String
    let subtitle: String
}