module Test.Hspec.UtilSpec (main, spec) where

import           Test.Hspec.Meta

import qualified Control.Exception as E
import           Test.Hspec.Util

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "quantify" $ do
    it "returns an amount and a word given an amount and word" $ do
      quantify 1 "thing" `shouldBe` "1 thing"

    it "returns a singular word given the number 1" $ do
      quantify 1 "thing" `shouldBe` "1 thing"

    it "returns a plural word given a number greater than 1" $ do
      quantify 2 "thing" `shouldBe` "2 things"

    it "returns a plural word given the number 0" $ do
      quantify 0 "thing" `shouldBe` "0 things"

  describe "safeEvaluate" $ do
    it "returns Right on success" $ do
      Right e <- safeEvaluate (return 23 :: IO Int)
      e `shouldBe` 23

    it "returns Left on exception" $ do
      Left e <- safeEvaluate (E.throwIO E.DivideByZero :: IO Int)
      show e `shouldBe` "divide by zero"

    it "re-throws AsyncException" $ do
      safeEvaluate (E.throwIO E.UserInterrupt :: IO Int) `shouldThrow` (== E.UserInterrupt)
