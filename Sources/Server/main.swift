import Dispatch

let server = demoServer("/")

let semaphore = DispatchSemaphore(value: 0)
do {
    try server.start(9080, forceIPv4: true)
    print("Server has started ( port = \(try server.port()) ). Try to connect now...")
    semaphore.wait()
} catch {
    print("Server start error: \(error)")
    semaphore.signal()
}
