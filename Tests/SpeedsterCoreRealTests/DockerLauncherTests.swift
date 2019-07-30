@testable import SpeedsterCore
import ShellKit
import Fluent
import XCTest


final class DockerLauncherTests: XCTestCase {
    
    let dockerFile = """
FROM einstore/swift:latest
MAINTAINER DockerLauncherTests<dev@einstore.io>
RUN cd /usr/ && pwd && ls
CMD echo "Hello world"
"""
    
    let dockerFilePath = "/tmp/speedster/tests/hello.dockerfile"
    
    var launcher: Launcher!
    var random: String!
    var randomPath: String!
    var eventLoop: EmbeddedEventLoop!
    var node: Row<Node>!
    var shell: Shell!
    
    
    override func setUp() {
        super.setUp()
        
        random = UUID().uuidString
        eventLoop = EmbeddedEventLoop()
        node = Node.row()
        node.name = "localhost"
        node.host = "localhost"
        node.port = 0
        node.user = "root"
        node.password = nil
        node.privateKey = nil
        shell = try! Shell(node.asShellConnection(), on: eventLoop)
        launcher = try! DockerLauncher(
            Root.Env(
                image: .docker(image: "einstore/hello"),
                memory: "128MiB",
                storage: "128MiB",
                mounts: [
                    "/tmp/speedster/tests/files/\(random!)": "/tmp/random/"
                ],
                variables: [
                    "MESSAGE": "hello world",
                    "RANDOM": random
                ],
                build: "docker build -t einstore/hello \(dockerFilePath)"
            ),
            node: node,
            on: eventLoop
        )
        
        if !FileManager.default.fileExists(atPath: dockerFilePath) {
            try! dockerFile.write(toFile: dockerFilePath, atomically: true, encoding: .utf8)
        }
    }
    
    override func tearDown() {
        super.tearDown()
        
        try! FileManager.default.removeItem(atPath: randomPath)
    }
    
    func testDockerStarts() {
        
    }
    
    static let allTests = [
        ("testDockerStarts", testDockerStarts),
    ]
    
}
