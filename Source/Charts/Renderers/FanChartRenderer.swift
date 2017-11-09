//
//  FanChartRenderer.swift
//  Charts
//
//  Created by Pouria Almassi on 9/11/17.
//

import Foundation

class FanChartRenderer: LineChartRenderer {

    // todo pba tmp remove
    struct Constant
    {
        struct ProjectionChart
        {
            static let dataSetOffset: Int = 1
            static let shortTargetMonths: Int = 1
        }
    }

    override init(dataProvider: LineChartDataProvider?,
                  animator: Animator?,
                  viewPortHandler: ViewPortHandler?) {
        super.init(dataProvider: dataProvider,
                   animator: animator,
                   viewPortHandler: viewPortHandler)
    }

    override func drawLinearFill(context: CGContext,
                                 dataSet: ILineChartDataSet,
                                 trans: Transformer,
                                 bounds: XBounds)
    {
        guard let dataProvider = dataProvider else
        {
            return
        }

        let filled = self.generateFilledPath(
            dataSet: dataSet,
            fillMin: dataSet.fillFormatter?.getFillLinePosition(dataSet: dataSet, dataProvider: dataProvider) ?? 0.0,
            bounds: bounds,
            matrix: trans.valueToPixelMatrix)

        if dataSet.fill != nil
        {
            drawFilledPath(context: context, path: filled, fill: dataSet.fill!, fillAlpha: dataSet.fillAlpha)
        }
        else
        {
            drawFilledPath(context: context, path: filled, fillColor: dataSet.fillColor, fillAlpha: dataSet.fillAlpha)
        }
    }

    /// Generates the path that is used for filled drawing.
    private func generateFilledPath(dataSet: ILineChartDataSet, fillMin: CGFloat, bounds: XBounds, matrix: CGAffineTransform) -> CGPath
    {
        let phaseY = animator?.phaseY ?? 1.0
        let _ = dataSet.mode == .stepped
        let matrix = matrix
        var boundaryEntryOptional: [ChartDataEntry]?
        var entry: ChartDataEntry!
        let filled = CGMutablePath()

        if let ff = dataSet.fillFormatter as? FanFillFormatter,
            let flb = ff.getFillLineBoundary() {
            boundaryEntryOptional = flb
        }

        entry = dataSet.entryForIndex(bounds.min)

        // start point
        //
        //    -
        //   -
        //  -
        // *
        //
        // ===========
        let startPoint = CGPoint(x: entry.x, y: entry.y)
        filled.move(to: startPoint, transform: matrix)

        // top edge
        //
        //     *
        //    -
        //   -
        //  -
        //
        // ===========

        var currentLineEntry: ChartDataEntry?

        for x in stride(from: (bounds.min + 1), through: bounds.range + bounds.min, by: 1) {
            guard let e = dataSet.entryForIndex(x) else { continue }

            // used for connecting right edge of fill area.
            // we'll need the last point along the top edge.
            currentLineEntry = e

            // never actually called
            // if isDrawSteppedEnabled {
            //     guard let ePrev = dataSet.entryForIndex(x-1) else { continue }
            //     let p = CGPoint(x: CGFloat(e.x), y: CGFloat(ePrev.y * phaseY))
            //     filled.addLine(to: p, transform: matrix)
            // }

            let p = CGPoint(x: CGFloat(e.x), y: CGFloat(e.y * phaseY))
            filled.addLine(to: p, transform: matrix)
        }

        // right edge
        //  |
        //  |
        //  |
        //  *
        guard let boundaryEntry = boundaryEntryOptional else { return CGPath(ellipseIn: CGRect.zero, transform: nil) }
        guard let boundaryEntryLast = boundaryEntry.last, let _ = currentLineEntry else { return CGPath(ellipseIn: CGRect.zero, transform: nil) }

        let p = CGPoint(x: boundaryEntryLast.x, y: boundaryEntryLast.y)
        filled.addLine(to: p, transform: matrix)

        // bottom edge
        //
        // *-----------
        //
        // ===========
        for x in boundaryEntry.reversed() {
            let p = CGPoint(x: CGFloat(x.x), y: CGFloat(x.y * phaseY))
            filled.addLine(to: p, transform: matrix)
        }

        // close up
        // |
        // |
        // |
        // *
        // *-----------
        //
        // ===========
        entry = dataSet.entryForIndex(bounds.range + bounds.min)
        if entry != nil {
            filled.addLine(to: CGPoint(x: CGFloat(entry.x), y: fillMin), transform: matrix)
        }
        filled.closeSubpath()

        return filled
    }

    open override func drawValues(context: CGContext)
    {
        guard
            let dataProvider = dataProvider,
            let lineData = dataProvider.lineData,
            let animator = animator,
            let viewPortHandler = self.viewPortHandler
            else {
                return
        }
        var dataSets = lineData.dataSets

        let phaseY = animator.phaseY

        var pt = CGPoint()

        for i in 0 ..< dataSets.count
        {
            guard let dataSet = dataSets[i] as? ILineChartDataSet else { continue }

            let valueFont = dataSet.valueFont

            guard let formatter = dataSet.valueFormatter else { continue }

            let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
            let valueToPixelMatrix = trans.valueToPixelMatrix

            let iconsOffset = dataSet.iconsOffset

            // make sure the values do not interfear with the circles
            var valOffset = Int(dataSet.circleRadius * 1.75)

            if !dataSet.isDrawCirclesEnabled
            {
                valOffset = valOffset / 2
            }

            _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)

            for j in stride(from: _xBounds.min, through: min(_xBounds.min + _xBounds.range, _xBounds.max), by: 1)
            {
                if j == Int(_xBounds.max - Constant.ProjectionChart.dataSetOffset)
                {
                    // Check if is on short target month then use the `dataSet.entryCount` to find the offset
                    guard let e = j > Constant.ProjectionChart.shortTargetMonths ? dataSet.entryForIndex(j) : dataSet.entryForIndex(dataSet.entryCount - (Constant.ProjectionChart.shortTargetMonths - Constant.ProjectionChart.dataSetOffset)) else
                    {
                        break
                    }

                    pt.x = CGFloat(e.x)
                    pt.y = CGFloat(e.y * phaseY)
                    pt = pt.applying(valueToPixelMatrix)

                    if (!viewPortHandler.isInBoundsRight(pt.x))
                    {
                        break
                    }

                    if (!viewPortHandler.isInBoundsLeft(pt.x) || !viewPortHandler.isInBoundsY(pt.y))
                    {
                        continue
                    }

                    if dataSet.isDrawValuesEnabled
                    {
                        ChartUtils.drawText(
                            context: context,
                            text: formatter.stringForValue(
                                e.y,
                                entry: e,
                                dataSetIndex: i,
                                viewPortHandler: viewPortHandler),
                            point: CGPoint(
                                x: pt.x,
                                y: pt.y - CGFloat(valOffset) - valueFont.lineHeight),
                            align: .center,
                            attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: dataSet.valueTextColorAt(j)])
                    }

                    if let icon = e.icon, dataSet.isDrawIconsEnabled
                    {
                        ChartUtils.drawImage(context: context,
                                             image: icon,
                                             x: pt.x + iconsOffset.x,
                                             y: pt.y + iconsOffset.y,
                                             size: icon.size)
                    }
                }
            }
        }
    }
}
