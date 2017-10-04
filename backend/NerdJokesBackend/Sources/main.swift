import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

let server = HTTPServer()
server.serverPort = 8080

let noteController = NoteController()
server.addRoutes(Routes(noteController.routes))

JokeAPI.sharedInstance.setupDatabase()

do {
    try server.start()
} catch PerfectError.networkError(let error, let message) {
    fatalError("Can't start the server! \(error) \(message)")
}

