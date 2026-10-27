module Handshake where

import Config
import Crypto.Noise
import Crypto.Noise.Cipher.AESGCM
import Crypto.Noise.DH (KeyPair, PublicKey)
import Crypto.Noise.DH.Curve25519
import Crypto.Noise.Hash.SHA256
import Data.ByteString (ByteString)
import Errors

type PpnNoiseState =
  NoiseState AESGCM Curve25519 SHA256

data ClientHandshake = ClientHandshake
  { clientNoiseState :: PpnNoiseState,
    expectedServerKey :: PublicKey Curve25519
  }

newtype PendingServerSession
  = PendingServerSession PpnNoiseState

newtype Session
  = Session PpnNoiseState

startClientHandshake ::
  PeerConfig ->
  IO (Either PpnError (ByteString, ClientHandshake))
startClientHandshake = undefined

respondServerHandshake ::
  PeerConfig ->
  ByteString ->
  IO (Either PpnError (ByteString, PendingServerSession))
respondServerHandshake = undefined

finishClientHandshake ::
  ClientHandshake ->
  ByteString ->
  Either PpnError Session
finishClientHandshake = undefined

confirmClient ::
  PendingServerSession ->
  ByteString ->
  Either PpnError (ByteString, Session)
confirmClient = undefined

encryptMessage ::
  Session ->
  ByteString ->
  Either PpnError (ByteString, Session)
encryptMessage = undefined

decryptMessage ::
  Session ->
  ByteString ->
  Either PpnError (ByteString, Session)
decryptMessage = undefined
