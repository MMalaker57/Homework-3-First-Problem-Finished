//
//  ContentView.swift
//  Shared
//
//  Created by Jeff Terry on 1/25/21.
//

import SwiftUI
import CorePlot

typealias plotDataType = [CPTScatterPlotField : Double]

struct ContentView: View {
    @EnvironmentObject var plotData :PlotClass
    
    @ObservedObject var integral = MonteCarloExp()
    @ObservedObject private var calculator = CalculatePlotData()
    @State var isChecked:Bool = false
    @State var tempInput = ""
    @State var plotInformation: [(numberOfGuesses: UInt64, integralError: Double, pointsBelowCurve: [(xPoint:Double, yPoint:Double)], pointsAboveCurve: [(xPoint: Double, yPoint: Double)])] = []
    @State var belowPointsToDraw: [(xPoint: Double, yPoint: Double)] = []
    @State var abovePointsToDraw: [(xPoint: Double, yPoint: Double)] = []
//    @State var dataToPlot: [(numberOfGuesses: UInt64, integralError: Double)]
    
    @State var selector = 0

    var body: some View {
        
        VStack{
            HStack{
            CorePlot(dataForPlot: $plotData.plotArray[selector].plotData, changingPlotParameters: $plotData.plotArray[selector].changingPlotParameters)
                .setPlotPadding(left: 10)
                .setPlotPadding(right: 10)
                .setPlotPadding(top: 10)
                .setPlotPadding(bottom: 10)
                .padding()
            
            Divider()
                drawingView(redLayer:$belowPointsToDraw, blueLayer: $abovePointsToDraw)
                    .padding()
                    .aspectRatio(1, contentMode: .fit)
                    .drawingGroup()
                // Stop the window shrinking to zero.
                Spacer()
            
            }
                        
            HStack{
                
                HStack(alignment: .center) {
                    Text("temp:")
                        .font(.callout)
                        .bold()
                    TextField("temp", text: $tempInput)
                        .padding()
                }.padding()
                
                Toggle(isOn: $isChecked) {
                            Text("Display Error")
                        }
                .padding()
                
                
            }
            
            
            HStack{
                Button("Calculate", action: {Task.init{plotInformation = await self.calculateEXPIntegralPlotData(passedLowerBound: 0.0, passedUpperBound: 1.0, guessesSet: [10,20,50,100,200,500,10000,50000])}}
                
                
                )
                .padding()
                
            }
            
            HStack{
                Button("Draw", action: {belowPointsToDraw = plotInformation.last?.pointsBelowCurve ?? [(xPoint: 0.0, yPoint: 0.0)]; abovePointsToDraw = plotInformation.last?.pointsAboveCurve ?? [(xPoint: 0.0, yPoint: 0.0)]})
                .padding()
                
            }
            
        }
        
    }
    
    
    func calculateEXPIntegralPlotData(passedLowerBound: Double, passedUpperBound: Double, guessesSet: [UInt64]) async->[(numberOfGuesses: UInt64, integralError: Double, pointsBelowCurve: [(xPoint:Double, yPoint:Double)], pointsAboveCurve: [(xPoint:Double, yPoint:Double)])]{
        
        let plotDataStructure = await withTaskGroup(of: (UInt64,  Double, [(Double, Double)],[(Double, Double)]).self, returning: [(numberOfGuesses: UInt64, integralError: Double,pointsBelowCurve: [(xPoint:Double, yPoint:Double)], pointsAboveCurve: [(xPoint:Double, yPoint:Double)])].self, body: {taskGroup in
            //Initialize each task in desired plot range
            for i in guessesSet{
                taskGroup.addTask {
                    //Create return value. This is a complex computation, hence the threading
                    let valueStructure = await integral.calculateEXPIntegral(lowerBound: passedLowerBound, upperBound: passedUpperBound, maximumGuesses: i)
//                    print(value)
                    let errorAtGuess = await integral.calculateIntegralError(passedLowerBound: passedLowerBound, passedUpperBound: passedUpperBound, passedExponentScale: 1.0, monteCarloValue: valueStructure.integral)
//                    print(errorAtGuess)
                    return (UInt64(i),errorAtGuess, valueStructure.belowPoints, valueStructure.abovePoints)
                }
            }
            //Take results as they come in and assign them to their proper place
            //We do not know the order these tasks will finish in, so we use a tuple to assign each result its value
            var interimResults = [(numberOfGuesses: UInt64, integralError: Double,pointsBelowCurve: [(xPoint:Double, yPoint:Double)], pointsAboveCurve: [(xPoint:Double, yPoint:Double)])]()
            //reordering results as they come in
            for await result in taskGroup{
                interimResults.append(result)
            }
            return interimResults.sorted(by: {$0.numberOfGuesses < $1.numberOfGuesses})
            
        })
        setupPlotDataModel(selector: 0)
        var plotData: [(numberOfGuesses: UInt64, integralError: Double)] = []
        for i in plotDataStructure{
            plotData.append((i.numberOfGuesses,i.integralError))
                    
        }
        await calculator.ploteToTheMinusX(dataToPlot: plotData)
        self.plotData.objectWillChange.send()
        
        
        
        return plotDataStructure
    }
    
    
    @MainActor func setupPlotDataModel(selector: Int){
        
        calculator.plotDataModel = self.plotData.plotArray[selector]
    }
    
    
    /// calculate
    /// Function accepts the command to start the calculation from the GUI
    func calculate() async {
        
        //pass the plotDataModel to the Calculator
       // calculator.plotDataModel = self.plotData.plotArray[0]
        
        setupPlotDataModel(selector: 0)
        
     //   Task{
            
            
            let _ = await withTaskGroup(of:  Void.self) { taskGroup in



                taskGroup.addTask {

        
        var temp = 0.0
        
        
        
        //Calculate the new plotting data and place in the plotDataModel
//                    await calculator.ploteToTheMinusX(dataToPlot: )
        
                    // This forces a SwiftUI update. Force a SwiftUI update.
        await self.plotData.objectWillChange.send()
                    
                }

                
            }
            
  //      }
        
        
    }
    
    /// calculate
    /// Function accepts the command to start the calculation from the GUI
    func calculate2() async {
        
        
        //pass the plotDataModel to the Calculator
       // calculator.plotDataModel = self.plotData.plotArray[0]
        
        setupPlotDataModel(selector: 1)
        
     //   Task{
            
            
            let _ = await withTaskGroup(of:  Void.self) { taskGroup in



                taskGroup.addTask {

        
        var temp = 0.0
        
        
        
        //Calculate the new plotting data and place in the plotDataModel
        await calculator.plotYEqualsX()
                  
                    // This forces a SwiftUI update. Force a SwiftUI update.
        await self.plotData.objectWillChange.send()
                    
                }
                
            }
            
    //    }
        
        

    }
    

   
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
