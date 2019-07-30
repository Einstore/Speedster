import DockerCommandKit
import XCTest
import NIO


final class DockerCommandsTests: XCTestCase {
    
    var shell: Shell!
    
    override func setUp() {
        super.setUp()
        
        shell = try! Shell(.local, on: EmbeddedEventLoop())
    }
    
    func testBuild() {
        let res = shell.docker.commandBuilder.build(
            file: "/some/Dockerfile",
            tag: "tag",
            args: [
                "ENV": "value 1",
                "ENV2": nil
            ],
            options: [
                "-o 1",
                "-o 2"
            ],
            path: "some/path"
        )
        XCTAssertEqual(res, #"docker build -f /some/Dockerfile -t tag --build-arg ENV="value 1" --build-arg ENV2 -o 1 -o 2 some/path"#)
    }
    
    func testDockerRun() {
        let res = shell.docker.commandBuilder.run(
            image: "image",
            name: "name",
            volumes: [
                "$PWD": "/somewhere/there",
                "/a": "/b"
            ],
            workdir: "/tmp",
            clean: true,
            mode: .detached,
            tty: true,
            expose: [80, 8080],
            options: [
                "-o 1",
                "-o 2"
            ],
            env: [
                "HU" : "HO",
                "HE": "HI"
            ],
            envFile: "/file.env",
            command: (command: "bash", args: ["-c"])
        )
        XCTAssertEqual(res, "docker run --name name -v $PWD /somewhere/there -v /a /b -w /tmp -rm -d -t --expose 80 --expose 8080 -o 1 -o 2 -e HU=HO -e HE=HI bash -c")
    }
    
    func testVersion() {
        var res = shell.docker.commandBuilder.version()
        XCTAssertEqual(res, "docker version")
        
        res = shell.docker.commandBuilder.version(display: .short)
        XCTAssertEqual(res, "docker --version")
        
        res = shell.docker.commandBuilder.version(display: .full)
        XCTAssertEqual(res, "docker version")
    }
    
    static let allTests = [
        ("testBuild", testBuild),
        ("testDockerRun", testDockerRun),
        ("testVersion", testVersion),
    ]
    
}

