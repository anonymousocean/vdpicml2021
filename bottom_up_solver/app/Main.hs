{-# LANGUAGE RecordWildCards #-}

module Main where

import JSON
import Fixpoint
import FO

import Data.List ( mapAccumL, sort )
import Data.Hashable ( Hashable )
import Control.Exception
import Control.Monad
import Control.Concurrent
import Control.Concurrent.Async
import System.Environment
import System.Timeout
import System.Directory
import System.CPUTime
import Text.Printf

-- How many separators to return
numberOfSeparators = 1
timeOutSec = 60 -- (in ) = 100 seconds
timeFactor = 10^6
combinator :: (Eq t, Hashable t) => Combinator t
combinator = disjunctOrConjunct

-- Run searches with each possible target image in parallel and return
-- the first to find a separator
type Task = IO (String, [Formula])
raceOf :: [Task] -> IO (Maybe (String, [Formula]))
raceOf tasks = loopUntilOne [] tasks

loopUntilOne :: [Async (String, [Formula])] -> [Task] -> IO (Maybe (String, [Formula]))
loopUntilOne asyncs (task:rest) = withAsync task (\a -> loopUntilOne (a:asyncs) rest)
loopUntilOne asyncs []    = loopWith asyncs
  where loopWith :: [Async (String, [Formula])] -> IO (Maybe (String, [Formula]))
        loopWith asyncs   = (readPolls asyncs) $ pollAll asyncs
        pollAll  asyncs   = sequence $ map poll asyncs
        readPolls :: [Async (String, [Formula])]
                  -> IO [Maybe (Either SomeException (String, [Formula]))]
                  -> IO (Maybe (String, [Formula]))
        readPolls asyncs io = do results <- io
                                 processResults asyncs False results
        processResults _    _ ((Just (Right (name, fs@(_:_)))):_)      = return $ Just (name, fs)
        processResults asyncs flag ((Just (Right (name, []))):rest)    = processResults asyncs flag rest
        processResults _ flag ((Just (Left  e)):_)                     = throw e
        processResults asyncs flag (Nothing:rest)                      = processResults asyncs True rest
        processResults asyncs True  []                                 = loopWith asyncs
        processResults asyncs False []                                 = return Nothing


-- Takes directory of puzzle, list of relations to filter out
solvePuzzle :: FilePath -> [String] -> IO ()
solvePuzzle fn filt = do
  (lang, puzzle) <- vdpParse fn
  let langFiltered = case filt of
                       [] -> lang
                       _  -> filterLanguage lang filt
      tasks = mkTasks langFiltered puzzle combinator
  mbResult <- raceOf tasks
  case mbResult of
    Nothing -> putStrLn "=== NO SEPARATOR ==="
    Just (name, fs) -> do putStrLn $ "=== FOUND SEPARATOR ==="
                          putStrLn $ "Image: "++name++" with Separator: "++(show fs)
  where mkTasks lang Puzzle{..} c =
          let (special, regular) = test
              trainModels        = map snd train
              instances          = [(name, m:trainModels, map snd rest)
                                   | ((name, m), rest) <- allSplits [] (special++regular)]
          in  map aux instances
                where allSplits acc [] = []
                      allSplits acc (x:xs) = (x, acc++xs) : allSplits (acc++[x]) xs
                      aux (name, pos, neg) = pure $ (name, vdpFirstNSeparators
                                                           lang
                                                           (pos, neg)
                                                           c
                                                           numberOfSeparators)


main :: IO ()
main = do
  args <- getArgs
  case args of
    []             -> putStrLn "First argument must be 0 or 1..."
    ("0":fn:rest)  -> do putStrLn $ "Solving a single puzzle "++fn++" with filter "++(show rest)
                         start <- getCPUTime
                         solvePuzzle fn rest
                         end <- getCPUTime
                         let diff = fromIntegral (end - start) / (10^12)
                         printf "CPU time: %0.3f sec\n" (diff :: Double)
    ("1":fn:_)     -> do putStrLn $ "Solving a suite of puzzles in "++fn
                         runAllPuzzlesWithTimeout (timeOutSec * timeFactor) fn
    _              -> putStrLn "Bad arguments...exiting"


-- First arg is timeout in microseconds
runAllPuzzlesWithTimeout :: Int -> FilePath -> IO ()
runAllPuzzlesWithTimeout t fn = do
  puzzleDirs <- listDirectory fn
  withCurrentDirectory fn (solvePuzzlesWithTimeout (sort puzzleDirs))
    where solvePuzzlesWithTimeout dirs = do
            forM_ dirs (\puzzle -> do
                           putStrLn ""
                           putStrLn $ "=== Solving "++puzzle++" ==="
                           start <- getCPUTime
                           mbData <- timeout t (solvePuzzle puzzle [])
                           case mbData of
                             Nothing -> printf "TIMEOUT: %0.3d sec\n" timeOutSec
                             Just _  -> do end <- getCPUTime
                                           let diff = fromIntegral (end - start) / (10^12)
                                           printf "CPU time: %0.3f sec\n" (diff :: Double)
                                           return ())
