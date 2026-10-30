module Errors where

import           Control.Exception (SomeException)

data PpnError
  = NoiseFailure SomeException
  | UnexpectedPSK
  | HandshakeNotComplete
  | ServerKeyMissing
  | ServerKeyMismatch
  deriving (Show)
