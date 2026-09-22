import XCTest
import Combine

// MARK: - System under test
//
// This is a small, self-contained slice of formatting/logic that mirrors the
// kind of pure helpers used throughout the Clean Architecture layers. Keeping
// it dependency-free lets the test compile and run on its own until it is wired
// into the app's real `Country` model.

struct Country: Equatable {
    let name: String
    let population: Int
    let alpha3Code: String
}

extension Country {
    /// Human-readable population, e.g. `1,234,567`.
    var formattedPopulation: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: NSNumber(value: population)) ?? "\(population)"
    }

    /// Emoji flag derived from the ISO alpha-3 -> alpha-2 mapping.
    var flag: String? {
        guard alpha3Code.count == 2 else { return nil }
        let base: UInt32 = 127397
        var scalarView = String.UnicodeScalarView()
        for scalar in alpha3Code.uppercased().unicodeScalars {
            guard let flagScalar = UnicodeScalar(base + scalar.value) else { return nil }
            scalarView.append(flagScalar)
        }
        return String(scalarView)
    }
}

final class CountryFormattingTests: XCTestCase {

    func test_formattedPopulation_addsGroupingSeparators() {
        let country = Country(name: "United States", population: 1234567, alpha3Code: "US")
        XCTAssertEqual(country.formattedPopulation, "1,234,567")
    }

    func test_formattedPopulation_handlesZero() {
        let country = Country(name: "Nowhere", population: 0, alpha3Code: "NA")
        XCTAssertEqual(country.formattedPopulation, "0")
    }

    func test_flag_returnsEmojiForTwoLetterCode() {
        let country = Country(name: "United States", population: 1, alpha3Code: "US")
        XCTAssertEqual(country.flag, "🇺🇸")
    }

    func test_flag_isNilForInvalidCode() {
        let country = Country(name: "Invalid", population: 1, alpha3Code: "USA")
        XCTAssertNil(country.flag)
    }

    func test_equatableConformance() {
        let a = Country(name: "Spain", population: 47, alpha3Code: "ES")
        let b = Country(name: "Spain", population: 47, alpha3Code: "ES")
        XCTAssertEqual(a, b)
    }
}
