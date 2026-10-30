module Main (main) where

import Lib
import Options
import Options.Applicative

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
cmd (Keygen filePath) = undefined
cmd (Run mode filepath) = undefined
