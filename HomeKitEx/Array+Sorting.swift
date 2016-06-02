/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    The `Array+Sorting` extension allows for easy sorting of HomeKit objects.
*/

import HomeKit

/// A protocol for objects which have a property called `name`.
protocol Nameable {
    var name: String { get }
}

/*
    All of these HomeKit objects have names and can conform
    to this protocol without modification.
*/

extension HMHome: Nameable {}
extension HMAccessory: Nameable {}
extension HMRoom: Nameable {}
extension HMZone: Nameable {}
extension HMActionSet: Nameable {}
extension HMService: Nameable {}
extension HMServiceGroup: Nameable {}
extension HMTrigger: Nameable {}

extension CollectionType where Generator.Element: Nameable {
    /**
        Generates a new array from the original collection,
        sorted by localized name.
        
        - returns:  New array sorted by localized name.
    */
    func sortByLocalizedName() -> [Generator.Element] {
        return sort { return $0.name.localizedCompare($1.name) == .OrderedAscending }
    }
}

extension CollectionType where Generator.Element: HMActionSet {
    /**
        Generates a new array from the original collection,
        sorted by built-in first, then user-defined sorted
        by localized name.
        
        - returns:  New array sorted by localized name.
    */

}
