//
//  FanFillFormatter.swift
//  Charts
//
//  Created by Pouria Almassi on 9/11/17.
//

import Foundation

final class FanFillFormatter: IFillFormatter {

    private var boundaryDataSet : LineChartDataSet?

    init(boundaryDataSet: LineChartDataSet)
    {
        self.boundaryDataSet = boundaryDataSet
    }

    func getFillLinePosition(dataSet: ILineChartDataSet, dataProvider: LineChartDataProvider) -> CGFloat
    {
        return 0
    }

    func getFillLineBoundary() -> [ChartDataEntry]?
    {
        guard let boundaryDataSet = boundaryDataSet else
        {
            return nil
        }

        return boundaryDataSet.values
    }
}

