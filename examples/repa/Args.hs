{-# LANGUAGE ScopedTypeVariables #-}

module Args
	( BuildArg(..)
	, buildArgs)
where
import System.Console.ParseArgs


-- Command line args for the buildbot.
data BuildArg
	= ArgHelp
	| ArgVerbose
	| ArgTmpDir
	| ArgWithGhcBuild
	| ArgDoNightly
	| ArgDoUnpackGhc
	| ArgWithGhcSnapshot
	| ArgDoBuildGhc
	| ArgDoUnpack
	| ArgDoDump
	| ArgDoCompare
	| ArgDoBuild
	| ArgDoTest
	| ArgTestIterations
	| ArgWriteResults
	| ArgAgainstResults
	| ArgMailFrom 
	| ArgMailTo
	deriving (Eq, Ord, Show)


buildArgs :: [Arg BuildArg]
 = 	[ Arg	{ argIndex	= ArgHelp
		, argAbbr	= Just 'h'
		, argName	= Just "help"
		, argData	= Nothing
		, argDesc	= "Print this usage help." }

	, Arg	{ argIndex	= ArgVerbose
		, argAbbr	= Just 'v'
		, argName	= Just "verbose"
		, argData	= Nothing
		, argDesc	= "Verbose logging of build commands." }

	, Arg	{ argIndex	= ArgTmpDir
		, argAbbr	= Nothing
		, argName	= Just "dir"
		, argData	= argDataOptional "dir" ArgtypeString
		, argDesc	= "Scratch dir to do the build in." }

	, Arg	{ argIndex	= ArgDoNightly
		, argAbbr	= Nothing
		, argName	= Just "nightly"
		, argData	= Nothing
		, argDesc	= "Run the entire nightly build: unpack, build, test." }

	, Arg	{ argIndex	= ArgDoUnpackGhc
		, argAbbr	= Nothing
		, argName	= Just "unpack-ghc"
		, argData	= argDataOptional "file" ArgtypeString
		, argDesc	= "Unpack this GHC snapshot and update it from darcs.haskell.org." }

	, Arg	{ argIndex	= ArgDoBuildGhc
		, argAbbr	= Nothing
		, argName	= Just "build-ghc"
		, argData	= Nothing
		, argDesc	= "Build the GHC repo." }

	, Arg	{ argIndex	= ArgWithGhcSnapshot
		, argAbbr	= Nothing
		, argName	= Just "with-ghc-snapshot"
		, argData	= argDataOptional "file" ArgtypeString
		, argDesc	= "Use this GHC snapshot" }

	, Arg	{ argIndex	= ArgDoUnpack
		, argAbbr	= Nothing
		, argName	= Just "unpack"
		, argData	= Nothing
		, argDesc	= "Download the latest version of Repa from code.haskell.org." }

	, Arg	{ argIndex	= ArgDoBuild
		, argAbbr	= Nothing
		, argName	= Just "build"
		, argData	= Nothing
		, argDesc	= "Build and register the Repa packages." }

	, Arg	{ argIndex	= ArgWithGhcBuild
		, argAbbr	= Nothing
		, argName	= Just "with-ghc-build"
		, argData	= argDataOptional "dir" ArgtypeString
		, argDesc	= "Build Repa with the GHC build in this dir." }

	, Arg	{ argIndex	= ArgDoDump
		, argAbbr	= Nothing
		, argName	= Just "dump"
		, argData	= argDataOptional "file" ArgtypeString
		, argDesc	= "Dump a results file in human readable format." }

	, Arg	{ argIndex	= ArgDoCompare 
		, argAbbr	= Nothing
		, argName	= Just "compare"
		, argData	= Nothing
		, argDesc	= "Compare two results files." }

	, Arg	{ argIndex	= ArgDoTest
		, argAbbr	= Nothing
		, argName	= Just "test"
		, argData	= Nothing
		, argDesc	= "Run regression tests." }

	, Arg	{ argIndex	= ArgTestIterations
		, argAbbr	= Just 'i'
		, argName	= Just "iterations"
		, argData	= argDataDefaulted "int" ArgtypeInt 1
		, argDesc	= "(opt. for test mode) Number of times to run each benchmark." }
		
	, Arg	{ argIndex	= ArgWriteResults
		, argAbbr	= Just 'w'
		, argName	= Just "write"
		, argData	= argDataOptional "file" ArgtypeString
		, argDesc	= "(opt. for test mode) Write results to this file." }
		
	, Arg	{ argIndex	= ArgAgainstResults
		, argAbbr	= Just 'a'
		, argName	= Just "against"
		, argData	= argDataOptional "file" ArgtypeString
		, argDesc	= "(opt. for test mode) Print running comparison against results in this file." }
		
	, Arg	{ argIndex	= ArgMailFrom
		, argAbbr	= Nothing
		, argName	= Just "mailfrom"
		, argData	= argDataOptional "address" ArgtypeString
		, argDesc	= "Mail results from this address." }

	, Arg	{ argIndex	= ArgMailTo
		, argAbbr	= Nothing
		, argName	= Just "mailto"
		, argData	= argDataOptional "address" ArgtypeString
		, argDesc	= " ...to this address." }
		
	]