{-# LANGUAGE InstanceSigs #-}
module Transport where

import           Data.ByteString
import           System.IO

class Transport t where
  sendPacket :: t -> ByteString -> IO ()
  recvPacket :: t -> IO (Maybe ByteString)

data IOTransport = HandleTransport
  { inputHandle  :: Handle
  , outputHandle :: Handle
  }

instance Transport IOTransport where
  sendPacket :: IOTransport -> ByteString -> IO ()
  sendPacket = undefined

  recvPacket :: IOTransport -> IO (Maybe ByteString)
  recvPacket = undefined

data MessageFrame = MessageFrame Integer ByteString

