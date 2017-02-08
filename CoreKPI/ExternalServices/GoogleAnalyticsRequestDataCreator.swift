//
//  GoogleAnalyticsRequestDataCreator.swift
//  CoreKPI
//
//  Created by Семен on 06.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import EVReflection
import ObjectMapper

class ReportRequest: EVObject {
    
    var viewId: String = ""
    var dateRanges: [DateRange]
    //var samplingLevel: Sampling?
    //var dimensions: [Dimension]?
    //var dimensionFilterClauses: [DimensionFilter]?
    var metrics: [Metric]
    //var metricFilterClauses: [MetricFilterClause]?
    //var filtersExpression: String?
    //var orderBys: [OrderBy]?
    //var segments: [Segment]?
    //var pivots: [Pivot]?
    //var cohortGroup: CohortGroup?
    
    //var pageToken: String?
    //var pageSize: Int?
    //var includeEmptyRows: Bool?
    //var hideTotals: Bool?
    //var hideValueRanges: Bool?
    
    init(viewId: String, startDate: String, endDate: String, expression: String, alias: String, formattingType: String) {
        self.viewId = viewId
        self.dateRanges = [DateRange(startDate: startDate, endDate: endDate)]
        self.metrics = [Metric(expression: expression, alias: alias, formattingType: MetricType(rawValue: formattingType)!)]
    }
    
    required convenience init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}

extension ReportRequest {
    
    struct DateRange {
        let startDate: String
        let endDate: String
    }
    
    enum Sampling {
        case SAMPLING_UNSPECIFIED
        case DEFAULT
        case SMALL
        case LARGE
    }
    
    struct Dimension {
        let name: String
        let histogramBuckets: [String]
    }
    
    enum FilterLogicalOperator {
        case OPERATOR_UNSPECIFIED
        case OR
        case AND
    }
    
    struct DimensionFilter {
        let dimensionName: String
        let not: Bool
        let operat: Operator
        let expressions: [String]
        let caseSensitive: Bool
    }
    
    enum Operator {
        case OPERATOR_UNSPECIFIED
        case REGEXP
        case BEGINS_WITH
        case ENDS_WITH
        case PARTIAL
        case EXACT
        case NUMERIC_EQUAL
        case NUMERIC_GREATER_THAN
        case NUMERIC_LESS_THAN
        case IN_LIST
    }
    
    struct DimensionFilterClause {
        let operat: FilterLogicalOperator
        let filters: [DimensionFilter]
    }
    
    enum MetricType: String {
        case METRIC_TYPE_UNSPECIFIED
        case INTEGER
        case FLOAT
        case CURRENCY
        case PERCENT
        case TIME
    }
    
    struct Metric {
        let expression: String
        let alias: String
        let formattingType: MetricType
    }
    
    struct MetricFilter {
        let metricName: String
        let not: Bool
        let operat: Operator
        let comparisonValue: String
    }
    
    struct MetricFilterClause {
        let operat: FilterLogicalOperator
        let filters: MetricFilter
    }
    
    enum OrderType {
        case ORDER_TYPE_UNSPECIFIED
        case VALUE
        case DELTA
        case SMART
        case HISTOGRAM_BUCKET
        case DIMENSION_AS_INTEGER
    }
    
    enum SortOrder {
        case SORT_ORDER_UNSPECIFIED
        case ASCENDING
        case DESCENDING
    }
    
    struct OrderBy {
        let fieldName: String
        let orderType: OrderType
        let sortOrder: SortOrder
    }
    
    struct SegmentDimensionFilter {
        let dimensionName: String
        let operat: Operator
        let caseSensitive: Bool
        let expressions: [String]
        let minComparisonValue: String
        let maxComparisonValue: String
    }
    
    enum Scope {
        case UNSPECIFIED_SCOPE
        case PRODUCT
        case HIT
        case SESSION
        case USER
    }
    
    struct SegmentMetricFilter {
        let scope: Scope
        let metricName: String
        let operat: Operator
        let comparisonValue: String
        let maxComparisonValue: String
    }
    
    struct SegmentFilterClause {
        let not: Bool
        let dimensionFilter: SegmentDimensionFilter
        let metricFilter: SegmentMetricFilter
    }
    
    struct OrFiltersForSegment {
        let segmentFilterClauses: [SegmentFilterClause]
    }
    
    struct SimpleSegment {
        let orFiltersForSegment: [OrFiltersForSegment]
    }
    
    enum MatchType {
        case UNSPECIFIED_MATCH_TYPE
        case PRECEDES
        case IMMEDIATELY_PRECEDES
    }
    
