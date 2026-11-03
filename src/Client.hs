module Client where

import           Config.Peer
import           Handshake
import           Transport.Class

orFail :: (Show e) => Either e a -> IO a
orFail = either (fail . show) pure

runClient ::
  (Transport t) =>
  PeerConfig -> -- client config
  t ->
  IO ()
runClient client transport = do
  clientEphemeral <- genEphemeralKey

  (msg, clientHandshake) <-
    orFail $
      startClientHandshake client clientEphemeral

  sendPacket transport msg

  reply <-
    recvPacket transport
      >>= maybe (fail "Peer closed connection during handshake") pure

  session <-
    orFail $
      finishClientHandshake clientHandshake reply

  (confirmation, nextSession) <-
    orFail $
      encryptMessage session "ready"

  sendPacket transport confirmation

  receiveLoop nextSession
  where
    receiveLoop session = do
      reply <-
        recvPacket transport
          >>= maybe (fail "Peer closed connection during handshake") pure

      (pt, session') <-
        orFail $
          decryptMessage session reply

      (ct, newSession) <-
        orFail $
          encryptMessage session' pt

      sendPacket transport ct

      receiveLoop newSession

demoClientServer ::
  PeerConfig -> -- client config
  PeerConfig -> -- server config
  IO ()
demoClientServer client server = do
  clientEphemeral <- genEphemeralKey
  serverEphemeral <- genEphemeralKey

  let res = do
        (msg, clientHandshake) <- startClientHandshake client clientEphemeral

        (reply, pendingServerSession) <- respondServerHandshake server serverEphemeral msg

        clientSession <- finishClientHandshake clientHandshake reply

        (confirmation, newClientSession) <-
          encryptMessage clientSession "ready"

        serverSession <-
          finishServerHandshake pendingServerSession confirmation

        pure (newClientSession, serverSession)

  case res of
    Left _err              -> print _err
    Right _clientHandshake -> print 2

  print 1
