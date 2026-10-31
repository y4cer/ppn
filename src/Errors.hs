module Errors where

import           Control.Exception

data PpnError
  = NoiseFailure SomeException
  | UnexpectedPSK
  | HandshakeNotComplete
  | ServerKeyMissing
  | ServerKeyMismatch
  deriving (Show)
