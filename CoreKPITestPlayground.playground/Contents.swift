//: Playground - noun: a place where people can play

import UIKit

let userCalendar = Calendar.current


// March 10, 1876: The day Alexander Graham Bell
// made the first land line phone call
// ---------------------------------------------
// DateComponents' init method is very thorough, but very long,
// especially when we're providing only 3 pieces of information
let firstLandPhoneCallDateComponents = DateComponents(calendar: nil,
                                                      timeZone: nil,
                                                      era: nil,
                                                      year: 1876,
                                                      month: 3,
                                                      day: 10,
                                                      hour: nil,
                                                      minute: nil,
                                                      second: nil,
                                                      nanosecond: nil,
                                                      weekday: nil,
                                                      weekdayOrdinal: nil,
                                                      quarter: nil,
                                                      weekOfMonth: nil,
                                                      weekOfYear: nil,
                                                      yearForWeekOfYear: nil)

// With a calendar and a year, month, and day defined in
// a DateComponents struct, we can build a date
let firstLandPhoneCallDate = userCalendar.date(from: firstLandPhoneCallDateComponents)!
firstLandPhoneCallDate.timeIntervalSinceReferenceDate

let timeZone = userCalendar.timeZone.identifier
let timeZoneTwo = TimeZone(identifier: "Europe/Moscow")?.isDaylightSavingTime()

var firstCellPhoneCallDateComponents = DateComponents()
firstCellPhoneCallDateComponents.year = 1973
firstCellPhoneCallDateComponents.month = 4
firstCellPhoneCallDateComponents.day = 3


let firstCellPhoneCallDate = userCalendar.date(from: firstCellPhoneCallDateComponents)!
firstCellPhoneCallDate.timeIntervalSinceReferenceDate




// (Previous code goes here)

// The first Friday in June, 2017:
// National Donut Day
// -------------------------------
var donutDayComponents = DateComponents()
donutDayComponents.year = 2019
donutDayComponents.month = 6
// We're looking for a Friday...
donutDayComponents.weekday = 6
// ...and it needs to be the first Friday of the month
donutDayComponents.weekdayOrdinal = 1

let donutDayDate = userCalendar.date(from: donutDayComponents)!






var thursday5pm18thWeek2017TokyoDateComponents = DateComponents()
thursday5pm18thWeek2017TokyoDateComponents.year = 2017
thursday5pm18thWeek2017TokyoDateComponents.weekOfYear = 18
thursday5pm18thWeek2017TokyoDateComponents.weekday = 5
thursday5pm18thWeek2017TokyoDateComponents.hour = 17
thursday5pm18thWeek2017TokyoDateComponents.timeZone = TimeZone(identifier: "Asia/Tokyo")!

let thursday5pm18thWeek2017TokyoDate = userCalendar.date(from: thursday5pm18thWeek2017TokyoDateComponents)!





// (Previous code goes here)

// We want to extract the year, month, and day from firstLandPhoneCallDate
let alexanderGrahamBellDateComponents = userCalendar.dateComponents([.year, .month, .day],
                                                                    from: firstLandPhoneCallDate)
alexanderGrahamBellDateComponents.year     // 1876
alexanderGrahamBellDateComponents.month    // 3
alexanderGrahamBellDateComponents.day      // 10



//"Stevenote" where the iPhone was announced took place
// 190,058,400 seconds after the start of the Third Millennium.
let iPhoneStevenoteDate = Date(timeIntervalSinceReferenceDate: 190_058_400)

// We want to extract the year, month, day, hour, and minute from this date,
// and we also want to know what day of the week and week of the year
// this date fell on.
let iPhoneStevenoteDateComponents = userCalendar.dateComponents(
    [.year, .month, .day, .hour, .minute, .weekday, .weekOfYear],
    from: iPhoneStevenoteDate)
