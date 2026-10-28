module Config where

import Crypto.Noise.Cipher (Plaintext)
import Crypto.Noise.DH (KeyPair, PublicKey, dhGenKey)
import Crypto.Noise.DH.Curve25519

data PeerConfig = PeerConfig
  { localStaticKey :: KeyPair Curve25519,
    peerPublicKey :: PublicKey Curve25519,
    prologue :: Plaintext
  }

genStaticKey :: IO (KeyPair Curve25519)
genStaticKey = dhGenKey

genEphemeralKey :: IO (KeyPair Curve25519)
genEphemeralKey = dhGenKey
