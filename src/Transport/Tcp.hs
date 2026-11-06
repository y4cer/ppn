module Transport.Tcp where

import           Client
import           Config.Peer
import           Control.Exception
import           Network.Socket
import           Server
import           System.IO
import           Transport.Stdio

address :: SockAddr
address = SockAddrInet 13337 (tupleToHostAddress (127, 0, 0, 1))

newSocket :: IO Socket
newSocket = socket AF_INET Stream defaultProtocol

serv :: PeerConfig -> IO ()
serv config =
  bracket acquireHandle hClose $ \handle -> do
    hSetBinaryMode handle True
    runServer config (Stdio handle handle)
  where
    acquireHandle :: IO Handle
    acquireHandle =
      bracketOnError newSocket close $
        \listener -> do
          bind listener address
          listen listener 1

          bracketOnError
            (fst <$> accept listener)
            close
            (\conn -> socketToHandle conn ReadWriteMode)

clien :: PeerConfig -> IO ()
clien config =
  bracket acquireHandle hClose $ \handle -> do
    hSetBinaryMode handle True
    runClient config (Stdio handle handle)
  where
    acquireHandle :: IO Handle
    acquireHandle =
      bracketOnError newSocket close $ \sock -> do
        connect sock address
        socketToHandle sock ReadWriteMode
