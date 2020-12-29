//
//  WebApplication.swift
//  
//
//  Created by Tomasz Kucharski on 23/12/2020.
//

import Foundation

class WebApplication {
    
    init(_ server: HttpServer) {

        server.POST["/planning"] = { request in
            
            guard let bodyString = request.bodyString, !bodyString.isEmpty else {
                Logger.error("Input data", "Empty request body")
                return .badRequest(nil)
            }
            
            do {
                let inputDto = try JSONDecoder().decode(InputDto.self, from: Data(request.bodyString!.utf8))
                //Logger.debug("InputDto", inputDto.debugDescription)
                
                let daysToPlan = (inputDto.daysInMonth ?? 0) * (inputDto.workplaces?.count ?? 0)
                let resourceAmount = inputDto.users?.count ?? 0
                print("--------------------------------------------------------")
                print("Received request to plan resorces for \(daysToPlan) days")
                print("Input data has \(resourceAmount) resources")
                
                guard let model = ModelBuilder.makeModel(from: inputDto) else {
                    return .badRequest(nil)
                }
                let engine = ScheduleEngine(model: model)
                engine.exec()
                
                let outputDto = ModelBuilder.makeOutputDto(from: engine.bestModel)
                //Logger.debug("Outcoming body", outputDto.debugDescription)
                return outputDto.asValidRsponse()
            } catch let error {
                Logger.debug("Incoming body", bodyString)
                Logger.error("Input data", "Problem with deserializing the data \(error.localizedDescription)")
                return HttpResponse.badRequest(.text(error.localizedDescription))
            }
        }
    }
}
