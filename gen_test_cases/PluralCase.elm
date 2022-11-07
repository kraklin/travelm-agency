module PluralCase exposing (..)

import Dict
import Dict.NonEmpty
import State exposing (State)
import Types.ArgValue exposing (ArgValue(..))
import Types.Segment exposing (TSegment(..))
import Util.Shared exposing (Generator, buildMain, dynamicOpts, inlineOpts)


main : Generator
main =
    buildMain [ inlineOpts, dynamicOpts ] state


state : State ()
state =
    Dict.singleton "messages" <|
        Dict.NonEmpty.singleton
            "en"
            { pairs =
                Dict.fromList
                    [ ( "text"
                      , ( Text "I met "
                        , [ PluralCase "number" [] ( Text "many people.", [] ) <|
                                Dict.singleton "one" ( Text "a single person.", [] )
                          ]
                        )
                      )
                    ]
            , fallback = Nothing
            , resources = ()
            }
