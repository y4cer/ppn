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

  let res = do
        a <- startClientHandshake client clientEphemeral
        pure a

  case res of
    Left err -> print 1
    Right (msg, clientHandshake) -> print 2

  print 1
