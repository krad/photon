import Foundation
@testable import photon
import NIO
import NIOOpenSSL

enum SessionConfigState {
    case greeted
    case got(id: String)
}

public final class SessionConfigHandler: ChannelInboundHandler {
    public typealias InboundIn = String
    
    private var ctx: ChannelHandlerContext?
    
    public func channelRegistered(ctx: ChannelHandlerContext) {
        self.ctx   = ctx
        
        var buffer = ctx.channel.allocator.buffer(capacity: "HI\n".utf8.count)
        buffer.write(bytes: "HI\n".data(using: .utf8)!)
        _ = ctx.channel.writeAndFlush(buffer).mapIfError(handleError)
    }
    
    public func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        print(#function)
        let broadcastID = self.unwrapInboundIn(data)
        print(broadcastID)
        let event = SessionConfigState.got(id: broadcastID)
        _ = ctx.channel.triggerUserOutboundEvent(event).map { _ in
            var buffer = ctx.channel.allocator.buffer(capacity: "BEGIN\n".utf8.count)
            buffer.write(bytes: "BEGIN\n".data(using: .utf8)!)
            _ = ctx.channel.writeAndFlush(buffer).mapIfError(self.handleError)
        }
    }
    
    func handleError(_ error: Error) {
        print("ERROR:", error)
        end()
    }
    
    func end() {
        _ = self.ctx?.channel.close()
    }
    
    
}

