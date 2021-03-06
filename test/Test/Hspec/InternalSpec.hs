module Test.Hspec.InternalSpec (main, spec) where

import           Test.Hspec.Meta

import           System.IO.Silently
import qualified Test.Hspec.Internal as H
import qualified Test.Hspec.Config as H
import           Test.QuickCheck

main :: IO ()
main = hspec spec

evaluateExample :: H.Example e => e -> IO H.Result
evaluateExample = H.evaluateExample H.defaultConfig

spec :: Spec
spec = do
  describe "evaluateExample" $ do

    context "for Bool" $ do
      it "returns Success on True" $ do
        evaluateExample True `shouldReturn` H.Success

      it "returns Fail on False" $ do
        evaluateExample False `shouldReturn` H.Fail ""

      it "propagates exceptions" $ do
        evaluateExample (error "foobar" :: Bool) `shouldThrow` errorCall "foobar"

    context "for Expectation" $ do
      it "returns Success if all expectations hold" $ do
        evaluateExample (23 `shouldBe` (23 :: Int)) `shouldReturn` H.Success

      it "returns Fail if an expectation does not hold" $ do
        evaluateExample (23 `shouldBe` (42 :: Int)) `shouldReturn` H.Fail "expected: 42\n but got: 23"

      it "propagates exceptions" $ do
        evaluateExample (error "foobar" :: Expectation) `shouldThrow` errorCall "foobar"

      it "silences any output to stdout" $ do
        (capture . evaluateExample $ putStrLn "foobar") `shouldReturn` ("", H.Success)

    context "for Property" $ do
      it "returns Success if property hold" $ do
        evaluateExample (property $ \n -> n == (n :: Int)) `shouldReturn` H.Success

      it "returns Fail if property does not hold" $ do
        H.Fail _ <- evaluateExample $ property $ \n -> n /= (n :: Int)
        return ()

      it "propagates exceptions" $ do
        pending "this probaly needs a patch to QuickCheck"
        -- evaluateExample (property $ (error "foobar" :: Int -> Bool)) `shouldThrow` errorCall "foobar"
