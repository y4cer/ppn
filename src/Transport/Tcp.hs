module Transport.Tcp where

import           Client
import           Config.Peer
import           Control.Exception
import qualified Logging
import           Network.Socket
import           Server
import           System.IO
import           Transport.Stdio

newSocket :: IO Socket
newSocket = socket AF_INET Stream defaultProtocol

logMessage :: String -> IO ()
logMessage = Logging.logMessage Logging.StdoutTransport

withTransport :: IO Handle -> (StdioTransport -> IO a) -> IO a
withTransport acquireHandle action =
  bracket
    acquireHandle
    ( \handle' ->
        do
          hClose handle'
          logMessage "[transport] error with handle"
    )
    ( \handle' -> do
        hSetBinaryMode handle' True
        action (Stdio handle' handle')
    )

withTcpServer :: SockAddr -> (StdioTransport -> IO ()) -> IO ()
withTcpServer address action =
  withTransport acquireHandle action
  where
    acquireHandle :: IO Handle
    acquireHandle =
      bracketOnError newSocket close $
        \listener -> do
          bind listener address
          listen listener 1

          bracketOnError
            (fst <$> accept listener)
            ( \sock -> do
                close sock
                logMessage "[server] error in connection socket"
            )
            (\sock -> socketToHandle sock ReadWriteMode)

withTcpClient :: SockAddr -> (StdioTransport -> IO ()) -> IO ()
withTcpClient address action =
  withTransport acquireHandle action
  where
    acquireHandle :: IO Handle
    acquireHandle =
      bracketOnError
        newSocket
        ( \sock -> do
            close sock
            logMessage "[client] error in connection socket"
        )
        ( \sock -> do
            connect sock address
            socketToHandle sock ReadWriteMode
        )
