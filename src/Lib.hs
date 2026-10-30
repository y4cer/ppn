module Lib
  ( someFunc,
  )
where

import           Client
-- Used to generate and manipulate keys

import           Config.Peer
import           Crypto.Noise
import           Crypto.Noise.DH
import           Crypto.Noise.DH.Curve25519
import           Errors

someFunc :: IO ()
someFunc = do
  aliceStatic <- dhGenKey :: IO (KeyPair Curve25519)
  bobStatic <- dhGenKey :: IO (KeyPair Curve25519)

  aliceEphemeral <- dhGenKey :: IO (KeyPair Curve25519)
  bobEphemeral <- dhGenKey :: IO (KeyPair Curve25519)

  let clientConfig =
        PeerConfig
          { localStaticKey = aliceStatic,
            peerPublicKey = snd bobStatic,
            prologue = "S"
          }
      serverConfig =
        PeerConfig
          { localStaticKey = bobStatic,
            peerPublicKey = snd aliceStatic,
            prologue = "S"
          }

  runClient clientConfig serverConfig
