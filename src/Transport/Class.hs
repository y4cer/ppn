module Transport.Class where

import           Data.ByteString
import           System.IO

class Transport t where
  sendPacket :: t -> ByteString -> IO ()
  recvPacket :: t -> IO (Maybe ByteString)

