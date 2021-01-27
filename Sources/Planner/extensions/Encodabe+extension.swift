//
//  Encodable+extension.swift
//  
//
//  Created by Tomasz Kucharski on 29/12/2020.
//

import Foundation

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
