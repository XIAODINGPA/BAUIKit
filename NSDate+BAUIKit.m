//
//  NSDate+BAUIKit.m
//  BAUIKit
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Alexander Borovikov
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "NSDate+BAUIKit.h"

@implementation NSDate (BAUIKit)

#define kCalendar [NSCalendar currentCalendar]

#define kDateComponents (NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfMonth |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal)

#pragma mark -
#pragma mark Comparing dates

- (BOOL)isEarlierDate:(NSDate *)aDate
{
    return ([[self earlierDate:aDate] isEqualToDate:self]);
}

- (BOOL)isLaterDate:(NSDate *)aDate
{
    return ([[self laterDate:aDate] isEqualToDate:self]);
}

- (BOOL)dateBetweenStartDate:(NSDate*)start andEndDate:(NSDate*)end
{
    BOOL isEarlier = [self isLaterDate:start];
    BOOL isLater = [self isEarlierDate:end];
    
    if (isLater && isEarlier){
        return YES;
    } else {
        return NO;
    }
}

#pragma mark -
#pragma mark Date formatting

- (NSString*)localeFormattedDateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    
    NSString *ret = [formatter stringFromDate:self];
    
    return ret;
}

- (NSString*)localeFormattedDateStringWithTime {    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString *ret = [formatter stringFromDate:self];
    
    return ret;
}

+ (NSDate *)localeFormatted
{
    return [[NSDate date] dateFormattedLocale];
}

- (NSDate *)dateFormattedLocale
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    NSString *ret = [formatter stringFromDate:self];
    
    return [formatter dateFromString:ret];
}


- (NSString *)formattedStringWithFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSString *ret = [formatter stringFromDate:self];
    
    return ret;
}

- (NSDate *)dateWithoutTime
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *ret = [formatter stringFromDate:self];
    
    return [formatter dateFromString:ret];
}

+ (NSDate *)dateWithoutTime
{
    return [[NSDate date] dateWithoutTime];
}


#pragma mark -
#pragma mark SQLite formatting

- (NSDate *)dateForSqlite
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *ret = [formatter stringFromDate:self];
    
    NSDate *date = [formatter dateFromString:ret];
    
    return date;
}

+ (NSDate*)dateFromSQLString:(NSString*)dateStr
{
    NSDateFormatter *dateForm = [[NSDateFormatter alloc] init];
    [dateForm setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
    NSDate *date = [dateForm dateFromString:dateStr];
    return date;
}


#pragma mark -
#pragma mark Beginning and end of date components

- (NSDate *)startOfDay
{
    NSDateComponents *components = [kCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                fromDate:self];    [components setHour: 0];
    [components setMinute: 0];
    [components setSecond: 0];
    
    return [kCalendar dateFromComponents:components];
}

- (NSDate *)endOfDay
{
    NSDateComponents *components = [kCalendar components: NSUIntegerMax fromDate: self];
    [components setHour: 23];
    [components setMinute: 59];
    [components setSecond: 59];
    
    return [kCalendar dateFromComponents:components];
}


- (NSDate *)beginningOfWeek
{
    NSDate *beginningOfWeek = nil;
    BOOL ok = [kCalendar rangeOfUnit:NSCalendarUnitWeekOfMonth startDate:&beginningOfWeek
                            interval:NULL forDate:self];
    if (ok){
        return beginningOfWeek;
    }
    
    NSDateComponents *weekdayComponents = [kCalendar components:NSCalendarUnitWeekday fromDate:self];
    
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    
    [componentsToSubtract setDay: 0 - ([weekdayComponents weekday] + 1)];
    beginningOfWeek = nil;
    beginningOfWeek = [kCalendar dateByAddingComponents:componentsToSubtract toDate:self options:0];
    
    NSDateComponents *components = [kCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                fromDate:beginningOfWeek];
    return [kCalendar dateFromComponents:components];
    
}

- (NSDate *)beginningOfMonth {
    
    NSDateComponents *comps = [kCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)fromDate:self];
    [comps setDay:1];
    
    return [kCalendar dateFromComponents:comps];
    
}

- (NSDate *)beginningOfYear
{
    NSDateComponents *comps = [kCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)fromDate:self];
    [comps setDay:1];
    [comps setMonth:1];
    
    return [kCalendar dateFromComponents:comps];
    
}

- (NSDate *)endOfWeek
{
    NSDateComponents *weekdayComponents = [kCalendar components:NSCalendarUnitWeekday fromDate:self];
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    [componentsToAdd setDay:(8 - [weekdayComponents weekday])];
    NSDate *endOfWeek = [kCalendar dateByAddingComponents:componentsToAdd toDate:self options:0];
    
    return endOfWeek;
}

