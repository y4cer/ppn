module Main (main) where

import           Config.File
import           Config.Peer
import qualified Data.ByteString       as BS
import qualified Data.Text             as Text
import           Data.Word
import           Handshake
import           System.IO
import           System.IO.Temp
import           Test.Hspec
import           Test.Hspec.QuickCheck
import           Test.QuickCheck
import           Transport.Class
import           Transport.Stdio

main :: IO ()
main = hspec $ modifyMaxSuccess (const 1000) $ do
  describe "Session" $ do
    prop "preserves message sequences in both directions" testEncryptDecrypt

  describe "Stdio framing" $
    prop "test message frames" $
      forAllShrink genFrame shrink testSendRecv

  describe "Config" $
    prop "test TOML fields encoding and decoding" testEncodeDecode

testEncryptDecrypt :: NonEmptyList [Word8] -> Expectation
testEncryptDecrypt (NonEmpty messages) = do
  (client, server) <- establishTestSession
  checkMessages client server messages
  where
    checkMessages _ _ [] = pure ()
    checkMessages client server (bytes : remaining) = do
      let message = BS.pack bytes

      (request, clientAfterSend) <- mustRight $ encryptMessage client message
      (received, serverAfterReceive) <- mustRight $ decryptMessage server request
      received `shouldBe` message

      (reply, serverAfterReply) <- mustRight $ encryptMessage serverAfterReceive received
      (echoed, clientAfterReply) <- mustRight $ decryptMessage clientAfterSend reply
      echoed `shouldBe` message

      checkMessages clientAfterReply serverAfterReply remaining

testSendRecv :: [Word8] -> Expectation
testSendRecv bytes = withTestTransport $ \handle transport -> do
  let message = BS.pack bytes
      size = BS.length message
      (hi, lo) = size `divMod` 256
      expectedHeader = BS.pack [fromIntegral hi, fromIntegral lo]

  sendPacket transport message

  hSeek handle AbsoluteSeek 0
  BS.hGet handle (size + 2) `shouldReturn` (expectedHeader <> message)

  hSeek handle AbsoluteSeek 0
  recvPacket transport `shouldReturn` Just message
  recvPacket transport `shouldReturn` Nothing

testEncodeDecode :: String -> String -> String -> Expectation
testEncodeDecode keyPath publicKey protocol = do
  let config = FileConfig
        { configPrivateKeyFile = keyPath
        , configPeerPublicKey = Text.pack publicKey
        , configPrologue = Text.pack protocol
        }
  decodeConfig (encodeConfig config) `shouldBe` Right config

genFrame :: Gen [Word8]
genFrame = do
  size <- chooseInt (0, 65535)
  vectorOf size arbitrary

withTestTransport :: (Handle -> StdioTransport -> IO a) -> IO a
withTestTransport action = withSystemTempFile "ppn-frame" $ \_ handle -> do
  hSetBinaryMode handle True
  action handle (Stdio handle handle)

establishTestSession :: IO (Session, Session)
establishTestSession = do
  clientKey <- genStaticKey
  serverKey <- genStaticKey

  clientEphemeral <- genEphemeralKey
  serverEphemeral <- genEphemeralKey

  let clientConfig = PeerConfig clientKey (snd serverKey) "ppn/test/v1"
      serverConfig = PeerConfig serverKey (snd clientKey) "ppn/test/v1"

  (firstMessage, handshake) <- mustRight $ startClientHandshake clientConfig clientEphemeral
  (reply, pendingServer) <- mustRight $ respondServerHandshake serverConfig serverEphemeral firstMessage

  client <- mustRight $ finishClientHandshake handshake reply
  (ready, nextClient) <- mustRight $ encryptMessage client "ready"

  server <- mustRight $ finishServerHandshake pendingServer ready

  pure (nextClient, server)

mustRight :: Show e => Either e a -> IO a
mustRight = either (fail . show) pure