iPhoneStevenoteDateComponents.year!        // 2007
iPhoneStevenoteDateComponents.month!       // 1
iPhoneStevenoteDateComponents.day!         // 9
iPhoneStevenoteDateComponents.hour!        // 13
iPhoneStevenoteDateComponents.minute!      // 0
iPhoneStevenoteDateComponents.weekday!     // 3 (Tuesday)
iPhoneStevenoteDateComponents.weekOfYear!  // 2 (2nd week of the year)





// (Previous code goes here)

// The "Stevenote" where the original iPad was announced took place
// 286,308,00 seconds after the start of the Third Millennium.
let iPadSteveNoteDate = Date(timeIntervalSinceReferenceDate: 286_308_000)

// We want to extract ALL the DateComponents.
let iPadSteveNoteDateComponents = userCalendar.dateComponents([.calendar,
                                                               .day,
                                                               .era,
                                                               .hour,
                                                               .minute,
                                                               .month,
                                                               .nanosecond,
                                                               .quarter,
                                                               .second,
                                                               .timeZone,
                                                               .weekday,
                                                               .weekdayOrdinal,
                                                               .weekOfMonth,
                                                               .weekOfYear,
                                                               .year,
                                                               .yearForWeekOfYear],
                                                              from: iPadSteveNoteDate)
iPadSteveNoteDateComponents.calendar?.identifier // gregorian
iPadSteveNoteDateComponents.day!                 // 27
iPadSteveNoteDateComponents.era!                 // 1
iPadSteveNoteDateComponents.hour!                // 13
iPadSteveNoteDateComponents.minute!              // 0
iPadSteveNoteDateComponents.month!               // 1
iPadSteveNoteDateComponents.nanosecond!          // 0
iPadSteveNoteDateComponents.quarter!             // 0
iPadSteveNoteDateComponents.second!              // 0
iPadSteveNoteDateComponents.timeZone!            // Eastern time zone
iPadSteveNoteDateComponents.weekday!             // 4 (Wednesday)
iPadSteveNoteDateComponents.weekdayOrdinal!      // 4 (4th Wednesday in the month)
iPadSteveNoteDateComponents.weekOfMonth!         // 5 (5th week of the month)
iPadSteveNoteDateComponents.weekOfYear!          // 5 (5th week of the year)
iPadSteveNoteDateComponents.year!                // 2010
iPadSteveNoteDateComponents.yearForWeekOfYear!   // 2010






let date = Date()
let myLocale = Locale(identifier: "bg_BG")
//: ### Setting an application-wide `TimeZone`
//: Notice how we use if-let in case the abbreviation is wrong. It will fallback to the default timezone in that case.
if let myTimezone = TimeZone(abbreviation: "EEST") {
    print("\(myTimezone.identifier)")
}
//: ### Using a `DateFormatter`
//: You can set a locale and styles to the date formatter. This allows the dates to be formatted in the given language and provides automatic handling of the preferred date formatting in the locale

let formatter = DateFormatter()
formatter.locale = myLocale
formatter.dateStyle = .medium
formatter.timeStyle = .medium
var dateStr = formatter.string(from: date)
print("1. \(dateStr)")
var calendar = Calendar(identifier: .gregorian)
calendar.locale = myLocale
//: ### Fetching `DateComponents` off a `Date`
//: Notice how *a locale is needed for the month symbols to be reported correctly*
let dateComponents = calendar.dateComponents([.day, .month, .year], from: date)
let monthName = calendar.monthSymbols[dateComponents.month! - 1]
print ("2. \(dateComponents.day!) \(monthName) \(dateComponents.year!)")
//: #### Constructing a `Date` object from a `DateComponents` object
//: You need a `DateComponents` object and a `Calendar` object instances to do so
if let componentsBasedDate = calendar.date(from: dateComponents) {
    let componentsBasedDateStr = formatter.string(from: componentsBasedDate)
    print("3. \(componentsBasedDateStr)")
}
