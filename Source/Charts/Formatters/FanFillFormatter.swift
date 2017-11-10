//
//  FanFillFormatter.swift
//  Charts
//
//  Created by Pouria Almassi on 9/11/17.
//

import Foundation

open class FanFillFormatter: IFillFormatter {

    private var boundaryDataSet : LineChartDataSet?

    public init(boundaryDataSet: LineChartDataSet,
                fillColor: NSUIColor)
    {
        self.boundaryDataSet = boundaryDataSet
        self.boundaryDataSet?.fillColor = fillColor
        self.boundaryDataSet?.drawFilledEnabled = true
    }

    open func getFillLinePosition(dataSet: ILineChartDataSet,
                                  dataProvider: LineChartDataProvider) -> CGFloat
    {
        return 0
    }

    open func getFillLineBoundary() -> [ChartDataEntry]?
    {
        guard let boundaryDataSet = boundaryDataSet else
        {
            return nil
        }

        return boundaryDataSet.values
    }
}
