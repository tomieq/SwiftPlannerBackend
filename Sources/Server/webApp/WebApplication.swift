//
//  WebApplication.swift
//  
//
//  Created by Tomasz Kucharski on 23/12/2020.
//

import Foundation

class WebApplication {
    
    init(_ server: HttpServer) {
        server["/json"] = { request in
            return SampleDto(id: 22, name: "janek").asInvalidRsponse()
            
        }

        server["/planning"] = { [weak self] request in
            
            //print("Planning request")
            //print("\(request.bodyString ?? "")")
        
            
            do {
                let inputDto = try JSONDecoder().decode(InputDto.self, from: Data(request.bodyString!.utf8))
                //print("\(inputDto.debugDescription)")
                
                let daysToPlan = (inputDto.daysInMonth ?? 0) * (inputDto.workplaces?.count ?? 0)
                let resourceAmount = inputDto.users?.count ?? 0
                let resourceWorkingDaySum = inputDto.users?.compactMap{ $0.maxWorkingDays }.reduce(0, { x, y in
                    x + y
                }) ?? 0
                print("--------------------------------------------------------")
                print("Received request to plan resorces for \(daysToPlan) days")
                print("Input data has \(resourceAmount) resources and \(resourceWorkingDaySum) days to cover")
                
                guard let model = ModelBuilder.buildModel(dto: inputDto) else {
                    return .badRequest(nil)
                }
                let engine = ScheduleEngine(model: model)
                engine.exec()
                
                let outputDto = ModelBuilder.buildOutputDto(model: model)
                //print("\(outputDto.debugDescription)")
                return outputDto.asValidRsponse()
            } catch let error {
                print("Error deserializing data \(error.localizedDescription)")
                return HttpResponse.badRequest(.text(error.localizedDescription))
            }
            return HttpResponse.internalServerError
        }
    }
}



struct SampleDto: Encodable {
    let id: Int
    let name: String
}

extension Encodable {

    func asValidRsponse() -> HttpResponse {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return HttpResponse.ok(HttpResponseBody.data(jsonData, contentType: "application/json"))
        } catch {
            return HttpResponse.internalServerError
        }
    }

    func asInvalidRsponse() -> HttpResponse {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return HttpResponse.badRequest(HttpResponseBody.data(jsonData, contentType: "application/json"))
        } catch {
            return HttpResponse.internalServerError
        }
    }
}
