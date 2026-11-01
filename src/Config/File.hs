module Config.File where

import           Config.Peer
import           Crypto.Noise.DH
import           Data.Bifunctor
import           Data.ByteArray
import           Data.ByteArray.Encoding
import qualified Data.ByteString         as BS
import qualified Data.ByteString.Char8   as BS8
import qualified Data.Text               as Text
import qualified Data.Text.Encoding      as TextEncoding
import           System.FilePath
import qualified Toml
import           Toml.Schema

data FileConfig = FileConfig
  { configPrivateKeyFile :: FilePath,
    configPeerPublicKey  :: Text.Text,
    configPrologue       :: Text.Text
  }
  deriving (Eq, Show)

instance FromValue FileConfig where
  fromValue =
    parseTableFromValue $
      FileConfig
        <$> reqKey "private-key-file"
        <*> reqKey "peer-public-key"
        <*> reqKey "prologue"

instance ToValue FileConfig where
  toValue = defaultTableToValue

instance ToTable FileConfig where
  toTable config =
    table
      [
        "private-key-file" .= configPrivateKeyFile config,
        "peer-public-key" .= configPeerPublicKey config,
        "prologue" .= configPrologue config
      ]

decodeConfig :: Text.Text -> Either [String] FileConfig
decodeConfig input =
  case Toml.decode input of
    Toml.Failure errors     -> Left errors
    Toml.Success [] config  -> Right config
    Toml.Success warnings _ -> Left warnings

encodeConfig :: FileConfig -> Text.Text
encodeConfig =
  Text.pack . show . Toml.encode

genKeysToFile :: FilePath -> IO ()
genKeysToFile filePath = do
  (privateKey, publicKey) <- genStaticKey
  let privateText = convertToBase Base64 (dhSecToBytes privateKey) :: BS.ByteString

      publicText = convertToBase Base64 (dhPubToBytes publicKey) :: BS.ByteString

  BS.writeFile filePath (privateText <> "\n")
  BS8.putStrLn publicText

buildPeerConfig :: FileConfig -> BS.ByteString -> Either String PeerConfig
buildPeerConfig config keyBytes = do
  privateBytes <-
    first (const "private-key-file: invalid Base64") $
      convertFromBase Base64 $
        BS8.dropWhileEnd (\c -> c == '\r' || c == '\n') keyBytes

  publicBytes <-
    first (const "peer-public-key: invalid Base64") $
      convertFromBase Base64 $
        TextEncoding.encodeUtf8 (configPeerPublicKey config)

  localKey <-
    maybe (Left "Invalid Curve25519 private key") Right $
      dhBytesToPair privateBytes

  remoteKey <-
    maybe (Left "Invalid Curve25519 public key") Right $
      dhBytesToPub publicBytes

  pure
    PeerConfig
      { localStaticKey = localKey,
        peerPublicKey = remoteKey,
        prologue = convert (TextEncoding.encodeUtf8 (configPrologue config))
      }


loadConfig :: FilePath -> IO PeerConfig
loadConfig filePath = do
  bytesContent <- BS.readFile filePath
  textContent <- either (fail . show) pure (TextEncoding.decodeUtf8' bytesContent)
  config <- either (fail . show) pure (decodeConfig textContent)

  keyBytes <- BS.readFile $
    takeDirectory filePath </> configPrivateKeyFile config

  either fail pure (buildPeerConfig config keyBytes)

