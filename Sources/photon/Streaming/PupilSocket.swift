import Foundation
import Socket

public typealias BroadcastBeginCallback = (Broadcast?, PupilSocket?, Error?) -> Void

public protocol PupilSocketProtocol {
    static func createStream(for broadcast: Broadcast, onReady: @escaping BroadcastBeginCallback)
    var bytesWrote: Int { get }
    func write(_ data: Data)
}

public enum PupilSocketError: Error {
    case protocolsNotSupport
    case noServers
    case couldNotConnectToServers
}

public class PupilSocket: PupilSocketProtocol {
    
    fileprivate var socket: Socket
    fileprivate var socketQ: DispatchQueue
    
    public private(set) var running = false
    
    public var hostName: String
    public var port: Int32
    public var bytesWrote: Int = 0
    
    private var writeBuffer: ThreadSafeArray<UInt8>
    
    public func write(_ data: Data) {
        self.writeBuffer.append(contentsOf: [UInt8](data))
        self.sendBytesToServer(length: data.count)
    }
    
    private func sendBytesToServer(length: Int) {
        self.socketQ.async {
            do {
                let bytes = self.writeBuffer.first(upTo: length)
                let data  = Data(bytes)
                let wrote = try self.socket.write(from: data)
                self.bytesWrote += wrote
                self.writeBuffer.removeFirst(n: wrote)
            } catch let error { print("Couldn't write bytes to server:", error.localizedDescription) }
        }
    }
    
    public static func createStream(for broadcast: Broadcast,
                                    onReady: @escaping BroadcastBeginCallback)
    {
        guard let servers = broadcast.pupil else {
            onReady(broadcast, nil, PupilSocketError.noServers)
            return
        }
        
        for server in servers {
            do {
                let socket = try PupilSocket.setup(broadcast.broadcastID, on: server)
                onReady(broadcast, socket, nil)
                return
            } catch let error {
                print("Problem setting up pupil socket session:", error)
            }
        }
        
        onReady(broadcast, nil, PupilSocketError.couldNotConnectToServers)
        
    }

    internal static func setup(_ identifier: String,
                               on server: PupilServer) throws -> PupilSocket
    {
        let sync = DispatchGroup()
        sync.enter()
        let socket = try PupilSocket(identifier: identifier, server: server, onReady: { ps in
            sync.leave()
        })
        sync.wait()
        return socket
    }
    
    internal init(identifier: String, server: PupilServer,  onReady: @escaping (PupilSocket) -> ()) throws {
        if let port = server.ports.filter({ $0.proto == "tcp" }).first {
            let sock = try Socket.create()
            try sock.connect(to: server.host, port: port.port)
            self.running        = true
            self.socket         = sock
            self.port           = port.port
            self.hostName       = server.host
            self.socketQ        = DispatchQueue(label: "\(sock.socketfd).socket.q")
            self.writeBuffer    = ThreadSafeArray<UInt8>()
            self.setup(with: identifier, onReady: onReady)
        } else {
            throw PupilSocketError.protocolsNotSupport
        }
    }
    
    internal func setup(with identifier: String, onReady: @escaping (PupilSocket) -> ()) {
        self.socketQ.async {[unowned self] in
            var readBuf = Data(capacity: 1024)
            repeat {
                do {
                    let read = try self.socket.read(into: &readBuf)
                    if read > 0 {
                        if let msg = String(data: readBuf[0..<read], encoding: .utf8) {
                            switch msg {
                            case "HI\n":
                                try self.socket.write(from: "\(identifier)\n")
                                readBuf.count = 0
                            case "BEGIN\n":
                                onReady(self)
                                self.running = false
                            default:
                                _=0+0
                            }
                        }
                    } else {
                        if self.socket.remoteConnectionClosed {
                            self.socketClosed()
                            self.running = false
                        }
                    }
                } catch {
                    self.running = false
                    if self.socket.remoteConnectionClosed { self.socketClosed() }
                }
            } while self.running
        }
    }
    
    internal func set(broadcastID: String, onReady: @escaping () -> ()) {
        do {
            try self.socket.write(from: "\(broadcastID)\n")
            onReady()
        } catch { self.running = false }
    }
    
    private func socketClosed() {
        print("socket closed")
    }
    
}
