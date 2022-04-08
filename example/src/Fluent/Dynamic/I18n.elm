module Fluent.Dynamic.I18n exposing (I18n, Language(..), attributes, attributesTitle, attributesWithVarAndTerm, compileTimeDatesAndNumbers, dateTimeFun, decodeDemo, displayGender, dynamicTermKey, fallback, init, languageFromString, languageToFileName_demo, languageToString, languages, loadDemo, matchOnGender, matchOnNumbers, nestedTermKey, numberFun, staticTermKey)

{-| This file was generated by travelm-agency version 2.8.1.

If you have any issues with the generated code, do not hesitate to open an issue here: <https://github.com/andreasewering/travelm-agency/issues>

-}

import Array
import Dict
import Http
import Intl
import Json.Decode
import List
import Maybe
import Parser exposing ((|.), (|=))
import Result
import String
import Time
import Tuple


type I18n
    = I18n { demo : Array.Array String } Intl.Intl Language


{-| Initialize an (empty) `I18n` instance. This is useful on startup when no JSON was `load`ed yet.
-}
init : Intl.Intl -> Language -> I18n
init intl lang =
    I18n { demo = Array.empty } intl lang


{-| Enumeration of the supported languages
-}
type Language
    = De
    | En
    | Fr


{-| A list containing all `Language`s. The list is sorted alphabetically.
-}
languages : List Language
languages =
    [ De, En, Fr ]


{-| Convert a `Language` to its `String` representation.
-}
languageToString : Language -> String
languageToString lang =
    case lang of
        De ->
            "de"

        En ->
            "en"

        Fr ->
            "fr"


{-| Maybe parse a `Language` from a `String`.
This will map languages based on the prefix i.e. 'en-US' and 'en' will both map to 'En' unless you provided a 'en-US' translation file.
-}
languageFromString : String -> Maybe Language
languageFromString lang =
    let
        helper langs =
            case langs of
                [] ->
                    Maybe.Nothing

                l :: ls ->
                    if String.startsWith (languageToString l) lang then
                        Maybe.Just l

                    else
                        helper ls
    in
    helper (List.reverse languages)


{-| Load translations for identifier 'demo' and a `Language` from the server. This is a simple `Http.get`, if you need more customization,
you can use the `decoder` instead. Pass the path and a callback to your `update` function, for example

    load { language = De, path = "/i18n", onLoad = GotTranslations }

will make a `GET` request to /i18n/demo.de.4291402199.json and will call GotTranslations with the decoded response.

-}
loadDemo : { language : Language, path : String, onLoad : Result Http.Error (I18n -> I18n) -> msg } -> Cmd msg
loadDemo opts =
    Http.get
        { expect = Http.expectJson opts.onLoad decodeDemo
        , url = opts.path ++ "/" ++ languageToFileName_demo opts.language
        }


attributes : I18n -> String
attributes (I18n { demo } _ _) =
    case Array.get 0 demo of
        Just translation ->
            translation

        Nothing ->
            fallbackValue


attributesTitle : I18n -> String
attributesTitle (I18n { demo } _ _) =
    case Array.get 1 demo of
        Just translation ->
            translation

        Nothing ->
            fallbackValue


attributesWithVarAndTerm : I18n -> String -> String
attributesWithVarAndTerm ((I18n { demo } _ _) as i18n) var =
    case Array.get 2 demo of
        Just translation ->
            replacePlaceholders i18n [ var ] translation

        Nothing ->
            fallbackValue


compileTimeDatesAndNumbers : I18n -> String
compileTimeDatesAndNumbers (I18n { demo } _ _) =
    case Array.get 3 demo of
        Just translation ->
            translation

        Nothing ->
            fallbackValue


dateTimeFun : I18n -> Time.Posix -> String
dateTimeFun ((I18n { demo } _ _) as i18n) date =
    case Array.get 4 demo of
        Just translation ->
            replacePlaceholders i18n [ String.fromInt <| Time.posixToMillis date ] translation

        Nothing ->
            fallbackValue


displayGender : I18n -> String -> String
displayGender ((I18n { demo } _ _) as i18n) gender =
    case Array.get 5 demo of
        Just translation ->
            replacePlaceholders i18n [ gender ] translation

        Nothing ->
            fallbackValue


dynamicTermKey : I18n -> String -> String
dynamicTermKey ((I18n { demo } _ _) as i18n) adjective =
    case Array.get 6 demo of
        Just translation ->
            replacePlaceholders i18n [ adjective ] translation

        Nothing ->
            fallbackValue


fallback : I18n -> String
fallback (I18n { demo } _ _) =
    case Array.get 7 demo of
        Just translation ->
            translation

        Nothing ->
            fallbackValue


matchOnGender : I18n -> String -> String
matchOnGender ((I18n { demo } _ _) as i18n) gender =
    case Array.get 8 demo of
        Just translation ->
            replacePlaceholders i18n [ gender ] translation

        Nothing ->
            fallbackValue


matchOnNumbers : I18n -> Float -> String
matchOnNumbers ((I18n { demo } _ _) as i18n) amount =
    case Array.get 9 demo of
        Just translation ->
            replacePlaceholders i18n [ String.fromFloat amount ] translation

        Nothing ->
            fallbackValue


