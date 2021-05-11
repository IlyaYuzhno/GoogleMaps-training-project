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
    var marker = GMSMarker()
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    var isLocating: Bool?
    let realmService = RealmService()
    let locationManager = LocationManager.instance
    var icon: UIImage?

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

    lazy var selfieButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Selfie", for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 6
        button.accessibilityIdentifier = "selfieButton"
        button.addTarget(self, action: #selector(self.selfieButtonPressed(sender:)), for: .touchUpInside)
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
        view.addSubview(selfieButton)

        NSLayoutConstraint .activate([
            showTrackButton.topAnchor.constraint(equalTo: mapView.bottomAnchor),
            showTrackButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            showTrackButton.widthAnchor.constraint(equalTo: mapView.widthAnchor, constant: -240),
            showTrackButton.heightAnchor.constraint(equalToConstant: 50),

            selfieButton.topAnchor.constraint(equalTo: mapView.bottomAnchor),
            selfieButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            selfieButton.widthAnchor.constraint(equalTo: mapView.widthAnchor, constant: -240),
            selfieButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func configureMap() {
        let camera = GMSCameraPosition.camera(withTarget: defaultCoordinate, zoom: 17)
        mapView.camera = camera
        mapView.delegate = self
    }

    private func configureLocationManager() {
        locationManager
            .location
            .asObservable()
            .bind { [weak self] location in
                //guard let location = location else { return }
                self?.routePath?.add(location.coordinate)
                // Обновляем путь у линии маршрута путём повторного присвоения
                self?.route?.path = self?.routePath

                // Добавляем плавно перемещающийся маркер
                self?.addMarker(position: location.coordinate)
                
                // Чтобы наблюдать за движением, установим камеру на только что добавленную
                // точку
                let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
                self?.mapView.animate(to: position)
            }
    }

    // Marker setup
    private func addMarker(position: CLLocationCoordinate2D) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(1)
        self.marker.position = position
        CATransaction.commit()
        self.marker.icon = retrieveMarkerIcon(forKey: "markerIcon")?.circularImage(30)
        self.marker.groundAnchor = CGPoint(x: 1, y: 1)
        self.marker.map = self.mapView
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
        locationManager.startUpdatingLocation()

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
        let lastTrack = realmService.lastTrack().last

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
        locationManager.stopUpdatingLocation()
        realmService.savePath(coordinates: routePath?.encodedPath() ?? "")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}



// MARK: - Extensions
extension MainViewController {

    @objc private func setBlur() {
        Blur.setBlur(view: self.view)
    }

    @objc private func removeBlur() {
        Blur.removeBlur()
    }
}

// MARK: - Image Picker Controller
extension MainViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @objc private func selfieButtonPressed(sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) else { return }
        // Создаём контроллер и настраиваем его
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .savedPhotosAlbum
        // Изображение можно редактировать
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        // Показываем контроллер
        present(imagePickerController, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        // Save resized icon to disk
        storeMarkerIcon(image: resizedImage(image: image, for: CGSize(width: 20, height: 20))!, forKey: "markerIcon")
    }

    // Resize selfie
    func resizedImage(image: UIImage, for size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

// MARK: - Store marker icon to disk
extension MainViewController {

    private func filePath(forKey key: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory,
                                                 in: FileManager.SearchPathDomainMask.userDomainMask).first else { return nil }

        return documentURL.appendingPathComponent(key + ".png")
    }

    private func storeMarkerIcon(image: UIImage, forKey key: String) {
        if let pngRepresentation = image.pngData() {
            if let filePath = filePath(forKey: key) {
                do  {
                    try pngRepresentation.write(to: filePath,
                                                options: .atomic)
                } catch let error {
                    print("Saving file resulted in error: ", error)
                }

            }
        }
    }

    private func retrieveMarkerIcon(forKey key: String) -> UIImage? {
        if let filePath = self.filePath(forKey: key),
           let fileData = FileManager.default.contents(atPath: filePath.path),
           let image = UIImage(data: fileData) {
            return image
        }
        return nil
    }

}
