{-# LANGUAGE InstanceSigs #-}
module Transport.Stdio where

import           Control.Monad
import           Data.ByteString as BS
import           System.IO
import           Transport.Class

instance Transport StdioTransport where
  sendPacket :: StdioTransport -> ByteString -> IO ()
  sendPacket (Stdio _ output) msg = do

    when (size > 0xffff) $
      fail "Message is too large"

    BS.hPut output (header <> msg)
    hFlush output

    where
      size = BS.length msg
      header = BS.pack $ Prelude.map fromIntegral [hi, lo]
      (hi, lo) = divMod size 256

  recvPacket :: StdioTransport -> IO (Maybe ByteString)
  recvPacket (Stdio input _) = do
    header <- BS.hGet input 2 -- size header is 2 bytes

    case BS.unpack header of
      [] -> pure Nothing
      [hi, lo] -> do
        let size = fromIntegral hi * 0x100 + fromIntegral lo
        msg <- BS.hGet input size

        when (BS.length msg /= size) $
          fail $ "Unexpected message length. Expected: " <> (show size)
               <> " got: " <> (show $ BS.length msg)
        pure (Just msg)
      _ -> fail "Connection closed"


data StdioTransport = Stdio Handle Handle

stdioTransport :: IO StdioTransport
stdioTransport = do
  hSetBinaryMode stdin True
  hSetBinaryMode stdout True
  pure (Stdio stdin stdout)
