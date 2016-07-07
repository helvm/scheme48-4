
module Main where

import Control.Monad
import Text.ParserCombinators.Parsec hiding (spaces)
import System.Environment

data LispVal =
    Atom String
  | List [LispVal]
  | DottedList [LispVal] LispVal
  | Number Integer
  | String String
  | Bool Bool
  deriving Show

parseString :: Parser LispVal
parseString = do
  char '"'
  x <- many parseStringContents
  char '"'
  return $ String x

parseStringContents :: Parser Char
parseStringContents =
  escapedChars <|> noneOf "\""

escapedChars :: Parser Char
escapedChars = do
  char '\\'
  c <- oneOf "\"nrt\\"
  return $ case c of
    'n' -> '\n'
    't' -> '\t'
    '\\' -> '\\'
    _ -> c

parseAtom :: Parser LispVal
parseAtom = do
  first <- letter <|> symbol
  rest <- many (letter <|> digit <|> symbol)
  let atom = first : rest
  return $ case atom of
    "#t" -> Bool True
    "#f" -> Bool False
    _    -> Atom atom

parseNumber :: Parser LispVal
-- parseNumber = liftM (Number . read) $ many1 digit
-- parseNumber = do
--  digits <- many1 digit
--  return $ Number $ read digits
parseNumber = many1 digit >>= return . Number . read

parseExpr :: Parser LispVal
parseExpr = parseAtom
         <|> parseString
         <|> parseNumber

symbol :: Parser Char
symbol = oneOf "!#$%&|*+-/:<=>?@^_~"

readExpr :: String -> String
readExpr input = case parse parseExpr "lisp" input of
  Left err -> "No match: " ++ show err
  Right val -> "Found value " ++ show val

spaces :: Parser ()
spaces = skipMany1 space

main :: IO ()
main = do
  expr : _ <- getArgs
  putStrLn $ readExpr expr
