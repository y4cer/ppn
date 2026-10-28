module Handshake where

import Config
import Crypto.Noise
import Crypto.Noise.Cipher.AESGCM
import Crypto.Noise.DH (KeyPair, PublicKey)
import Crypto.Noise.DH.Curve25519
import Crypto.Noise.HandshakePatterns (noiseKX)
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

handleNoiseResult ::
  NoiseResult c d h ->
  Either PpnError (ScrubbedBytes, NoiseState c d h)
handleNoiseResult result =
  case result of
    NoiseResultMessage bytes nextState -> pure (bytes, nextState)
    NoiseResultNeedPSK _ -> Left UnexpectedPSK
    NoiseResultException exception -> Left (NoiseFailure exception)

startClientHandshake ::
  PeerConfig ->
  KeyPair Curve25519 ->
  Either PpnError (ByteString, ClientHandshake)
startClientHandshake clientConfig clientEphemeral =
  do
    let dho = defaultHandshakeOpts InitiatorRole (prologue clientConfig) :: HandshakeOpts Curve25519

    let clientHO =
          setLocalStatic (Just $ localStaticKey clientConfig)
            . setLocalEphemeral (Just clientEphemeral)
            $ dho

    let ins = noiseState clientHO noiseKX :: NoiseState AESGCM Curve25519 SHA256

    (msg1, ins1) <- handleNoiseResult $ writeMessage "" ins

    let msg = convert msg1 :: ByteString
        clientHandshake =
          ClientHandshake
            { clientNoiseState = ins1,
              expectedServerKey = peerPublicKey clientConfig
            }

    pure (msg, clientHandshake)

respondServerHandshake ::
  PeerConfig ->
  KeyPair Curve25519 ->
  ByteString ->
  Either PpnError (ByteString, PendingServerSession)
respondServerHandshake serverConfig serverEphemeral ct =
  do
    let dho = defaultHandshakeOpts ResponderRole (prologue serverConfig) :: HandshakeOpts Curve25519

    let serverHO =
          setLocalStatic (Just $ localStaticKey serverConfig)
            . setRemoteStatic (Just $ peerPublicKey serverConfig)
            . setLocalEphemeral (Just serverEphemeral)
            $ dho
    let rns = noiseState serverHO noiseKX :: NoiseState AESGCM Curve25519 SHA256

finishClientHandshake ::
  ClientHandshake ->
  ByteString ->
  Either PpnError Session
finishClientHandshake = undefined

acceptFirstClientMessage ::
  PendingServerSession ->
  ByteString ->
  Either PpnError Session
acceptFirstClientMessage = undefined

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
