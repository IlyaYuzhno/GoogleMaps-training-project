//
//  MapView.swift
//  HW1
//
//  Created by Ilya Doroshkevitch on 25.03.2021.
//

import UIKit
import GoogleMaps

class MapView: GMSMapView {


    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.settings.myLocationButton = true
        self.settings.zoomGestures = true

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



}
