
module Repa
	( repaUnpack
	, repaBuild
	, repaTest
	, BuildResults(..))
where
import Benchmarks
import Config
import BuildBox
import Data.Time
import Control.Monad


-- Unpack -----------------------------------------------------------------------------------------
-- | Download the Repa package from code.haskell.org,
repaUnpack config
 = do	outCheckFalseOk "* Checking build directory is empty"
	 $ HasDir $ (configTmpDir config) ++ "/repa-head"
	
	outCheckOk "* Checking Google is reachable"
	 $ HostReachable "www.google.com"

	outCheckOk "* Checking code.haskell.org is reachable"
	 $ HostReachable "code.haskell.org"
	
	outCheckOk "* Checking code.haskell.org web server is up"
	 $ UrlGettable "http://code.haskell.org"
	
	out "\n"
	inDir (configTmpDir config)
	 $ do	outLn "* Getting Darcs Package"
		system "darcs get http://code.haskell.org/repa/repa-head"
	


-- Building ---------------------------------------------------------------------------------------	
-- | Build the packages and register then with the given compiler.
repaBuild config
 = inDir (configTmpDir config)
 $ inDir "repa-head"
 $ do	outLn "* Building Packages"

	mapM_ (repaBuildPackage True config)
		[ "repa"
		, "repa-bytestring"
		, "repa-io"
		, "repa-algorithms"]

	repaBuildPackage False config "repa-examples"


repaBuildPackage install config dirPackage
 = inDir dirPackage
 $ do	outLine

	system	"runghc Setup.hs clean"
	system	$ "runghc Setup.hs configure"
		++ " --user "
		++ " --with-compiler=" ++ configWithGhc config
		++ " --with-hc-pkg="   ++ configWithGhcPkg config
		
	system	"runghc Setup.hs build"

	when install
	 $ system	"runghc Setup.hs install"

	outBlank
	
	
-- Testing ----------------------------------------------------------------------------------------
data BuildResults
	= BuildResults
	{ buildResultTime		:: UTCTime
	, buildResultEnvironment	:: Environment
	, buildResultBench		:: [BenchResult] }
	deriving (Show, Read)

instance Pretty BuildResults where
 ppr results
	= hang (ppr "BuildResults") 2 $ vcat
	[ ppr "time: " <> (ppr $ buildResultTime results)
	, ppr $ buildResultEnvironment results
	, ppr ""
	, vcat 	$ punctuate (ppr "\n") 
		$ map ppr 
		$ buildResultBench results ]

-- | Run regression tests.	
repaTest :: Config -> Environment -> Build ()
repaTest config env
 = do	
	-- Get the current time.
	utcTime	<- io $ getCurrentTime

	-- Load the baseline file if it was given.
	mBaseline <- case configAgainstResults config of
			Nothing		-> return Nothing
			Just fileName
			 -> do	file	<- io $ readFile fileName
				return	$ Just file
				
	let resultsPrior
		= maybe []
			(\contents -> buildResultBench $ read contents)
			mBaseline

	-- Run the benchmarks in the build directory
	benchResults
	 <- inDir (configTmpDir config ++ "/repa-head")
 	 $ do	mapM 	(outRunBenchmarkWith (configIterations config)  resultsPrior)
			(benchmarks config)

	-- Make the build results.
	let buildResults
		= BuildResults
		{ buildResultTime		= utcTime
		, buildResultEnvironment	= env
		, buildResultBench		= benchResults }

	-- Write results to a file if requested.	
	maybe 	(return ())
		(\fileName -> do
			outLn $ "* Writing results to " ++ fileName
			io $ writeFile fileName $ show buildResults)
		(configWriteResults config)
	
	-- Mail results to recipient if requested.
	let spaceHack = text . unlines . map (\l -> " " ++ l) . lines . render
	maybe 	(return ())
		(\(from, to) -> do
			outLn $ "* Mailing results to " ++ to 
			mail	<- createMailWithCurrentTime from to "Repa build"
				$ render $ vcat
				[ text "Repa Nightly Build"
				, blank
				, ppr env
				, blank
				, spaceHack $ pprComparisons resultsPrior benchResults
				, blank ]
				
			sendMailWithMailer mail defaultMailer				
			return ())
		(configMailFromTo config)
