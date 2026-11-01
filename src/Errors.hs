module Errors where

import           Control.Exception

data PpnError
  = NoiseFailure SomeException
  | UnexpectedPSK
  | InvalidConfirmation
  | HandshakeNotComplete
  | ServerKeyMissing
  | ServerKeyMismatch
  deriving (Show)
