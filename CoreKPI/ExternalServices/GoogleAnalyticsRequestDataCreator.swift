//
//  GoogleAnalyticsRequestDataCreator.swift
//  CoreKPI
//
//  Created by Семен on 06.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import ObjectMapper

class ReportRequest: Mappable {
    
    var viewId: String = ""
    var dateRanges: [DateRange]? = []
    var samplingLevel: Sampling?
    var dimensions: [Dimension]? = []
    var dimensionFilterClauses: [DimensionFilter]? = []
    var metrics: [Metric]? = []
    var metricFilterClauses: [MetricFilterClause]? = []
    var filtersExpression: String?
    var orderBys: [OrderBy]? = []
    var segments: [Segment]? = []
    var pivots: [Pivot]? = []
    var cohortGroup: CohortGroup?
    
    var pageToken: String?
    var pageSize: Int?
    var includeEmptyRows: Bool?
    var hideTotals: Bool?
    var hideValueRanges: Bool?
    
    required init?(map: Map) {
    }
    
    init(){}
    init(reportRequest: ReportRequest) {
        self.viewId = reportRequest.viewId
        self.dateRanges = reportRequest.dateRanges
        self.samplingLevel = reportRequest.samplingLevel
        self.dimensions = reportRequest.dimensions
        self.dimensionFilterClauses = reportRequest.dimensionFilterClauses
        self.metrics = reportRequest.metrics
        self.metricFilterClauses = reportRequest.metricFilterClauses
        self.filtersExpression = reportRequest.filtersExpression
        self.orderBys = reportRequest.orderBys
        self.segments = reportRequest.segments
        self.pivots = reportRequest.pivots
        self.cohortGroup = reportRequest.cohortGroup
        self.pageToken = reportRequest.pageToken
        self.pageSize = reportRequest.pageSize
        self.includeEmptyRows = reportRequest.includeEmptyRows
        self.hideTotals = reportRequest.hideTotals
        self.hideValueRanges = reportRequest.hideValueRanges
    }
    
    // Mappable
    func mapping(map: Map) {
        viewId                 <- map["viewId"]
        dateRanges             <- map["dateRanges"]
        metrics                <- map["metrics"]
        samplingLevel          <- map["samplingLevel"]
        dimensions             <- map["dimensions"]
        dimensionFilterClauses <- map["dimensionFilterClauses"]
        metricFilterClauses    <- map["metricFilterClauses"]
        filtersExpression      <- map["filtersExpression"]
        orderBys               <- map["orderBys"]
        segments               <- map["segments"]
        pivots                 <- map["pivots"]
        cohortGroup            <- map["cohortGroup"]
        pageToken              <- map["pageToken"]
        pageSize               <- map["pageSize"]
        includeEmptyRows       <- map["includeEmptyRows"]
        hideTotals             <- map["hideTotals"]
        hideValueRanges        <- map["hideValueRanges"]
    }
}

extension ReportRequest {
    
    struct DateRange: Mappable {
        var startDate: String?
        var endDate: String?
        
        init?(map: Map) {
        }
        init(startDate: String, endDate: String) {
            self.startDate = startDate
            self.endDate = endDate
        }
        mutating func mapping(map: Map) {
            startDate <- map["startDate"]
            endDate   <- map["endDate"]
        }
    }
    
    enum Sampling: String {
        case SAMPLING_UNSPECIFIED
        case DEFAULT
        case SMALL
        case LARGE
    }
    
    struct Dimension: Mappable {
        var name: String?
        var histogramBuckets: [String]? = []
        
        init?(map: Map) {
        }
        init(name: String) {
            self.name = name
        }
        mutating func mapping(map: Map) {
            name             <- map["name"]
            histogramBuckets <- map["histogramBuckets"]
        }
    }
    
    enum FilterLogicalOperator: String {
        case OPERATOR_UNSPECIFIED
        case OR
        case AND
    }
    
