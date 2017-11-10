//
//  FanLineDemoViewController.swift
//  ChartsDemo-OSX
//
//  Created by Pouria Almassi on 10/11/17.
//  Copyright © 2017 dcg. All rights reserved.
//

import Foundation
import Cocoa
import Charts

open class FanLineDemoViewController: NSViewController
{
    @IBOutlet var lineChartView: LineChartView!

    override open func viewDidLoad()
    {
        super.viewDidLoad()

        let ys1 = Array(1..<10).map { x in return linear(Double(x * 3)) }
        let ys2 = Array(1..<10).map { x in return linear(Double(x * 2)) }

        let yse1 = ys1.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
        let yse2 = ys2.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }

        let data = LineChartData()

        let ds1Color = NSUIColor.red
        let ds1 = LineChartDataSet(values: yse1, label: "Hello")
        ds1.colors = [ds1Color]

        let ds2Color = NSUIColor.blue
        let ds2 = LineChartDataSet(values: yse2, label: "World")
        ds2.colors = [ds2Color]

        ds2.fillFormatter = FanFillFormatter(boundaryDataSet: ds1, fillColor: ds2Color)
        ds1.fillFormatter = FanFillFormatter(boundaryDataSet: ds2, fillColor: ds1Color)

        data.addDataSet(ds1)
        data.addDataSet(ds2)
        self.lineChartView.data = data

        self.lineChartView.gridBackgroundColor = NSUIColor.white
        self.lineChartView.chartDescription?.text = "Linechart Demo"
    }

    override open func viewWillAppear()
    {
        self.lineChartView.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
    }
    
    private func linear(_ x: Double) -> Double {
        return x * 1
    }
}
