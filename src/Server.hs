module Server where

import           Config.Peer
import qualified Data.ByteString as BS
import           Handshake
import qualified Logging
import           Transport.Class

runServer ::
  (Transport t) =>
  PeerConfig -> -- client config
  t ->
  IO ()
runServer server transport = do
  logMessage "Waiting for handshake"
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

  logMessage "Handshake complete"
  receiveLoop serverSession
  where
    logMessage :: String -> IO ()
    logMessage = Logging.logMessage Logging.StdoutTransport . ("[server] " <>)

    receiveLoop session = do
      reply <-
        recvPacket transport
          >>= maybe
            ( do
                logMessage "Peer disconnected"
                fail "Peer closed connection while waiting for message"
            )
            pure

      (pt, session') <-
        either (fail . show) pure $
          decryptMessage session reply

      logMessage $ "Received " <> show (BS.length pt) <> " bytes"

      (ct, newSession) <-
        either (fail . show) pure $
          encryptMessage session' pt

      sendPacket transport ct
      logMessage "Reply sent"

      receiveLoop newSession
