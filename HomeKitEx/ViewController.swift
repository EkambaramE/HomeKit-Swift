//
//  ViewController.swift
//  HomeKitEx
//
//  Created by EkambaramE on 30/05/16.
//  Copyright © 2016 EkambaramE. All rights reserved.
//

import UIKit
import HomeKit
import ExternalAccessory

enum AccessoryType: Equatable, Nameable {
    /// A HomeKit object
    case HomeKit(accessory: HMAccessory)
    
    /// An external, `EAWiFiUnconfiguredAccessory` object
    case External(accessory: EAWiFiUnconfiguredAccessory)
    
    /// The name of the accessory.
    var name: String {
        return accessory.name
    }
    
    /// The accessory within the `AccessoryType`.
    var accessory: AnyObject {
        switch self {
        case .HomeKit(let accessory):
            return accessory
            
        case .External(let accessory):
            return accessory
        }
    }
}

/// Comparison of `AccessoryType`s based on name.
func ==(lhs: AccessoryType, rhs: AccessoryType) -> Bool {
    return lhs.name == rhs.name
}


class ViewController: UIViewController, EAWiFiUnconfiguredAccessoryBrowserDelegate, HMAccessoryBrowserDelegate {

    
    var addedAccessories = [HMAccessory]()
    var displayedAccessories = [AccessoryType]()
    let accessoryBrowser = HMAccessoryBrowser()
    var externalAccessoryBrowser: EAWiFiUnconfiguredAccessoryBrowser?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        accessoryBrowser.delegate = self
        
        #if arch(arm)
            // We can't use the ExternalAccessory framework on the iPhone simulator.
            externalAccessoryBrowser = EAWiFiUnconfiguredAccessoryBrowser(delegate: self, queue: dispatch_get_main_queue())
        #endif
        
        startBrowsing()
        
    }

    
    
    /// Starts browsing on both HomeKit and External accessory browsers.
    private func startBrowsing(){
        accessoryBrowser.startSearchingForNewAccessories()
        externalAccessoryBrowser?.startSearchingForUnconfiguredAccessoriesMatchingPredicate(nil)
    }
    
    /// Stops browsing on both HomeKit and External accessory browsers.
    private func stopBrowsing(){
        accessoryBrowser.stopSearchingForNewAccessories()
        externalAccessoryBrowser?.stopSearchingForUnconfiguredAccessories()
    }
    
    func allAccessories() -> [AccessoryType] {
        var accessories = [AccessoryType]()
        accessories += accessoryBrowser.discoveredAccessories.map { .HomeKit(accessory: $0) }
        
        accessories += addedAccessories.flatMap { addedAccessory in
            let accessoryType = AccessoryType.HomeKit(accessory: addedAccessory)
            
            return accessories.contains(accessoryType) ? nil : accessoryType
        }
        
        if let external = externalAccessoryBrowser?.unconfiguredAccessories {
            let unconfiguredAccessoriesArray = Array(external)
            
            accessories += unconfiguredAccessoriesArray.flatMap { addedAccessory in
                let accessoryType = AccessoryType.External(accessory: addedAccessory)
                
                return accessories.contains(accessoryType) ? nil : accessoryType
            }
        }
        
        return accessories.sortByLocalizedName()
    }
    
 
    /**
     Finds an unconfigured accessory with a specified name.
     
     - parameter name: The name string of the accessory.
     
     - returns:  An `HMAccessory?` from the search; `nil` if
     the accessory could not be found.
     */
    func unconfiguredHomeKitAccessoryWithName(name: String) -> HMAccessory? {
        for type in displayedAccessories {
            if case let .HomeKit(accessory) = type where accessory.name == name {
                return accessory
            }
        }
        return nil
    }
    
    
    // MARK: EAWiFiUnconfiguredAccessoryBrowserDelegate Methods
    
    // Any updates to the external accessory browser causes a reload in the table view.
    
    func accessoryBrowser(browser: EAWiFiUnconfiguredAccessoryBrowser, didFindUnconfiguredAccessories accessories: Set<EAWiFiUnconfiguredAccessory>) {
        print("didFindUnconfiguredAccessories")
    }
    
    func accessoryBrowser(browser: EAWiFiUnconfiguredAccessoryBrowser, didRemoveUnconfiguredAccessories accessories: Set<EAWiFiUnconfiguredAccessory>) {
        print("didRemoveUnconfiguredAccessories")
    }
    
    func accessoryBrowser(browser: EAWiFiUnconfiguredAccessoryBrowser, didUpdateState state: EAWiFiUnconfiguredAccessoryBrowserState) {
        print("didUpdateState")
     }
    
    /// If the configuration was successful, presents the 'Add Accessory' view.
    func accessoryBrowser(browser: EAWiFiUnconfiguredAccessoryBrowser, didFinishConfiguringAccessory accessory: EAWiFiUnconfiguredAccessory, withStatus status: EAWiFiUnconfiguredAccessoryConfigurationStatus) {
        if status != .Success {
            return
        }
        
        if let foundAccessory = unconfiguredHomeKitAccessoryWithName(accessory.name) {
            print("Found Accessory : \(foundAccessory)")
           // configureAccessory(foundAccessory)
        }
    }
    
    // MARK: HMAccessoryBrowserDelegate Methods
    
    /**
     Inserts the accessory into the internal array and inserts the
     row into the table view.
     */
    func accessoryBrowser(browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
        let newAccessory = AccessoryType.HomeKit(accessory: accessory)
        print("New Accessory: \(newAccessory)")
        if displayedAccessories.contains(newAccessory)  {
            return
        }
        displayedAccessories.append(newAccessory)
        displayedAccessories = displayedAccessories.sortByLocalizedName()
        
    }
    
    /**
     Removes the accessory from the internal array and deletes the
     row from the table view.
     */
    func accessoryBrowser(browser: HMAccessoryBrowser, didRemoveNewAccessory accessory: HMAccessory) {
        let removedAccessory = AccessoryType.HomeKit(accessory: accessory)
          print("didRemoveNewAccessory")
        if !displayedAccessories.contains(removedAccessory)  {
            return
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

