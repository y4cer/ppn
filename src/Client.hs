module Client where

import Config
import Crypto.Noise.DH (PublicKey)
import Crypto.Noise.DH.Curve25519 (Curve25519)
import Data.ByteString (ByteString)
import Errors
import Handshake

clientConfig :: PublicKey Curve25519 -> ByteString -> IO PeerConfig
clientConfig serverPublicKey protocolPrologue = do
  staticKey <- genStaticKey
  pure
    PeerConfig
      { localStaticKey = staticKey,
        peerPublicKey = serverPublicKey,
        prologue = protocolPrologue
      }

demoClient ::
  PeerConfig ->
  PeerConfig ->
  IO ()
demoClient client server = do
  clientEphemeral <- genEphemeralKey
  serverEphemeral <- genEphemeralKey

  let res = do
        (msg, clientHandshake) <- startClientHandshake client clientEphemeral

        (reply, pendingServerSession) <- respondServerHandshake server serverEphemeral msg

        clientSession <- finishClientHandshake clientHandshake reply

        serverSession <- acceptFirstClientMessage pendingServerSession reply

        pure (clientSession)

  case res of
    Left _err -> print 1
    Right _clientHandshake -> print 2

  print 1
