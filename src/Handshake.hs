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
    (_, rns1) <- handleNoiseResult $ readMessage (convert ct) rns

    (reply, newRns) <- handleNoiseResult $ writeMessage "" rns1

    pure (convert reply, PendingServerSession newRns)

finishClientHandshake ::
  ClientHandshake ->
  ByteString ->
  Either PpnError Session
finishClientHandshake handshake msg = do
  (_, ins) <-
    handleNoiseResult $
      readMessage (convert msg) (clientNoiseState handshake)

  validateSession ins
  where
    validateSession ins
      | not (handshakeComplete ins) =
          Left HandshakeNotComplete
      | Nothing <- remoteStaticKey ins =
          Left ServerKeyMissing
      | Just actualKey <- remoteStaticKey ins,
        actualKey /= expectedServerKey handshake =
          Left ServerKeyMismatch
      | otherwise =
          Right (Session ins)

finishServerHandshake ::
  PendingServerSession ->
  ByteString ->
  Either PpnError Session
finishServerHandshake (PendingServerSession handshake) msg = do
  (_, rns) <- handleNoiseResult $ readMessage (convert msg) handshake

  pure (Session rns)

encryptMessage ::
  Session ->
  ByteString ->
  Either PpnError (ByteString, Session)
encryptMessage (Session s) pt = do
  (ct, newState) <- handleNoiseResult $ writeMessage (convert pt) s

  pure (convert ct, Session newState)

decryptMessage ::
  Session ->
  ByteString ->
  Either PpnError (ByteString, Session)
decryptMessage (Session s) ct = do
  (pt, newState) <- handleNoiseResult $ readMessage (convert ct) s

  pure (convert pt, Session newState)