    struct DimensionFilter: Mappable {
        var dimensionName: String?
        var not: Bool?
        var operat: Operator?
        var expressions: [String]? = []
        var caseSensitive: Bool?
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            dimensionName <- map["dimensionName"]
            not           <- map["not"]
            operat        <- map["operator"]
            expressions   <- map["expressions"]
            caseSensitive <- map["caseSensitive"]
        }
    }
    
    enum Operator: String {
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
    
    struct DimensionFilterClause: Mappable {
        var operat: FilterLogicalOperator?
        var filters: [DimensionFilter]? = []
        
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            operat    <- map["operator"]
            filters   <- map["filters"]
        }
    }
    
    enum MetricType: String {
        case METRIC_TYPE_UNSPECIFIED
        case INTEGER
        case FLOAT
        case CURRENCY
        case PERCENT
        case TIME
    }
    
    struct Metric: Mappable {
        var expression: String?
        var alias: String?
        var formattingType: MetricType?
        init?(map: Map) {
        }
        init(expression: String, formattingType: MetricType) {
            self.expression = expression
            self.formattingType = formattingType
        }
        mutating func mapping(map: Map) {
            expression     <- map["expression"]
            alias          <- map["alias"]
            formattingType <- map["formattingType"]
        }
    }
    
    struct MetricFilter: Mappable {
        var metricName: String?
        var not: Bool?
        var operat: Operator?
        var comparisonValue: String?
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            metricName      <- map["metricName"]
            not             <- map["not"]
            operat          <- map["operator"]
            comparisonValue <- map["comparisonValue"]
        }
    }
    
    struct MetricFilterClause: Mappable {
        var operat: FilterLogicalOperator?
        var filters: MetricFilter?
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            operat  <- map["operator"]
            filters <- map["filters"]
        }
    }
    
    enum OrderType: String {
        case ORDER_TYPE_UNSPECIFIED
        case VALUE
        case DELTA
        case SMART
        case HISTOGRAM_BUCKET
        case DIMENSION_AS_INTEGER
    }
    
    enum SortOrder: String {
        case SORT_ORDER_UNSPECIFIED
        case ASCENDING
        case DESCENDING
    }
    
    struct OrderBy: Mappable {
        var fieldName: String?
        var orderType: OrderType?
        var sortOrder: SortOrder?
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            fieldName <- map["fieldName"]
            orderType <- map["orderType"]
            sortOrder <- map["sortOrder"]
        }
    }
    
    struct SegmentDimensionFilter: Mappable {
        var dimensionName: String?
        var operat: Operator?
        var caseSensitive: Bool?
        var expressions: [String]? = []
        var minComparisonValue: String?
        var maxComparisonValue: String?
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            dimensionName      <- map["dimensionName"]
            operat             <- map["operator"]
            caseSensitive      <- map["caseSensitive"]
            expressions        <- map["expressions"]
            minComparisonValue <- map["minComparisonValue"]
            maxComparisonValue <- map["maxComparisonValue"]
        }
    }
    
    enum Scope: String {
        case UNSPECIFIED_SCOPE
        case PRODUCT
        case HIT
        case SESSION
        case USER
    }
    
    struct SegmentMetricFilter: Mappable {
        var scope: Scope?
        var metricName: String?
        var operat: Operator?
        var comparisonValue: String?
        var maxComparisonValue: String?
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            scope              <- map["scope"]
            metricName         <- map["metricName"]
            operat             <- map["operator"]
            comparisonValue    <- map["comparisonValue"]
            maxComparisonValue <- map["maxComparisonValue"]
        }
    }
    
    struct SegmentFilterClause: Mappable {
        var not: Bool?
        var dimensionFilter: SegmentDimensionFilter?
        var metricFilter: SegmentMetricFilter?
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            not             <- map["not"]
            dimensionFilter <- map["dimensionFilter"]
            metricFilter    <- map["metricFilter"]
        }
    }
    
    struct OrFiltersForSegment: Mappable {
        var segmentFilterClauses: [SegmentFilterClause]? = []
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            segmentFilterClauses <- map["segmentFilterClauses"]
        }
    }
    
    struct SimpleSegment: Mappable {
        var orFiltersForSegment: [OrFiltersForSegment]? = []
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            orFiltersForSegment <- map["orFiltersForSegment"]
        }
    }
    
    enum MatchType: String {
        case UNSPECIFIED_MATCH_TYPE
        case PRECEDES
        case IMMEDIATELY_PRECEDES
    }
    
    struct SegmentSequenceStep: Mappable {
        var orFiltersForSegment: [OrFiltersForSegment]? = []
        var matchType: MatchType?
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            orFiltersForSegment <- map["orFiltersForSegment"]
            matchType           <- map["matchType"]
        }
    }
    
    struct SequenceSegment: Mappable {
        var segmentSequenceSteps: SegmentSequenceStep?
        var firstStepShouldMatchFirstHit: Bool?
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            segmentSequenceSteps         <- map["segmentSequenceSteps"]
            firstStepShouldMatchFirstHit <- map["firstStepShouldMatchFirstHit"]
        }
    }
    
    struct SegmentFilter: Mappable {
        var not: Bool?
        var simpleSegment: SimpleSegment?
        var sequenceSegment: SequenceSegment?
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            not             <- map["not"]
            simpleSegment   <- map["simpleSegment"]
            sequenceSegment <- map["sequenceSegment"]
        }
    }
    
    struct SegmentDefinition: Mappable {
        var segmentFilters: [SegmentFilter]? = []
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            segmentFilters <- map["segmentFilters"]
        }
    }
    
    struct DynamicSegment: Mappable {
        var name: String?
        var userSegment: SegmentDefinition?
        var sessionSegment: SegmentDefinition?
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            name           <- map["name"]
            userSegment    <- map["userSegment"]
            sessionSegment <- map["sessionSegment"]
        }
    }
    
    struct Segment: Mappable {
        var dynamicSegment: DynamicSegment?
        var segmentId: String?
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            dynamicSegment <- map["dynamicSegment"]
            segmentId      <- map["segmentId"]
        }
    }
    
    struct Pivot: Mappable {
        var dimensions: [Dimension]? = []
        var dimensionFilterClauses: [DimensionFilterClause]? = []
        var metrics: [Metric]? = []
        var startGroup: Int?
        var maxGroupCount: Int?
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            dimensions             <- map["dimensions"]
            dimensionFilterClauses <- map["dimensionFilterClauses"]
            metrics                <- map["metrics"]
            startGroup             <- map["startGroup"]
            maxGroupCount          <- map["maxGroupCount"]
        }
    }
    
    enum CohortType: String {
        case UNSPECIFIED_COHORT_TYPE
        case FIRST_VISIT_DATE
    }
    
    struct Cohort: Mappable {
        var name: String?
        var type: CohortType?
        var dateRange: DateRange?
        init?(map: Map) {
        }
        init?(name: String?, type: CohortType, startDate: String, endDate: String) {
            self.name = name
            self.type = type
            self.dateRange = DateRange(startDate: startDate, endDate: endDate)
        }
        mutating func mapping(map: Map) {
            name      <- map["name"]
            type      <- map["type"]
            dateRange <- map["dateRange"]
        }
    }
    
    struct CohortGroup: Mappable {
        var cohorts: [Cohort]? = []
        var lifetimeValue: Bool?
        init(cohorts: [Cohort]) {
            self.cohorts = cohorts
        }
        init?(map: Map) {
        }
        mutating func mapping(map: Map) {
            cohorts       <- map["cohorts"]
            lifetimeValue <- map["lifetimeValue"]
        }
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
        var isDataGolden: Bool? = false
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