nestedTermKey : I18n -> String
nestedTermKey (I18n { demo } _ _) =
    case Array.get 10 demo of
        Just translation ->
            translation

        Nothing ->
            fallbackValue


numberFun : I18n -> Float -> String
numberFun ((I18n { demo } _ _) as i18n) num =
    case Array.get 11 demo of
        Just translation ->
            replacePlaceholders i18n [ String.fromFloat num ] translation

        Nothing ->
            fallbackValue


staticTermKey : I18n -> String
staticTermKey (I18n { demo } _ _) =
    case Array.get 12 demo of
        Just translation ->
            translation

        Nothing ->
            fallbackValue


{-| Decode an `I18n` from Json. Make sure this is _only_ used on the files generated by this package.
-}
decodeDemo : Json.Decode.Decoder (I18n -> I18n)
decodeDemo =
    Json.Decode.array Json.Decode.string
        |> Json.Decode.map (\arr (I18n i18n intl lang) -> I18n { i18n | demo = arr } intl lang)


fallbackValue : String
fallbackValue =
    "..."


parser : I18n -> List String -> Parser.Parser String
parser ((I18n _ intl lang) as i18n) argList =
    let
        args =
            Array.fromList argList

        getArg n =
            Array.get n args |> Maybe.withDefault ""

        wrappedLang =
            "\"" ++ languageToString lang ++ "\""

        argParser =
            Parser.oneOf
                [ Parser.succeed wrappedLang |. Parser.token "}"
                , Parser.succeed (\str -> wrappedLang ++ ",{" ++ str ++ "}")
                    |= (Parser.chompUntil "}" |> Parser.getChompedString)
                    |. Parser.token "}"
                ]

        matchParser =
            Parser.succeed Tuple.pair
                |= (Parser.chompUntil "|" |> Parser.getChompedString)
                |. Parser.token "|"
                |= (Parser.chompUntil "}"
                        |> Parser.getChompedString
                        |> Parser.andThen
                            (\str ->
                                case
                                    Json.Decode.decodeString (Json.Decode.dict Json.Decode.string) ("{" ++ str ++ "}")
                                of
                                    Ok ok ->
                                        Parser.succeed ok

                                    Err err ->
                                        Parser.problem (Json.Decode.errorToString err)
                            )
                   )
                |. Parser.token "}"

        numberFormatUnsafe n parsedArgString =
            Maybe.withDefault "" <|
                Intl.unsafeAccess intl <|
                    "[\"NumberFormat\",["
                        ++ parsedArgString
                        ++ "],\"format\",["
                        ++ getArg n
                        ++ "]]"

        dateFormatUnsafe n parsedArgString =
            Maybe.withDefault "" <|
                Intl.unsafeAccess intl <|
                    "[\"DateTimeFormat\",["
                        ++ parsedArgString
                        ++ "],\"format\",["
                        ++ getArg n
                        ++ "]]"

        matchStrings n ( default, cases ) =
            Dict.get (getArg n) cases
                |> Maybe.withDefault default
                |> Parser.run (parser i18n argList)
                |> Result.toMaybe
                |> Maybe.withDefault fallbackValue

        matchNumbers n ( default, cases ) =
            getArg n
                |> String.toFloat
                |> Maybe.andThen
                    (\i ->
                        Intl.determinePluralRuleFloat
                            intl
                            { language = languageToString lang, number = i, type_ = Intl.Cardinal }
                            |> Intl.pluralRuleToString
                            |> (\pluralRule -> Dict.get pluralRule cases)
                    )
                |> Maybe.withDefault default
                |> Parser.run (parser i18n argList)
                |> Result.toMaybe
                |> Maybe.withDefault fallbackValue
    in
    Parser.loop "" <|
        \state ->
            Parser.oneOf
                [ Parser.succeed ((++) state >> Parser.Loop)
                    |. Parser.token "{"
                    |= Parser.oneOf
                        [ Parser.succeed getArg |= Parser.int |. Parser.token "}"
                        , Parser.succeed numberFormatUnsafe |. Parser.token "N" |= Parser.int |= argParser
                        , Parser.succeed dateFormatUnsafe |. Parser.token "D" |= Parser.int |= argParser
                        , Parser.succeed matchStrings
                            |. Parser.token "S"
                            |= Parser.int
                            |. Parser.token "|"
                            |= matchParser
                        , Parser.succeed matchNumbers
                            |. Parser.token "P"
                            |= Parser.int
                            |. Parser.token "|"
                            |= matchParser
                        ]
                , Parser.chompUntilEndOr "{"
                    |> Parser.getChompedString
                    |> Parser.map ((++) state)
                    |> Parser.andThen
                        (\str ->
                            Parser.oneOf
                                [ Parser.succeed (Parser.Done str) |. Parser.end, Parser.succeed (Parser.Loop str) ]
                        )
                ]


{-| Replaces all placeholders with the given arguments using the Intl API on the marked spots
-}
replacePlaceholders : I18n -> List String -> String -> String
replacePlaceholders i18n argList =
    Parser.run (parser i18n argList) >> Result.toMaybe >> Maybe.withDefault fallbackValue


languageToFileName_demo : Language -> String
languageToFileName_demo lang =
    case lang of
        De ->
            "demo.de.4291402199.json"

        En ->
            "demo.en.3249469367.json"

        Fr ->
            "demo.fr.4256166018.json"
