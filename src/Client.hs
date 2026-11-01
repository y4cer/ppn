module Client where

import           Config.Peer
import           Crypto.Noise
import           Crypto.Noise.DH
import           Crypto.Noise.DH.Curve25519
import           Handshake
import           Transport.Class

runClient ::
  Transport t =>
  PeerConfig -> -- client config
  t
  -> IO ()
runClient client transport = do
  clientEphemeral <- genEphemeralKey

  (msg, clientHandshake) <-
    either (fail . show) pure $
      startClientHandshake client clientEphemeral

  sendPacket transport msg

  reply <-
    recvPacket transport
      >>= maybe (fail "Peer closed connection during handshake") pure

  session <-
    either (fail . show) pure $
      finishClientHandshake clientHandshake reply

  (confirmation, nextSession) <-
    either (fail . show) pure $
      encryptMessage session "ready"

  sendPacket transport confirmation

  receiveLoop nextSession
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
