import Foundation
import HomeKit

class HomeManager: NSObject, HMHomeManagerDelegate {
    private let homeManager = HMHomeManager()
    private var tvLights: HMAccessory?

    override init() {
        super.init()
        homeManager.delegate = self
    }
    
    func fetchAccessories(completion: @escaping ([[String: String]]) -> Void) {
        var accessoriesList: [[String: String]] = []
        for home in homeManager.homes {
            for accessory in home.accessories {
                if let room = accessory.room?.name {
                    let accessoryInfo = [
                        "name": accessory.name,
                        "room": room,
                        "home": home.name // Include the home name
                    ]
                    accessoriesList.append(accessoryInfo)
                }
            }
        }
        completion(accessoriesList)
    }
    
    func toggleAccessory(name: String, room: String, completion: @escaping (Bool, Error?) -> Void) {
        for home in homeManager.homes {
            for accessory in home.accessories {
                if accessory.name == name && accessory.room?.name == room {
                    for service in accessory.services {
                        if service.serviceType == HMServiceTypeLightbulb {
                            for characteristic in service.characteristics {
                                if characteristic.characteristicType == HMCharacteristicTypePowerState {
                                    characteristic.readValue { error in
                                        if let error = error {
                                            completion(false, error)
                                        } else if let currentValue = characteristic.value as? Bool {
                                            let newValue = !currentValue
                                            characteristic.writeValue(newValue) { error in
                                                if let error = error {
                                                    completion(false, error)
                                                } else {
                                                    completion(true, nil)
                                                }
                                            }
                                        } else {
                                            completion(false, NSError(domain: "HomeManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Unable to read power state"]))
                                        }
                                    }
                                    return
                                }
                            }
                        }
                    }
                }
            }
        }
        completion(false, NSError(domain: "HomeManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Accessory not found"]))
    }
}
