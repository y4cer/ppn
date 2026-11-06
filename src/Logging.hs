module Logging
  ( logMessage,
    StdoutTransport (..),
  )
where

import qualified Data.ByteString    as BS
import qualified Data.Text          as Text
import qualified Data.Text.Encoding as TextEncoding
import           System.IO
import           Transport.Class

data StdoutTransport = StdoutTransport

instance Transport StdoutTransport where
  sendPacket StdoutTransport message = do
    BS.hPut stdout message
    hFlush stdout

  recvPacket StdoutTransport = undefined

logMessage :: (Transport t) => t -> String -> IO ()
logMessage transport message =
  sendPacket transport (TextEncoding.encodeUtf8 (Text.pack (message <> "\n")))
