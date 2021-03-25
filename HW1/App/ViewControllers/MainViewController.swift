//
//  MainViewController.swift
//  HW1
//
//  Created by Ilya Doroshkevitch on 25.03.2021.
//

import UIKit
import GoogleMaps
import CoreLocation

class MainViewController: UIViewController, GMSMapViewDelegate {

    let mapView = MapView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 100))
    let defaultCoordinate = CLLocationCoordinate2D(latitude: 55.753215, longitude: 37.622504)
    var marker: GMSMarker?
    var locationManager: CLLocationManager?


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureMap()
        configureLocationManager()

        view.addSubview(mapView)
    }


    // MARK: - Private
    private func configureUI() {
        self.title = "GOOGLE MAP"
        self.view.backgroundColor = .white

        let goButton = UIBarButtonItem(title: "Текущее", style: .plain, target: self, action: #selector(rightButtonTapped))
        self.navigationItem.rightBarButtonItem = goButton

        let markerButton = UIBarButtonItem(title: "Отслеживать", style: .plain, target: self, action: #selector(leftButtonTapped))
        self.navigationItem.leftBarButtonItem = markerButton
    }


    private func configureMap() {
        let camera = GMSCameraPosition.camera(withTarget: defaultCoordinate, zoom: 17)
        mapView.camera = camera
        mapView.delegate = self
    }


    private func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.delegate = self
    }


    private func addMarker(position: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: position)
        marker.map = mapView
        self.marker = marker
    }


    private func removeMarker() {
        marker?.map = nil
        marker = nil
    }


    @objc private func rightButtonTapped(sender: UIButton) {
        locationManager?.requestLocation()
    }


    @objc private func leftButtonTapped(sender: UIButton) {
        locationManager?.startUpdatingLocation()
    }

}


// MARK: - Extensions
extension MainViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil {

            addMarkerWhenChangePosition(for: locations)
        }

    }

    func addMarkerWhenChangePosition(for locations: [CLLocation]) {
        let camera = GMSCameraPosition.camera(withTarget: locations.first?.coordinate ?? defaultCoordinate, zoom: 17)
        mapView.camera = camera
        addMarker(position: locations.first?.coordinate ?? defaultCoordinate)
    }
}
