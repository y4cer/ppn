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
someFunc = putStrLn "someFunc"
