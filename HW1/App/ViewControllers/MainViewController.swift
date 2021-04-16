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

    let mapView = MapView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 200))
    let defaultCoordinate = CLLocationCoordinate2D(latitude: 55.753215, longitude: 37.622504)
    var marker: GMSMarker?
    var locationManager: CLLocationManager?
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    var isLocating: Bool?
    let service = RealmService()

    lazy var showTrackButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Show last track", for: .normal)
        button.backgroundColor = .green
        button.layer.cornerRadius = 6
        button.accessibilityIdentifier = "lastTrackButton"
        button.addTarget(self, action: #selector(self.lastTrackButtonPressed(sender:)), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureMap()
        configureLocationManager()

        NotificationCenter.default.addObserver(self, selector: #selector(setBlur), name: Notification.Name("sceneWillResignActive"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeBlur), name: Notification.Name("sceneDidBecomeActive"), object: nil)
    }

    // MARK: - Private
    private func configureUI() {
        self.title = "GOOGLE MAP"
        self.view.backgroundColor = .white

        let rightButton = UIBarButtonItem(title: "Stop track", style: .plain, target: self, action: #selector(rightButtonTapped))
        self.navigationItem.rightBarButtonItem = rightButton

        let leftButton = UIBarButtonItem(title: "Start new track", style: .plain, target: self, action: #selector(leftButtonTapped))
        self.navigationItem.leftBarButtonItem = leftButton

        view.addSubview(mapView)
        view.addSubview(showTrackButton)

        NSLayoutConstraint .activate([
            showTrackButton.topAnchor.constraint(equalTo: mapView.bottomAnchor),
            showTrackButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showTrackButton.widthAnchor.constraint(equalTo: mapView.widthAnchor, constant: -40),
            showTrackButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func configureMap() {
        let camera = GMSCameraPosition.camera(withTarget: defaultCoordinate, zoom: 17)
        mapView.camera = camera
        mapView.delegate = self
    }

    private func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.startMonitoringSignificantLocationChanges()
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.requestAlwaysAuthorization()

    }

    private func addMarker(position: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: position)
        marker.icon = GMSMarker.markerImage(with: .purple)
        marker.map = mapView
        self.marker = marker
    }

    private func removeMarker() {
        marker?.map = nil
        marker = nil
    }

    @objc private func rightButtonTapped(sender: UIButton) {
        stopTrackingAndSavePath()
    }

    @objc private func leftButtonTapped(sender: UIButton) {
        isLocating = true
        // Отвязываем от карты старую линию
        route?.map = nil
        // Заменяем старую линию новой
        route = GMSPolyline()
        route?.strokeWidth = 7
        // Заменяем старый путь новым, пока пустым (без точек)
        routePath = GMSMutablePath()
        // Добавляем новую линию на карту
        route?.map = mapView
        // Запускаем отслеживание или продолжаем, если оно уже запущено
        locationManager?.startUpdatingLocation()

    }

    @objc private func lastTrackButtonPressed(sender: UIButton) {

        if isLocating == true {
            let alert = UIAlertController(title: "Внимание", message: "В данный момент происходит слежение!!!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Остановить слежение", style: .destructive, handler: { [weak self] action in
                self?.stopTrackingAndSavePath()
                self?.showLastTrack()
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            showLastTrack()
        }
    }

    private func showLastTrack() {
        mapView.clear()
        let lastTrack = service.lastTrack().last

        guard let path = GMSPath(fromEncodedPath: lastTrack?.toStore ?? "") else { return }
        let route = GMSPolyline(path: path)
        route.strokeColor = .red
        route.strokeWidth = 10
        route.map = mapView

        let bounds = GMSCoordinateBounds(path: path)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
        mapView.moveCamera(update)

    }

    private func stopTrackingAndSavePath() {
        isLocating = false
        locationManager?.stopUpdatingLocation()
        service.savePath(coordinates: routePath?.encodedPath() ?? "")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}



// MARK: - Extensions
extension MainViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Берём последнюю точку из полученного набора
        guard let location = locations.last else { return }
        // Добавляем её в путь маршрута
        routePath?.add(location.coordinate)
        // Обновляем путь у линии маршрута путём повторного присвоения
        route?.path = routePath
        // Чтобы наблюдать за движением, установим камеру на только что добавленную точку
        let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
        mapView.animate(to: position)
    }

    func addMarkerWhenChangePosition(for locations: [CLLocation]) {
        let camera = GMSCameraPosition.camera(withTarget: locations.first?.coordinate ?? defaultCoordinate, zoom: 17)
        mapView.camera = camera
        addMarker(position: locations.first?.coordinate ?? defaultCoordinate)
    }
}


extension MainViewController {

    @objc private func setBlur() {
        Blur.setBlur(view: self.view)
    }

    @objc private func removeBlur() {
        Blur.removeBlur()
    }

}
