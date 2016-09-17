import XCTest
import OHHTTPStubs
import CoreLocation
@testable import MapboxGeocoder

class ForwardGeocodingTests: XCTestCase {
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testValidForwardGeocode() {
        let expectation = expectationWithDescription("forward geocode should return results")
        
        stub(isHost("api.mapbox.com")
            && isPath("/geocoding/v5/mapbox.places/1600+pennsylvania+ave.json")
            && containsQueryParams(["country": "ca", "access_token": BogusToken])) { _ in
            let path = NSBundle(forClass: self.dynamicType).pathForResource("forward_valid", ofType: "json")
            return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        let geocoder = Geocoder(accessToken: BogusToken)
        var addressPlacemark: Placemark! = nil
        let options = ForwardGeocodeOptions(query: "1600 pennsylvania ave")
        options.allowedISOCountryCodes = ["CA"]
        let task = geocoder.geocode(options: options) { (placemarks, attribution, error) in
            XCTAssertEqual(placemarks?.count, 4, "forward geocode should have 4 results")
            addressPlacemark = placemarks![0]
            
            XCTAssertEqual(attribution, "NOTICE: © 2016 Mapbox and its suppliers. All rights reserved. Use of this data is subject to the Mapbox Terms of Service (https://www.mapbox.com/about/maps/). This response and the information it contains may not be retained.")
            
            expectation.fulfill()
        }
        XCTAssertNotNil(task)
        
        waitForExpectationsWithTimeout(1) { (error) in
            XCTAssertNil(error, "Error: \(error)")
            XCTAssertEqual(task.state, NSURLSessionTaskState.Completed)
        }
        
        XCTAssertEqual(addressPlacemark.description, "Pennsylvania Ave", "forward geocode should populate description")
        XCTAssertEqual(addressPlacemark.debugDescription, "Pennsylvania Ave, Wasaga Beach, Ontario L9Z 3A8, Canada", "forward geocode should populate debug description")
        XCTAssertEqual(addressPlacemark.name, "Pennsylvania Ave", "forward geocode should populate name")
        XCTAssertEqual(addressPlacemark.qualifiedName, "Pennsylvania Ave, Wasaga Beach, Ontario L9Z 3A8, Canada", "forward geocode should populate name")
        XCTAssertEqual(addressPlacemark.superiorPlacemarks?.count, 4, "forward geocode should populate superior placemarks")
        XCTAssertEqual(addressPlacemark.location?.coordinate.latitude, 44.5047077, "forward geocode should populate location")
    
        XCTAssertEqual(addressPlacemark.location?.coordinate.longitude, -79.9850737, "forward geocode should populate location")
        XCTAssertEqual(addressPlacemark.scope, PlacemarkScope.Address, "forward geocode should populate scope")
        XCTAssertEqual(addressPlacemark.country?.code, "CA", "forward geocode should populate ISO country code")
        XCTAssertEqual(addressPlacemark.country?.name, "Canada", "forward geocode should populate country")
        XCTAssertEqual(addressPlacemark.postalCode?.name, "L9Z 3A8", "forward geocode should populate postal code")
        XCTAssertEqual(addressPlacemark.administrativeRegion?.name, "Ontario", "forward geocode should populate administrative region")
        XCTAssertNil(addressPlacemark.district?.name, "forward geocode in Canada should not populate district area")
        XCTAssertEqual(addressPlacemark.place?.name, "Wasaga Beach", "forward geocode should populate locality")
        XCTAssertEqual(addressPlacemark.thoroughfare, "Pennsylvania Ave", "forward geocode should populate thoroughfare")
        XCTAssertNil(addressPlacemark.subThoroughfare, "forward geocode should not populate sub-thoroughfare for street-only result")
        
        XCTAssertNotNil(addressPlacemark.addressDictionary)
        let addressDictionary = addressPlacemark.addressDictionary!
        XCTAssertEqual(addressDictionary[MBPostalAddressStreetKey] as? String, "Pennsylvania Ave", "forward geocode should populate street in address dictionary")
        XCTAssertEqual(addressDictionary[MBPostalAddressCityKey] as? String, "Wasaga Beach", "forward geocode should populate city in address dictionary")
        XCTAssertEqual(addressDictionary[MBPostalAddressStateKey] as? String, "Ontario", "forward geocode should populate state in address dictionary")
        XCTAssertEqual(addressDictionary[MBPostalAddressCountryKey] as? String, "Canada", "forward geocode should populate country in address dictionary")
        XCTAssertEqual(addressDictionary[MBPostalAddressISOCountryCodeKey] as? String, "CA", "forward geocode should populate ISO country code in address dictionary")
    }
    
    func testInvalidForwardGeocode() {
        stub(isHost("api.mapbox.com")
            && isPath("/geocoding/v5/mapbox.places/Sandy+Island,+New+Caledonia.json")
            && containsQueryParams(["country": "nc", "types": "region,place,locality,poi", "access_token": BogusToken])) { _ in
                let path = NSBundle(forClass: self.dynamicType).pathForResource("forward_invalid", ofType: "json")
                return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        let expection = expectationWithDescription("forward geocode execute completion handler for invalid query")
        let geocoder = Geocoder(accessToken: BogusToken)
        let options = ForwardGeocodeOptions(query: "Sandy Island, New Caledonia")
        options.allowedScopes = [.Region, .Place, .Locality, .PointOfInterest]
        options.allowedISOCountryCodes = ["NC"]
        let task = geocoder.geocode(options: options) { (placemarks, attribution, error) in
            XCTAssertEqual(placemarks?.count, 0, "forward geocode should return no results for invalid query")
            
            XCTAssertEqual(attribution, "NOTICE: © 2016 Mapbox and its suppliers. All rights reserved. Use of this data is subject to the Mapbox Terms of Service (https://www.mapbox.com/about/maps/). This response and the information it contains may not be retained.")
            
            expection.fulfill()
        }
        XCTAssertNotNil(task)
        
        waitForExpectationsWithTimeout(1) { (error) in
            XCTAssertNil(error, "Error: \(error)")
            XCTAssertEqual(task.state, NSURLSessionTaskState.Completed)
        }
    }
}
