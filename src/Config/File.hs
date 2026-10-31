module Config.File where

import           Config.Peer
import           Crypto.Noise.DH
import           Data.ByteArray.Encoding
import qualified Data.ByteString       as BS
import qualified Data.ByteString.Char8 as BS8
import qualified Data.Text             as Text
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
    Toml.Failure errors ->
      Left errors

    Toml.Success [] config ->
      Right config

    Toml.Success warnings _ ->
      Left warnings

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


loadConfig :: FilePath -> PeerConfig
loadConfig = undefined
