import Foundation
import CryptoKit


struct Config {
    
    enum Format: String {
        case base64
        case hex
    }
    
    let prefix: String?
    let format: Format
    var length: Int

}

func config() -> Config {
    var prefix: String?
    var format: String?
    var length: String?
    
    var previous: String?
    for arg in CommandLine.arguments {
        switch true {
        case previous == "--prefix" || previous == "-p":
            prefix = arg
        case previous == "--format" || previous == "-f":
            format = arg
        case previous == "--length" || previous == "-l":
            length = arg
        case arg == "--help" || arg == "-h":
            print("Arguments:")
            print("    -l Lenght of the generated random data (number of bytes, default is 32)")
            print("    -p String prefix for the encoded data in a string format")
            print("    -f [base64 or hex for hex string base64 encoding is default")
            print("Use:")
            print("Generate 64 random bytes: random-generator -l 64")
            print("Prefix data with a message: random-generator -p \"prefix:\"")
            print("Output as hex string: random-generator -f hex")
            exit(0)
        default:
            previous = arg
            continue
        }
        previous = arg
    }
    
    if (format != "hex" || format != "base64") && format != nil {
        fatalError("Format has to be either 'hex' or 'base64'")
    }
    
    let f = Config.Format(rawValue: format ?? "base64") ?? .base64
    
    let l: Int
    if let length = length, let len = Int(length), len > 0 {
        l = len
    } else {
        l = 32
    }
    
    print("Setup:")
    print("    Length   - \(l)")
    print("    Prefix   - \(prefix ?? "n/a")")
    print("    Format   - \(f.rawValue)")
    
    return Config(
        prefix: prefix,
        format: f,
        length: l
    )
}

print("random-generator by Einstore, the open source enterprise appstore solution and CI Speedter")
print("https://github.com/Einstore/Speedster")

let c = config()

let rand = try URandom().generateData(count: c.length)

let out: [UInt8]
if let prefix = c.prefix {
    var o: [UInt8] = Array(prefix.utf8)
    o.append(contentsOf: rand)
    out = o
} else {
    out = rand
}

if c.format == .hex {
    print("Result:")
    print("    \(out.hexEncodedString())")
} else {
    let base64 = Data(out).base64EncodedString()
    print("Result:")
    print("    \(base64)")

}
