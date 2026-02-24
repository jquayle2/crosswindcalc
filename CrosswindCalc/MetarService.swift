import Foundation
import CoreLocation

struct MetarData {
    let stationId: String
    let tempC: Double
    let altimeterInHg: Double
    let elevation: Double  // field elevation in feet
    let raw: String
}

class MetarService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var metar: MetarData?
    @Published var densityAltitude: Int?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?
    
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        isLoading = true
        errorMessage = nil
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        fetchNearestMetar(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false
        errorMessage = "Location unavailable"
    }
    
    // MARK: - METAR Fetch (NWS API - no key needed)
    
    private func fetchNearestMetar(lat: Double, lon: Double) {
        // Step 1: Find nearest station via NWS points endpoint
        let pointsURL = URL(string: "https://api.weather.gov/points/\(lat),\(lon)")!
        var pointsReq = URLRequest(url: pointsURL)
        pointsReq.setValue("CrosswindCalc/1.0", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: pointsReq) { [weak self] data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = "Network error"
                }
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let props = json["properties"] as? [String: Any],
                  let obsURL = props["observationStations"] as? String else {
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = "No stations found"
                }
                return
            }
            
            self?.fetchStationList(urlString: obsURL)
        }.resume()
    }
    
    private func fetchStationList(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        var req = URLRequest(url: url)
        req.setValue("CrosswindCalc/1.0", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: req) { [weak self] data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let features = json["features"] as? [[String: Any]],
                  let first = features.first,
                  let stationProps = first["properties"] as? [String: Any],
                  let stationId = stationProps["stationIdentifier"] as? String,
                  let elevation = stationProps["elevation"] as? [String: Any],
                  let elevValue = elevation["value"] as? Double else {
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = "Station parse error"
                }
                return
            }
            
            let elevFeet = elevValue * 3.28084  // meters to feet
            self?.fetchLatestObs(stationId: stationId, elevFeet: elevFeet)
        }.resume()
    }
    
    private func fetchLatestObs(stationId: String, elevFeet: Double) {
        let urlStr = "https://api.weather.gov/stations/\(stationId)/observations/latest"
        guard let url = URL(string: urlStr) else { return }
        var req = URLRequest(url: url)
        req.setValue("CrosswindCalc/1.0", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: req) { [weak self] data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let props = json["properties"] as? [String: Any] else {
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = "Obs parse error"
                }
                return
            }
            
            let tempC: Double
            if let tempObj = props["temperature"] as? [String: Any],
               let tv = tempObj["value"] as? Double {
                tempC = tv
            } else {
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = "No temp data"
                }
                return
            }
            
            let altInHg: Double
            if let altObj = props["barometricPressure"] as? [String: Any],
               let av = altObj["value"] as? Double {
                altInHg = av / 3386.39  // Pa to inHg
            } else {
                altInHg = 29.92
            }
            
            let rawText = props["rawMessage"] as? String ?? "N/A"
            
            let metarData = MetarData(
                stationId: stationId,
                tempC: tempC,
                altimeterInHg: altInHg,
                elevation: elevFeet,
                raw: rawText
            )
            
            let da = self?.calculateDA(tempC: tempC, altimeterInHg: altInHg, fieldElevation: elevFeet) ?? 0
            
            DispatchQueue.main.async {
                self?.metar = metarData
                self?.densityAltitude = da
                self?.isLoading = false
                self?.lastUpdated = Date()
            }
        }.resume()
    }
    
    // MARK: - DA Calculation
    
    private func calculateDA(tempC: Double, altimeterInHg: Double, fieldElevation: Double) -> Int {
        // Pressure altitude = field elevation + (29.92 - altimeter) * 1000
        let pressureAlt = fieldElevation + (29.92 - altimeterInHg) * 1000.0
        
        // Standard temp at pressure altitude: 15 - (pressureAlt / 1000 * 1.98)
        let stdTemp = 15.0 - (pressureAlt / 1000.0 * 1.98)
        
        // DA = pressure altitude + (120 * (tempC - stdTemp))
        let da = pressureAlt + (120.0 * (tempC - stdTemp))
        
        return Int(round(da))
    }
}