- (NSDate *)endOfMonth
{
    NSRange daysRange = [kCalendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self];
    
    NSDateComponents *components = [kCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)fromDate:self];
    [components setDay:daysRange.length];
    
    return [kCalendar dateFromComponents:components];
}

- (NSDate *)endOfYear
{
    NSUInteger days = 0;
    NSDateComponents *components = [kCalendar components:NSCalendarUnitYear fromDate:self];
    NSUInteger months = [kCalendar rangeOfUnit:NSCalendarUnitMonth
                                        inUnit:NSCalendarUnitYear
                                       forDate:self].length;
    for (int i = 1; i <= months; i++){
        components.month = i;
        NSDate *month = [kCalendar dateFromComponents:components];
        days += [kCalendar rangeOfUnit:NSCalendarUnitDay
                                inUnit:NSCalendarUnitMonth
                               forDate:month].length;
    }
    
    NSDateComponents *comps = [kCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)fromDate:self];;
    
    [comps setMonth:12];
    
    return [[kCalendar dateFromComponents:comps] endOfMonth];
}

#pragma mark -
#pragma mark Date math

- (NSDate *)dateByAddingDays:(NSInteger)days
{
    NSDate *date = [self dateByAddingTimeInterval:(days * kSecondsDay)];
    return date;
}

- (NSDate *)dateBySubtractingDays:(NSInteger)days
{
    
    NSDate *date = [self dateByAddingTimeInterval:(-days * kSecondsDay)];
    return date;
}

- (NSDate *)dateByAddingHours:(NSInteger)hours
{
    NSDate *date = [self dateByAddingTimeInterval:(hours * kSecondsHour)];
    return date;
}

- (NSDate *)dateBySubtractingHours:(NSInteger)hours
{
    NSDate *date = [self dateByAddingTimeInterval:(-hours * kSecondsHour)];
    return date;
}

- (NSDate *)dateByAddingMinutes:(NSInteger)minutes
{
    NSDate *date = [self dateByAddingTimeInterval:(minutes * kSecondsMinute)];
    return date;
}

- (NSDate *)dateBySubtractingMinutes:(NSInteger)minutes
{
    NSDate *date = [self dateByAddingTimeInterval:(-minutes * kSecondsMinute)];
    return date;
}


- (NSDate*)dateByAddingMonth:(int)monthes
{
    NSDateComponents *components = [kCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)fromDate:self];
    components.month += monthes;
    
    return [kCalendar dateFromComponents:components];
}

- (NSDate*)dateBySubstractingMonth:(int)monthes
{
    NSDateComponents *components = [kCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)fromDate:self];
    components.month -= monthes;
    
    return [kCalendar dateFromComponents:components];
}


#pragma mark Date components

- (NSInteger)hour
{
    NSDateComponents *components = [kCalendar components:kDateComponents fromDate:self];
    return [components hour];
}

- (NSInteger)minute
{
    NSDateComponents *components = [kCalendar components:kDateComponents fromDate:self];
    return [components minute];
}

- (NSInteger)seconds
{
    NSDateComponents *components = [kCalendar components:kDateComponents fromDate:self];
    return [components second];
}

- (NSInteger)day
{
    NSDateComponents *components = [kCalendar components:kDateComponents fromDate:self];
    return [components day];
}

- (NSInteger)month
{
    NSDateComponents *components = [kCalendar components:kDateComponents fromDate:self];
    return [components month];
}

- (NSInteger)week
{
    NSDateComponents *components = [kCalendar components:kDateComponents fromDate:self];
    return [components weekOfYear];
}

- (NSInteger)weekday
{
    NSDateComponents *components = [kCalendar components:kDateComponents fromDate:self];
    return [components weekday];
}

- (NSInteger)nthWeekday
{
    NSDateComponents *components = [kCalendar components:kDateComponents fromDate:self];
    return [components weekdayOrdinal];
}
- (NSInteger)year
{
    NSDateComponents *components = [kCalendar components:kDateComponents fromDate:self];
    return [components year];
}


- (NSString*)monthName
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM"];
    [formatter setLocale:[NSLocale currentLocale]];
    
    NSString *stringFromDate = [formatter stringFromDate:self];
    
    return stringFromDate;
}

- (NSString*)yearFromDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY"];
    [formatter setLocale:[NSLocale currentLocale]];
    
    NSString *stringFromDate = [formatter stringFromDate:self];
    
    return stringFromDate;
}

@end
