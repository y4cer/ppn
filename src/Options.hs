module Options where

import Options.Applicative

data Sample = Sample
  { hello :: String,
    quiet :: Bool,
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
commandParser = undefined

keygenParser :: Parser Command
keygenParser = undefined

runParser :: Parser Command
runParser = undefined

modeReader :: ReadM Mode
modeReader = eitherReader $ \input ->
  case input of
    "init" -> Right Initiator

sample :: Parser Sample
sample =
  Sample
    <$> strOption
      ( long "hello"
          <> metavar "TARGET"
          <> help "Target for the greeting"
      )
    <*> switch
      ( long "quiet"
          <> short 'q'
          <> help "Whether to be quiet"
      )
    <*> option
      auto
      ( long "enthusiasm"
          <> help "How enthusiastically to greet"
          <> showDefault
          <> value 1
          <> metavar "INT"
      )
