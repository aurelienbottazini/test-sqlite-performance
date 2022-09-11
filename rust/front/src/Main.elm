module Main exposing (..)

import Browser
import Html exposing (..)

greet : String -> String
greet name = "Hello, " ++ name ++ "!"

main : Html msg
main =
  Html.text (greet "Auray")
