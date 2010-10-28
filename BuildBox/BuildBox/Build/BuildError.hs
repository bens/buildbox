{-# LANGUAGE ExistentialQuantification #-}
{-# OPTIONS_HADDOCK hide #-}

module BuildBox.Build.BuildError
	(BuildError(..))
where
import BuildBox.Pretty
import System.Exit
import Control.Monad.Error
import BuildBox.Data.Log		(Log)
import qualified BuildBox.Data.Log	as Log


-- BuildError -------------------------------------------------------------------------------------
-- | The errors we recognise.
data BuildError
	-- | Some generic error
	= ErrorOther String

	-- | Some system command fell over, and it barfed out the given stdout and stderr.
	| ErrorSystemCmdFailed
		{ buildErrorCmd 	:: String
		, buildErrorCode	:: ExitCode
		, buildErrorStdout	:: Log
		, buildErrorStderr	:: Log }
		
	-- | Some miscellanous IO action failed.
	| ErrorIOError IOError

	-- | Some property `check` was supposed to return the given boolean value, but it didn't.
	| forall prop. Show prop => ErrorCheckFailed Bool prop	

	-- | A build command needs the following file to continue.
	--   This can be used for writing make-like bots.
	| ErrorNeeds FilePath
	

instance Error BuildError where
 strMsg s = ErrorOther s

instance Pretty BuildError where
 ppr err
  = case err of
	ErrorOther str
	 -> text "Other error: " <> text str

	ErrorSystemCmdFailed{}
	 -> vcat 
		[ text "System command failure."
		, text "    command: " <> (text $ buildErrorCmd err)
		, text "  exit code: " <> (text $ show $ buildErrorCode err)
		, blank
		, if (not $ Log.null $ buildErrorStdout err)
		   then vcat 	[ text "-- stdout (last 10 lines) ------------------------------------------------------"
				, text $ Log.toString $ Log.lastLines 10 $ buildErrorStdout err]
		   else text ""
		, blank
		, if (not $ Log.null $ buildErrorStderr err)
		   then vcat	[ text "-- stderr (last 10 lines) ------------------------------------------------------"
				, text $ Log.toString $ Log.lastLines 10 $ buildErrorStderr err]
		   else text ""
		
		, 		  text "--------------------------------------------------------------------------------" ]
	
	ErrorIOError ioerr
	 -> text "IO error: " <> (text $ show ioerr)

	ErrorCheckFailed expected prop
	 -> text "Check failure: " <> (text $ show prop) <> (text " expected ") <> (text $ show expected)

	ErrorNeeds filePath
	 -> text "Build needs: " <> text filePath


instance Show BuildError where
 show err = render $ ppr err


