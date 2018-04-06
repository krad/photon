import NIO

private let newLine = "\n".utf8.first!

final class LineDelimiterCodec: ByteToMessageDecoder {
    public typealias InboundIn = ByteBuffer
    public typealias InboundOut = String
    
    public var cumulationBuffer: ByteBuffer?
    
    public func decode(ctx: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        let readable = buffer.withUnsafeReadableBytes { $0.index(of: newLine) }
        if let r = readable {
            if let payload = buffer.readString(length: r) {
                ctx.fireChannelRead(self.wrapInboundOut(payload))
                _ = buffer.readBytes(length: 1)
                return .continue
            }
        }
        return .needMoreData
    }
    
}

