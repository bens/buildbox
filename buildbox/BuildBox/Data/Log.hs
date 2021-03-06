{-# LANGUAGE TypeSynonymInstances #-}

-- | When the output of a command is long, keeping it as a `String` is a bad idea.
module BuildBox.Data.Log
        ( Log
        , Line
        , empty
        , null
        , toString
        , fromString
        , (<|)
        , (|>)
        , (><)
        , firstLines
        , lastLines)
where
import Data.Sequence                    (Seq)
import Data.Text                        (Text)
import qualified Data.Text              as Text
import qualified Data.Sequence          as Seq
import qualified Data.Foldable          as F
import Prelude                          hiding (null)

-- | A sequence of lines, without newline charaters on the end.
type Log        = Seq Line
type Line       = Text


-- | O(1) No logs here.
empty :: Log
empty = Seq.empty

-- | O(1) Check if the log is empty.
null :: Log -> Bool
null  = Seq.null

-- | O(n) Convert a `Log` to a `String`.
toString :: Log -> String
toString ll     
        = Text.unpack 
        $ Text.intercalate (Text.pack "\n") 
        $ F.toList ll

-- | O(n) Convert a `String` to a `Log`.
fromString :: String -> Log
fromString str  
        = Seq.fromList 
        $ Text.lines 
        $ Text.pack str


-- | O(1) Add a `Line` to the start of a `Log`.
(<|):: Line -> Log -> Log
(<|)    = (Seq.<|)

-- | O(1) Add a `Line` to the end of a `Log`.
(|>)    :: Log -> Line -> Log
(|>)    = (Seq.|>)

-- | O(log(min(n1,n2))) Concatenate two `Log`s.
(><)    :: Log -> Log -> Log
(><)    = (Seq.><)


-- | O(n) Take the first m lines from a log
firstLines :: Int -> Log -> Log
firstLines m ll
        = Seq.take m ll

-- | O(n) Take the last m lines from a log
lastLines :: Int -> Log -> Log
lastLines m ll
        = Seq.drop (Seq.length ll - m) ll
        
