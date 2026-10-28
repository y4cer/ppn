module Lib
  ( someFunc,
  )
where

-- Used to generate and manipulate keys

import Crypto.Noise
import Crypto.Noise.DH
import Crypto.Noise.DH.Curve25519
import Errors

handleNoiseResult ::
  NoiseResult c d h ->
  Either PpnError (ScrubbedBytes, NoiseState c d h)
handleNoiseResult result =
  case result of
    NoiseResultMessage bytes nextState -> pure (bytes, nextState)
    NoiseResultNeedPSK _ -> Left UnexpectedPSK
    NoiseResultException exception -> Left (NoiseFailure exception)

someFunc :: IO ()
someFunc = do
  -- Static keys: долгосрочные ключи узлов
  aliceStatic <- dhGenKey :: IO (KeyPair Curve25519)
  bobStatic <- dhGenKey :: IO (KeyPair Curve25519)

  -- Ephemeral keys: новые для каждого handshake
  aliceEphemeral <- dhGenKey :: IO (KeyPair Curve25519)
  bobEphemeral <- dhGenKey :: IO (KeyPair Curve25519)

  let aliceHO =
        setLocalStatic (Just aliceStatic)
          . setLocalEphemeral (Just aliceEphemeral)
          $ dho
        where
          dho = defaultHandshakeOpts InitiatorRole "prologue" :: HandshakeOpts Curve25519

  let bobHO =
        setLocalStatic (Just bobStatic)
          . setRemoteStatic (Just $ snd aliceStatic)
          . setLocalEphemeral (Just bobEphemeral)
          $ dho
        where
          dho = defaultHandshakeOpts ResponderRole "prologue" :: HandshakeOpts Curve25519

  print 1

-- -- Initiator
-- let ins = noiseState aliceHO noiseKX :: NoiseState AESGCM Curve25519 SHA256
--
-- -- Responder
-- let rns = noiseState bobHO noiseKX :: NoiseState AESGCM Curve25519 SHA256
--
-- -- 1. Alice -> Bob
-- (msg1, ins1) <- handleNoiseResult $ writeMessage "first" ins
-- print (convert msg1 :: ByteString)
-- (msg, rns1) <- handleNoiseResult $ readMessage msg1 rns
--
-- print $ handshakeComplete rns1
-- -- 2. Bob -> Alice
-- (msg2, rns2) <- handleNoiseResult $ writeMessage "second" rns1
-- print (convert msg2 :: ByteString)
-- (msg, ins2) <- handleNoiseResult $ readMessage msg2 ins1
--
-- print $ handshakeComplete rns2
-- -- Alice encrypts
-- (ciphertext, ins3) <- handleNoiseResult $ writeMessage "Hello Bob!" ins2
-- print (convert ciphertext :: ByteString)
-- (plaintext, rns3) <- handleNoiseResult $ readMessage ciphertext rns2
-- print (convert plaintext :: ByteString)
--
-- print $ handshakeComplete rns3
