module Config.File where

import           Config.Peer
import           Data.Text
import           Options
import qualified Toml
import           Toml.Schema

data FileConfig = FileConfig
  { configPrivateKeyFile :: FilePath,
    configPeerPublicKey  :: Text,
    configPrologue       :: Text
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

genKeysToFile :: FilePath -> IO ()
genKeysToFile = undefined

loadConfig :: FilePath -> PeerConfig
loadConfig = undefined
