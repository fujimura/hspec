module Test.Hspec.Util (
  quantify
, safeEvaluate
) where

import           Control.Applicative
import qualified Control.Exception as E

-- | Create a more readable display of a quantity of something.
--
-- Examples:
--
-- >>> quantify 0 "example"
-- "0 examples"
--
-- >>> quantify 1 "example"
-- "1 example"
--
-- >>> quantify 2 "example"
-- "2 examples"
quantify :: Int -> String -> String
quantify 1 s = "1 " ++ s
quantify n s = show n ++ " " ++ s ++ "s"

safeEvaluate :: IO a -> IO (Either E.SomeException a)
safeEvaluate action = (Right <$> action) `E.catches` [
  -- Re-throw AsyncException, otherwise execution will not terminate on SIGINT
  -- (ctrl-c).  All AsyncExceptions are re-thrown (not just UserInterrupt)
  -- because all of them indicate severe conditions and should not occur during
  -- normal operation.
    E.Handler $ \e -> E.throw (e :: E.AsyncException)

  , E.Handler $ \e -> (return . Left) (e :: E.SomeException)
  ]
