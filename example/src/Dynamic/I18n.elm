module Dynamic.I18n exposing (I18n, Language(..), decodeMessages, differentVars, greeting, init, languageFromString, languageSwitchInfo, languageToFileName_messages, languageToString, languages, loadMessages, orderDemo, specialCharacters, staticText)

{-| This file was generated by elm-i18n version 2.4.0.


-}

import Array
import Http
import Json.Decode
import List
import String
import Tuple


type I18n
    = I18n { messages : Array.Array String }


{-| Initialize an (empty) `I18n` instance. This is useful on startup when no JSON was `load`ed yet.


-}
init : I18n
init =
    I18n { messages = Array.empty }


fallbackValue_ : String
fallbackValue_ =
    "..."


{-| Replaces all placeholder expressions in a string in order with the given values


-}
replacePlaceholders : List String -> String -> String
replacePlaceholders list_ str_ =
    List.foldl
        (\val_ ( i_, acc_ ) -> ( i_ + 1, String.replace ("{" ++ String.fromInt i_ ++ "}") val_ acc_ ))
        ( 0, str_ )
        list_
        |> Tuple.second


{-| Enumeration of the supported languages


-}
type Language
    = De
    | En
    | Fr


{-| A list containing all `Language`s


-}
languages : List Language
languages =
    [ De, En, Fr ]


{-| Convert a `Language` to its `String` representation.


-}
languageToString : Language -> String
languageToString lang_ =
    case lang_ of
        De ->
            "de"

        En ->
            "en"

        Fr ->
            "fr"


{-| Maybe parse a `Language` from a `String`. 
This only considers the keys given during compile time, if you need something like 'en-US' to map to the correct `Language`,
you should write your own parsing function.


-}
languageFromString : String -> Maybe Language
languageFromString lang_ =
    case lang_ of
        "de" ->
            Just De

        "en" ->
            Just En

        "fr" ->
            Just Fr

        _ ->
            Nothing


differentVars : I18n -> { a | elmEn : String, unionGer : String } -> String
differentVars (I18n { messages }) placeholders_ =
    case Array.get 0 messages of
        Just translation_ ->
            replacePlaceholders [ placeholders_.elmEn, placeholders_.unionGer ] translation_

        Nothing ->
            fallbackValue_


greeting : I18n -> String -> String
greeting (I18n { messages }) name_ =
    case Array.get 1 messages of
        Just translation_ ->
            replacePlaceholders [ name_ ] translation_

        Nothing ->
            fallbackValue_


languageSwitchInfo : I18n -> String -> String
languageSwitchInfo (I18n { messages }) currentLanguage_ =
    case Array.get 2 messages of
        Just translation_ ->
            replacePlaceholders [ currentLanguage_ ] translation_

        Nothing ->
            fallbackValue_


orderDemo : I18n -> { a | language : String, name : String } -> String
orderDemo (I18n { messages }) placeholders_ =
    case Array.get 3 messages of
        Just translation_ ->
            replacePlaceholders [ placeholders_.language, placeholders_.name ] translation_

        Nothing ->
            fallbackValue_


specialCharacters : I18n -> String
specialCharacters (I18n { messages }) =
    case Array.get 4 messages of
        Just translation_ ->
            translation_

        Nothing ->
            fallbackValue_


staticText : I18n -> String
staticText (I18n { messages }) =
    case Array.get 5 messages of
        Just translation_ ->
            translation_

        Nothing ->
            fallbackValue_


{-| Decode an `I18n` from Json. Make sure this is *only* used on the files generated by this package.


-}
decodeMessages : Json.Decode.Decoder (I18n -> I18n)
decodeMessages =
    Json.Decode.array Json.Decode.string |> Json.Decode.map (\arr_ (I18n i18n_) -> I18n { i18n_ | messages = arr_ })


{-| 
Load translations for identifier 'messages' and a `Language` from the server. This is a simple `Http.get`, if you need more customization,
you can use the `decoder` instead. Pass the path and a callback to your `update` function, for example

    load { language = De, path = "/i18n", onLoad = GotTranslations }

will make a `GET` request to /i18n/messages.de.4271012564.json and will call GotTranslations with the decoded response.


-}
loadMessages : { language : Language, path : String, onLoad : Result Http.Error (I18n -> I18n) -> msg } -> Cmd msg
loadMessages opts_ =
    Http.get
        { expect = Http.expectJson opts_.onLoad decodeMessages
        , url = opts_.path ++ "/" ++ languageToFileName_messages opts_.language
        }


languageToFileName_messages : Language -> String
languageToFileName_messages lang_ =
    case lang_ of
        De ->
            "messages.de.4271012564.json"

        En ->
            "messages.en.2397054257.json"

        Fr ->
            "messages.fr.4224922667.json"
