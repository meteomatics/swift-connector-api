//
//  ContentView.swift
//  MeteomaticsConnector
//
//  Created by Alin Fusaru on 28.03.2022.
//


//         Will fetch the temperature at 2m in Celsius and the wind speed at 850hPa in mps for present time in Berlin in the JSON format

//        For time interval use the initializer with startDate/endDate, you will have to adjust the validDdateTime in Meteomatics.createPath() method with your prefered time step
//          Check description of mandatory fields at https://www.meteomatics.com/en/api/request/required-parameters/

import SwiftUI
import CoreLocation

struct ContentView: View {
    var meteo: Meteomatics
    
    var date = Date()
//    Full list of available parameters at https://www.meteomatics.com/en/api/available-parameters/alphabetic-list/
    var parameters = ["t_2m:C", "wind_speed_850hPa:ms"]
    var latitude = 52.520551
    var longitude = 13.461804
    var user = "Your-User-Here"
    var password = "Your-Password-Here"
    
    init() {
        meteo = Meteomatics(forDate: date, parameters: self.parameters, latitude: self.latitude, longitude: self.longitude, user: self.user, password: self.password)
    }
    
    @State var weather: MeteomaticsData = MeteomaticsData()
    var body: some View {
        Text("\(weather.data[0].coordinates[0].dates[0].value)")
            .task {
                do {
                    weather = try await meteo.fetchWeather()
                } catch {
                    print(error)
                }
            }
        
            .padding()

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
