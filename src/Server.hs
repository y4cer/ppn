module Server where

import           Config.Peer
import           Handshake
import           Transport.Class

runServer ::
  (Transport t) =>
  PeerConfig -> -- client config
  t ->
  IO ()
runServer server transport = do
  serverEphemeral <- genEphemeralKey

  clientInit <-
    recvPacket transport
      >>= maybe (fail "Peer closed connection during handshake") pure

  (reply, pendingServerSession) <-
    either (fail . show) pure $
      respondServerHandshake server serverEphemeral clientInit

  sendPacket transport reply

  confirmation <-
    recvPacket transport
      >>= maybe (fail "Peer closed connection during handshake") pure

  serverSession <-
    either (fail . show) pure $
      finishServerHandshake pendingServerSession confirmation

  receiveLoop serverSession
  where
    receiveLoop session = do
      reply <-
        recvPacket transport
          >>= maybe (fail "Peer closed connection during handshake") pure

      (pt, session') <-
        either (fail . show) pure $
          decryptMessage session reply

      (ct, newSession) <-
        either (fail . show) pure $
          encryptMessage session' pt

      sendPacket transport ct

      receiveLoop newSession
