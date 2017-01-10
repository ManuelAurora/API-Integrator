//
//  KPIList.swift
//  CoreKPI
//
//  Created by Семен on 09.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class BuildInKPI {
    var departmentOfKpi: Departments
    var salesDictionary = [
        "New Contacts Rate" : "The figure which is being monitored almost by every manager in the US. It is used by organizations to determine whether their sales team promotes business expansion on the particular territory, as well as to define too low / high rate of sales.",
        "Sales Volume Per Location" : "The indicator showing the efficiency of the entire branch / unit, more often, by comparison with the other branches. Mainly used to determine maximum territorial effectiveness of the product and the reasons for it.",
        "Lead response time" : "The indicator shows how quickly a new lead received a response from the representative of the organization. One of the key indicators to determine the effectiveness of sales departments.",
        "Client Acquisition Rate" : "The indicator that displays the ratio of transferring the potential customers into the active clients.",
        "Lead Flow":"Indicator that determines the rate of generation of new leads.",
        "Contact Rate/ Reach Rate" : "Factor that determines the percentage of leads with which the contact was made to the total number of leads.",
        "Rate of Follow-up Contact" : "The percentage of leads which called the representatives of the organization after the initial contact.",
        "Opportunity-to-Win Ratio" : "Indicator that determines how effectively the staff works with leads and closes the deals.",
        "Sales Growth":"Indicator that determines the company's sales growth rate.",
        "Average Profit Margin" : "The indicator that measures the average income received for the sale of a particular product / service.",
        ]
    var procurementDictionary = [
    "Cost Savings" : "Indicator that determines the amount of money saved by reducing costs.",
    "Return on Investment - ROI" : "One of the key indicators for western organizations that mainly help to determine the economic efficiency of the Procurement Department.",
    "Percent of On-Time Supplier Deliveries" : " KPI that determines how effectively the Procurement Department receives the goods needed when it’s necessary.",
    "Supplier defect rate" : "An important parameter that determines the quality of the purchases made by the Procurement Department.",
    "Procurement Cycle Time" : "The indicator used to measure the efficiency of the Procurement Department. Basically, it is the period of time between sending a request to supplier and placing an order.",
    "Cost Savings as a Percentage of Managed Spend" : "This index reflects an important indicator of how well the Procurement Department copes with the responsibilities entrusted to it.",
    "Managed Spend as a Percentage of Total Spend" : "Administrative costs are fully controlled by the Procurement Department. Basically, this figure shows how the manager or head trusts the capabilities of the procurement.",
    "Procurement Operating Costs as a Percentage of Managed Spend" : "Operating expenses of the Sales Department represent the cost for maintaining the Procurement Department.  The examples of such expenses: maintenance of the building costs, costs of hardware and software, etc. This KPI determines the efficiency of costs for the Procurement Department.",
    "Purchase Dollars as a percent of Sales Dollars" : "Indicator that determines how effectively the funds are used by the Purchasing Department to stimulate sales.",
    "Purchase Dollars spent per active supplier" : " Indicator that determines the effectiveness of investment and monitoring the dynamics of prices of suppliers."
    ]
    var projectDictionary = [
        "Return on Investment - ROI" : "One of the most important KPIs in project management that shows the profitability of the project.",
        "Planned Value - PV or Budgeted Cost of Work Scheduled - BCWS" : "It is the estimated cost of the project activities planned at the balance sheet date.",
        "Actual Cost - AC or The Actual Cost of Work Performed - ACWP" : "The indicator that shows how much money is actually spent on the project to date.",
        "Earned Value - EV or Budgeted Cost of Work Performed - BCWP" : "The indicator that shows how much of the total amount of work has already been done and the cost of work performed.",
        "Cost Variance – CV. The cost variance is directly related to the cost of the project." : "The indicator that displays how the actual budget deviated from the planned budget.",
        "Cost Performance Index - CPI" : "The indicator that helps to assess whether the project is behind / ahead of the approved project schedule.",
        "Cost of managing process" : "This KPI will show how much time and resources are spent on management and project control.",
        "Crossed deadlines / overdue project tasks" : "Figure that is basically displayed as a percentage of the total number of tasks, showing the overall efficiency of project participants.",
        "Dispersion schedule" : "This figure shows how the project is behind / ahead of the planned project budget (as well as the approved schedule)",
        "Schedule performance index - SPI" : "This figure mainly defines how the project is behind / ahead of the approved schedule. This figure is largely similar to the previous ones but with a slight difference: it is used to determine the effectiveness of the senior management of the project and displayed in the coefficient."
    ]
    var financialManagementDictionary = [
        "Working Capital - WC" : "This figure is mainly used for the definition of <financial health> of the organization and represents the money that can be used immediately.",
        "Operating Cash Flow." : "This is a key indicator for the analysis which determines whether a company produces a sufficient amount of cash to maintain their capital investments.",
        "Current Ratio." : "The factor that determines how much solvent the organization is.",
        "Payroll Headcount Ratio" : "This KPI is common mainly for the United States. Basically, it displays the number of employees on full-time.",
        "Return on Equity - ROE" : "This indicator measures the profitability of the organization as well as the effectiveness of its work.",
        "Debt to equity ratio" : "An indicator that determines how the organization finances its growth and how to effectively use the investment of shareholders.",
        "Accounts Payable Turnover" : "This KPI shows how quickly the company is able to pay its suppliers and other costs. This indicator is important to determine the amount of money that an organization spends on suppliers for a certain period of time.",
        "Accounts Receivable Turnover" : "The indicator that measures the rate at which the organization receives money from customers.",
        "Net Profit Margin" : " An indicator that determines how effectively a company generates profit for every dollar of income. The indicator is used to determine the profitability of the business and helps to make the short-term / long-term solutions.",
        "Gross Profit Margin" : "An indicator that determines the profit of the company for every dollar spent."
    ]
    var staffDictionary = [
    "Employee productivity rate" : "This index is used to measure the overall effectiveness of the labor force for a certain time (usually a quarter or a year).",
    "Revenue per employee" : "The indicator mainly defines the actuality of the number of employees, the costs of losing an employee and staff turnover costs.",
    "Customer service" : "This rate determines how satisfied the customers of the company feel.",
    "The time required for the realization of the task" : "The index of time required the employee to perform the job. It is mainly used to determine the chance of performing tasks on time.",
    "Absenteeism rate" : "The median which determines the percentage of absences. It is mainly used to determine the causes of unfulfilled tasks or employees’ motivation.",
    "Staff turnover" : "Indicator that determines the staff turnover rate at the moment and its expenses to the company.",
    "Human Capital Value Added" : "The median determining the profitability per employee in the company.",
    "Percentage of Cost of Workforce" : "It is a measure of labor costs as a percentage of total expenses. One of the most popular KPI used to determine the effectiveness of the use of funds for the development of the company.",
    "Employee Satisfaction rate" : "An important index in the business culture that every HR-manager carefully tracks. Defines the overall satisfaction of employees.",
    "Percentage of workforce below performance standards" : "The indicator determines an overall inefficient of the employees in the company, as well as the effectiveness of a given goal / plan."
    ]

    init(department: Departments) {
        self.departmentOfKpi = department
    }
    
}
