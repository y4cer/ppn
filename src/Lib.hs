module Lib
  ( someFunc,
  )
where

import Crypto.Noise
-- Used to generate and manipulate keys

import Crypto.Noise.Cipher.AESGCM
import Crypto.Noise.DH
import Crypto.Noise.DH.Curve25519
import Crypto.Noise.HandshakePatterns (noiseKX)
import Crypto.Noise.Hash.SHA256
import Data.ByteArray (convert)
import Data.ByteString (ByteString)
import qualified Data.Text.Encoding as Text
import qualified Data.Text.IO as Text

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
          . setRemoteStatic (Just $ snd bobStatic)
          $ dho
        where
          dho = defaultHandshakeOpts InitiatorRole "prologue" :: HandshakeOpts Curve25519

  let bobHO =
        setLocalStatic (Just bobStatic)
          . setLocalEphemeral (Just bobEphemeral)
          $ dho
        where
          dho = defaultHandshakeOpts ResponderRole "prologue" :: HandshakeOpts Curve25519

  -- Initiator
  let ins = noiseState aliceHO noiseKX :: NoiseState AESGCM Curve25519 SHA256

  -- Responder
  let rns = noiseState bobHO noiseKX :: NoiseState AESGCM Curve25519 SHA256

  -- Initiator
  let writeResult = writeMessage "They must find it difficult -- those who have taken authority as the truth, rather than truth as the authority." ins

  let ct = case writeResult of
        NoiseResultMessage ciphertext _ -> ciphertext
        NoiseResultNeedPSK _ -> error "something terrible happened" -- will never happen in Noise_IK
        NoiseResultException _ -> error "something terrible happened"

  -- Responder
  let readResult = readMessage ct rns
  case readResult of
    NoiseResultMessage plaintext _ ->
      Text.putStrLn (Text.decodeUtf8 (convert plaintext :: ByteString))
    NoiseResultNeedPSK _ -> error "something terrible happened"
    NoiseResultException _ -> error "something terrible happened"

  print (1 :: Int)
