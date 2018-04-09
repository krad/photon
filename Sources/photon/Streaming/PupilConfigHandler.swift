import NIO

let NOP = { _=0 }

enum PupilConfigEvent {
    case gotGreeting
    case sent(msg: String)
    case gotBegin
}

class PupilConfigHandler: ChannelInboundHandler {
    typealias InboundIn = String
    
    var broadcastID: String
    
    init(broadcastID: String) {
        self.broadcastID = broadcastID
    }
    
    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let msg = self.unwrapInboundIn(data)
        print(#function, msg)
        switch msg {
        case "HI":
            _ = ctx.triggerUserOutboundEvent(PupilConfigEvent.gotGreeting)
            
            let payload = "\(self.broadcastID)\n"
            var buffer = ctx.channel.allocator.buffer(capacity: payload.utf8.count)
            buffer.write(string: payload)
            _ = ctx.channel.writeAndFlush(buffer).then {
                ctx.triggerUserOutboundEvent(PupilConfigEvent.sent(msg: self.broadcastID))
            }
            
        case "BEGIN":
            _ = ctx.triggerUserOutboundEvent(PupilConfigEvent.gotBegin)
            
        default:
            NOP()
        }
    }
    
}
