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

        server["/params/*"] = { request in
            return .ok(.html("\(request.queryParams)"))
            
        }

        server["/post"] = { [weak self] request in
            return HttpResponse.ok(.text(request.bodyString ?? "nic"))
        }
        server["/magic"] = { .ok(.htmlBody("You asked for " + $0.path)) }
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
