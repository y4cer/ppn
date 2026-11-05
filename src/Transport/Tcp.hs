module Transport.Tcp where

import           Client
import           Config.Peer
import           Network.Socket
import           Server
import           System.IO
import           Transport.Stdio

address :: SockAddr
address = SockAddrInet 13337 (tupleToHostAddress (127, 0, 0, 1))

newSocket :: IO Socket
newSocket = socket AF_INET Stream defaultProtocol

serv :: PeerConfig -> IO ()
serv config = do
  listener <- newSocket
  bind listener address
  listen listener 1

  (conn, _) <- accept listener

  close listener

  handle <- socketToHandle conn ReadWriteMode
  hSetBinaryMode handle True

  runServer config (Stdio handle handle)

  hClose handle

clien :: PeerConfig -> IO ()
clien config = do
  sock <- newSocket
  connect sock address

  handle <- socketToHandle sock ReadWriteMode
  hSetBinaryMode handle True

  runClient config (Stdio handle handle)

  hClose handle
