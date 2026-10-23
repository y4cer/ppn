module Lib
  ( someFunc,
  )
where

import Crypto.Noise
import Crypto.Noise.Cipher.AESGCM
import Crypto.Noise.DH -- Used to generate and manipulate keys
import Crypto.Noise.DH.Curve25519
import Crypto.Noise.HandshakePatterns (noiseIK)
import Crypto.Noise.Hash.SHA256

someFunc :: IO ()
someFunc = do
  (aPriv, aPub) <-
    dhGenKey :: IO (KeyPair Curve25519)

  (bPriv, bPub) <-
    dhGenKey :: IO (KeyPair Curve25519)

  let secretA = dhPerform aPriv bPub

  let secretB = dhPerform bPriv aPub

  print (secretA == secretB)
