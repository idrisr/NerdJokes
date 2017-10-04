import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

let server = HTTPServer()
server.serverPort = 8080

let jokeController = JokeController()
server.addRoutes(Routes(jokeController.routes))

JokeAPI.sharedInstance.setupDatabase()

do {
    try server.start()
} catch PerfectError.networkError(let error, let message) {
    fatalError("Can't start the server! \(error) \(message)")
}

