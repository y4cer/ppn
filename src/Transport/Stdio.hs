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

    where
      size = BS.length msg
      header = BS.pack
        [ fromIntegral (size `div` 0xff)
        , fromIntegral (size `mod` 0xff)
        ]

  recvPacket :: StdioTransport -> IO (Maybe ByteString)
  recvPacket (Stdio input _) = do
    header <- BS.hGet input 2

    case BS.unpack header of
      [] -> pure Nothing
      [hi, lo] -> do
        msg <- BS.hGet input size

        when (BS.length msg /= size) $
          fail $ "Unexpected message length. Expected: " <> (show size)
               <> " got: " <> (show $ BS.length msg)
        pure (Just msg)

        where
          size = fromIntegral hi * 0xff + fromIntegral lo
      _ -> fail "Connection closed"


data StdioTransport = Stdio Handle Handle

stdioTransport :: IO StdioTransport
stdioTransport = do
  hSetBinaryMode stdin True
  hSetBinaryMode stdout True
  pure (Stdio stdin stdout)
