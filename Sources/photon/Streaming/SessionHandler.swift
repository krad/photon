import NIO

class SessionHandler: ChannelInboundHandler, ChannelOutboundHandler {
    typealias InboundIn = ByteBuffer
    typealias OutboundIn = ByteBuffer
    
    private var broadcastID: String
    private var delegate: PupilClientDelegate
    
    init(broadcastID: String, delegate: PupilClientDelegate) {
        self.broadcastID = broadcastID
        self.delegate    = delegate
    }
    
    func channelRegistered(ctx: ChannelHandlerContext) {
        self.delegate.connected()
        ctx.fireChannelRegistered()
    }
    
    func triggerUserOutboundEvent(ctx: ChannelHandlerContext, event: Any, promise: EventLoopPromise<Void>?) {
        if let ev = event as? PupilConfigEvent {
            switch ev {
            case .gotGreeting:
                print("Got Greeting")
            case .sent(let msg):
                print("Sent \(msg)")
            case .gotBegin:
                print("Got Begin")
                self.delegate.ready()
            }
        }
        
        promise?.succeed(result: {}())
    }
    
}
