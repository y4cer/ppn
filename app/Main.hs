module Main (main) where

import           Client
import           Config.File
import           Network.Socket
import           Options
import           Options.Applicative
import           Server
import           Transport.Stdio
import           Transport.Tcp

main :: IO ()
main = cmd =<< execParser opts
  where
    opts =
      info
        (commandParser <**> helper)
        ( progDesc "Generate keypair or run a ppn in client or server mode"
            <> header "ppn - a secure client-server communication based on Noise KX protocol"
        )

address :: SockAddr
address = SockAddrInet 13337 (tupleToHostAddress (127, 0, 0, 1))

cmd :: Command -> IO ()
cmd (ConfigGen filePath) = do
  genKeysToFile (filePath <> ".key")
  genSampleConfig filePath
cmd (Keygen filePath) = genKeysToFile filePath
cmd (Run mode filepath) = do
  config <- loadConfig filepath
  transport <- stdioTransport

  case mode of
    Initiator -> withTcpClient address $ runClient config
    Responder -> withTcpServer address $ runServer config