    struct SegmentSequenceStep {
        let orFiltersForSegment: [OrFiltersForSegment]
        let matchType: MatchType
    }
    
    struct SequenceSegment {
        let segmentSequenceSteps: SegmentSequenceStep
        let firstStepShouldMatchFirstHit: Bool
    }
    
    struct SegmentFilter {
        let not: Bool
        let simpleSegment: SimpleSegment
        let sequenceSegment: SequenceSegment
    }
    
    struct SegmentDefinition {
        let segmentFilters: [SegmentFilter]
    }
    
    struct DynamicSegment {
        let name: String
        let userSegment: SegmentDefinition
        let sessionSegment: SegmentDefinition
    }
    
    struct Segment {
        let dynamicSegment: DynamicSegment
        let segmentId: String
    }
    
    struct Pivot {
        let dimensions: [Dimension]
        let dimensionFilterClauses: [DimensionFilterClause]
        let metrics: [Metric]
        let startGroup: Int
        let maxGroupCount: Int
    }
    
    enum CohortType {
        case UNSPECIFIED_COHORT_TYPE
        case FIRST_VISIT_DATE
    }
    
    struct Cohort {
        let name: String
        let type: CohortType
        let dateRange: DateRange
    }
    
    struct CohortGroup {
        let cohorts: [Cohort]
        let lifetimeValue: Bool
    }
}

class Report: Mappable {
    var columnHeader: ColumnHeader?
    var data: ReportData?
    var nextPageToken: String?
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        columnHeader  <- map["columnHeader"]
        data          <- map["data"]
        nextPageToken <- map["nextPageToken"]
    }
}

extension Report {
    
    enum MetricType: String {
        case METRIC_TYPE_UNSPECIFIED
        case INTEGER
        case FLOAT
        case CURRENCY
        case PERCENT
        case TIME
    }
    
    struct MetricHeaderEntry: Mappable {
        var name: String?
        var type: MetricType?
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            name <- map["name"]
            type <- map["type"]
        }
    }
    
    struct PivotHeaderEntry: Mappable {
        var dimensionNames: [String] = []
        var dimensionValues: [String] = []
        var metric: MetricHeaderEntry?
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            dimensionNames  <- map["dimensionNames"]
            dimensionValues <- map["dimensionValues"]
            metric          <- map["metric"]
        }
    }
    
    struct PivotHeader: Mappable {
        var pivotHeaderEntries: [PivotHeaderEntry] = []
        var totalPivotGroupsCount: Int?
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            pivotHeaderEntries    <- map["pivotHeaderEntries"]
            totalPivotGroupsCount <- map["totalPivotGroupsCount"]
        }
    }
    
    struct MetricHeader: Mappable {
        var metricHeaderEntries: [MetricHeaderEntry] = []
        var pivotHeaders: [PivotHeader] = []
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            metricHeaderEntries <- map["metricHeaderEntries"]
            pivotHeaders        <- map["pivotHeaders"]
        }
    }
    
    struct ColumnHeader: Mappable {
        var dimensions: [String] = []
        var metricHeader: MetricHeader?
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            dimensions   <- map["dimensions"]
            metricHeader <- map["metricHeader"]
        }
    }
    
    struct PivotValueRegion: Mappable {
        var values: [String] = []
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            values   <- map["values"]
        }
    }
    
    struct DateRangeValues: Mappable {
        var values: [String] = []
        var pivotValueRegions: [PivotValueRegion] = []
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            values            <- map["values"]
            pivotValueRegions <- map["pivotValueRegions"]
        }
    }
    
    struct ReportRow: Mappable {
        var dimensions: [String] = []
        var metrics: [DateRangeValues] = []
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            dimensions <- map["dimensions"]
            metrics    <- map["metrics"]
        }
    }
    
    struct ReportData: Mappable {
        var rows: [ReportRow] = []
        var totals: [DateRangeValues] = []
        var rowCount: Int?
        var minimums: [DateRangeValues] = []
        var maximums: [DateRangeValues] = []
        var samplesReadCounts: [String] = []
        var samplingSpaceSizes: [String] = []
        var isDataGolden: Bool?
        init?(map: Map) {
        }

        mutating func mapping(map: Map) {
            rows              <- map["rows"]
            totals            <- map["totals"]
            rowCount          <- map["rowCount"]
            minimums          <- map["minimums"]
            maximums          <- map["maximums"]
            samplesReadCounts <- map["samplesReadCounts"]
            isDataGolden      <- map["isDataGolden"]
            totals            <- map["totals"]
        }
    }
}
