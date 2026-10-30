module Server where

import           Config.Peer

-- serverConfig :: PublicKey Curve25519 -> ByteString -> IO PeerConfig
-- serverConfig clientPublicKey protocolPrologue = do
--   staticKey <- genStaticKey
--   pure
--     PeerConfig
--       { localStaticKey = staticKey,
--         peerPublicKey = clientPublicKey,
--         prologue = protocolPrologue
--       }


runServer ::
  PeerConfig ->
  PeerConfig ->
  IO ()
runServer = undefined
