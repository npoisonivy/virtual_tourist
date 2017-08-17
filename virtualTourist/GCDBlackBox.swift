//
//  GCDBlackBox.swift
//  virtualTourist
//
//  Created by Nikki L on 8/3/17.
//  Copyright © 2017 Nikki. All rights reserved.
//

import Foundation

func performUIUpdatesOnMan(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
