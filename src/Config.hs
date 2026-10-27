module Config where

import Control.Exception (SomeException)
import Crypto.Noise
import Crypto.Noise.Cipher.AESGCM
import Crypto.Noise.DH (KeyPair, PublicKey)
import Crypto.Noise.DH.Curve25519
import Crypto.Noise.Hash.SHA256
import Data.ByteString (ByteString)

data PeerConfig = PeerConfig
  { localStaticKey :: KeyPair Curve25519,
    peerPublicKey :: PublicKey Curve25519,
    prologue :: ByteString
  }
