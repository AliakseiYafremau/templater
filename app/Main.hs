module Main where

import Options.Applicative
import System.Directory (createDirectoryIfMissing, doesFileExist, getHomeDirectory,
                         doesDirectoryExist, listDirectory, copyFile)
import System.FilePath ((</>), takeFileName)
import qualified Data.ByteString as BS
import Control.Monad (when, unless)
import Data.List (sort)

data Command = Store { target :: FilePath }
             | Load  { templateName :: String, outputPath :: Maybe FilePath }
             | List
             deriving (Show)

storeCommand :: Parser Command
storeCommand = Store
    <$> strOption
        ( long "target"
       <> short 't'
       <> metavar "FILE"
       <> help "File to store in templates" )

loadCommand :: Parser Command
loadCommand = Load
    <$> strArgument
        ( metavar "TEMPLATE"
       <> help "Template name to load" )
    <*> optional (strOption
        ( long "output"
       <> short 'o'
       <> metavar "FILE"
       <> help "Output file path" ))

listCommand :: Parser Command
listCommand = pure List

commandParser :: Parser Command
commandParser = subparser
    ( command "store" (info storeCommand (progDesc "Store a file as template"))
   <> command "load"  (info loadCommand  (progDesc "Load a template to file"))
   <> command "list"  (info listCommand  (progDesc "List all available templates"))
    )

getTemplatesDir :: IO FilePath
getTemplatesDir = do
    home <- getHomeDirectory
    return $ home </> ".temlpater"

storeTemplate :: FilePath -> IO ()
storeTemplate srcFile = do
    templatesDir <- getTemplatesDir
    createDirectoryIfMissing True templatesDir
    
    let destFile = templatesDir </> takeFileName srcFile
    
    exists <- doesFileExist srcFile
    if exists
        then do
            content <- BS.readFile srcFile
            BS.writeFile destFile content
            putStrLn $ "Template stored: " ++ takeFileName srcFile
        else
            putStrLn $ "Error: Source file does not exist: " ++ srcFile

loadTemplate :: String -> Maybe FilePath -> IO ()
loadTemplate templateName outputPath = do
    templatesDir <- getTemplatesDir
    let templatePath = templatesDir </> templateName
    
    exists <- doesFileExist templatePath
    if exists
        then do
            let dest = case outputPath of
                        Just path -> path
                        Nothing   -> templateName
            copyFile templatePath dest
            putStrLn $ "Template loaded to: " ++ dest
        else do
            putStrLn $ "Error: Template not found: " ++ templateName
            showAvailableTemplates

listTemplates :: IO ()
listTemplates = do
    templatesDir <- getTemplatesDir
    dirExists <- doesDirectoryExist templatesDir
    
    if dirExists
        then do
            templates <- listDirectory templatesDir
            if null templates
                then putStrLn "No templates available"
                else do
                    putStrLn "Available templates:"
                    mapM_ putStrLn (sort templates)
        else putStrLn "Templates directory does not exist"

showAvailableTemplates :: IO ()
showAvailableTemplates = do
    templatesDir <- getTemplatesDir
    dirExists <- doesDirectoryExist templatesDir
    when dirExists $ do
        templates <- listDirectory templatesDir
        unless (null templates) $ do
            putStrLn "Available templates:"
            mapM_ putStrLn (sort templates)

main :: IO ()
main = do
    cmd <- execParser (info (commandParser <**> helper) 
        ( fullDesc
        <> progDesc "Command line tool for storing and loading templates"
        <> header "Template Storage Tool - v1.0" ))

    case cmd of
        Store target    -> storeTemplate target
        Load name output -> loadTemplate name output
        List           -> listTemplates