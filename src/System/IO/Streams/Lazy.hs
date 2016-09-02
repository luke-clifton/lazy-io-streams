{-# OPTIONS_GHC -fno-warn-tabs #-}
-- | This module provides some arguably evil functions
-- for turning your nice io-streams into lazy lists.
module System.IO.Streams.Lazy where

import Prelude hiding (read)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Lazy as BL
import System.IO.Streams (InputStream, OutputStream, read)
import System.IO.Streams.Concurrent (makeChanPipe)
import System.IO.Unsafe (unsafeInterleaveIO)

-- | Convert an input stream into a lazy list.
toLazyList :: InputStream a -> IO [a]
toLazyList is = unsafeInterleaveIO $ do
	ma <- read is
	case ma of
		Nothing -> return []
		Just a -> do
			as <- toLazyList is
			return (a : as)

-- | Create an output stream and a lazy list that contains the values
-- that you feed into that output stream. Make sure you evaluate the list
-- in a separate thread to the one you write to the stream in.
lazyListOutput :: IO (OutputStream a, [a])
lazyListOutput = do
	(is, os) <- makeChanPipe
	as <- toLazyList is
	return (os, as)

-- | Convert an input stream of strict `ByteString`s to a lazy `ByteString`.
toLazyByteString :: InputStream BS.ByteString -> IO BL.ByteString
toLazyByteString is = BL.fromChunks <$> toLazyList is

-- | Create a lazy `ByteString` by feeding an `OutputStream` strict
-- `ByteString`s
lazyByteStringOutput :: IO (OutputStream BS.ByteString, BL.ByteString)
lazyByteStringOutput = do
    (os, ll) <- lazyListOutput
    return (os, BL.fromChunks ll)
