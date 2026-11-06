module Client where

import           Config.Peer
import           Control.Monad         (unless)
import qualified Data.ByteString.Char8 as BS
import           Handshake
import qualified Logging
import           System.IO             (isEOF)
import           Transport.Class

orFail :: (Show e) => Either e a -> IO a
orFail = either (fail . show) pure

runClient ::
  (Transport t) =>
  PeerConfig -> -- client config
  t ->
  IO ()
runClient client transport = do
  logMessage "Sending handshake"
  clientEphemeral <- genEphemeralKey

  (msg, clientHandshake) <-
    orFail $
      startClientHandshake client clientEphemeral

  sendPacket transport msg

  reply <-
    recvPacket transport
      >>= maybe (fail "Peer closed connection during handshake") pure

  session <-
    orFail $
      finishClientHandshake clientHandshake reply

  (confirmation, nextSession) <-
    orFail $
      encryptMessage session "ready"

  logMessage "sending 'ready' packet"
  sendPacket transport confirmation

  logMessage "entering sending loop"
  sendLoop nextSession
  where
    logMessage :: String -> IO ()
    logMessage = Logging.logMessage Logging.StdoutTransport . ("[client] " <>)
    sendLoop session = do
      end <- isEOF
      unless end $ do
        message <- BS.getLine

        (ct, sentSession) <-
          orFail $
            encryptMessage session message

        sendPacket transport ct

        reply <-
          recvPacket transport
            >>= maybe (fail "Peer closed connection while waiting for reply") pure

        (plaintext, nextSession) <-
          orFail $
            decryptMessage sentSession reply

        BS.putStrLn plaintext

        sendLoop nextSession
