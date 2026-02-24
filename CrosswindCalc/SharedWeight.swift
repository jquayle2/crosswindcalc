import SwiftUI
import Combine

class SharedWeight: ObservableObject {
    @AppStorage("shared_fuel") var fuelGallons: Double = 42 {
        didSet { objectWillChange.send() }
    }
    @AppStorage("shared_pax") var paxWeight: Double = 0 {
        didSet { objectWillChange.send() }
    }
    @AppStorage("shared_baggage") var baggage: Double = 0 {
        didSet { objectWillChange.send() }
    }
    
    // Aircraft constants (RV-7)
    let emptyWeight: Double = 1096
    let pilotWeight: Double = 178
    let maxGross: Double = 1800
    let fuelCapacity: Double = 42
    let fuelWeight: Double = 6.0
    let paxOptions: [Double] = [100, 130, 160, 200]
    let baggageOptions: [Double] = [25, 50, 75, 100]
    
    var fuelLbs: Double { fuelGallons * fuelWeight }
    
    var currentWeight: Double {
        emptyWeight + pilotWeight + fuelLbs + paxWeight + baggage
    }
    
    var weightRatio: Double { currentWeight / maxGross }
    var sqrtWeightRatio: Double { sqrt(weightRatio) }
    var isOverGross: Bool { currentWeight > maxGross }
}
