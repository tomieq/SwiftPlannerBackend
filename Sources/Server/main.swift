import Dispatch
import Foundation

let server = HttpServer()
let application = WebApplication(server)

let semaphore = DispatchSemaphore(value: 0)
do {
    try server.start(5100, forceIPv4: true)
    print("Server has started ( port = \(try server.port()) dir = \(FileManager.default.currentDirectoryPath)).")
    semaphore.wait()
} catch {
    print("Server start error: \(error)")
    semaphore.signal()
}


