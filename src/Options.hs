module Options where

import           Options.Applicative

data Sample = Sample
  { hello      :: String,
    quiet      :: Bool,
    enthusiasm :: Int
  }

data Mode
  = Initiator
  | Responder
  deriving (Show)

data Command
  = Keygen FilePath
  | Run Mode FilePath
  deriving (Show)

commandParser :: Parser Command
commandParser =
  hsubparser
    ( command
        "keygen"
        ( info
            (keygenParser <**> helper)
            (progDesc "Generate a staic key")
        )
        <> command
          "run"
          ( info
              (runParser)
              (progDesc "Run a peer")
          )
    )

keygenParser :: Parser Command
keygenParser =
  Keygen
    <$> strOption
      ( short 'o'
          <> long "output"
          <> metavar "OUTPUT"
          <> help "output key file"
      )

runParser :: Parser Command
runParser =
  Run
    <$> option
      modeReader
      ( short 'm'
          <> long "mode"
          <> metavar "MODE"
          <> help "initiator or responder"
      )
    <*> strOption
      ( short 'i'
          <> long "input"
          <> metavar "FILE"
          <> help "input configuration file"
      )

modeReader :: ReadM Mode
modeReader = eitherReader $ \input ->
  case input of
    "initiator" -> Right Initiator
    "responder" -> Right Responder
    _           -> Left "Expected initiator or responder"
