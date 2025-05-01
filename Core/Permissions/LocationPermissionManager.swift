//
//  LocationPermissionManager.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 14/04/2025.
//

import Foundation
import CoreLocation

final class LocationPermissionManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            print("Location access denied or restricted.")
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location access granted.")
        @unknown default:
            break
        }
    }

    // Optional: handle status change
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location access granted via delegate.")
        case .denied, .restricted:
            print("Location access denied via delegate.")
        default:
            break
        }
    }
}
