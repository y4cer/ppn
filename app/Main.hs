module Main (main) where

import           Client
import           Config.File
import           Options
import           Options.Applicative
import           Server

main :: IO ()
main = cmd =<< execParser opts
  where
    opts =
      info
        (commandParser <**> helper)
        ( progDesc "Generate keypair or run a ppn in client or server mode"
            <> header "ppn - a secure client-server communication based on Noise KX protocol"
        )

cmd :: Command -> IO ()
cmd (Keygen filePath)   = genKeysToFile filePath
cmd (Run mode filepath) =
  case mode of
    Initiator -> runClient clientConfig serverConfig
    Responder -> runServer clientConfig clientConfig
  where
    clientConfig = loadConfig filepath
    serverConfig = loadConfig filepath
