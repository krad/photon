import NIO

class SessionHandler: ChannelInboundHandler, ChannelOutboundHandler {
    typealias InboundIn = ByteBuffer
    typealias OutboundIn = ByteBuffer
    
    private var broadcastID: String
    
    init(broadcastID: String) {
        self.broadcastID = broadcastID
    }
    
}
