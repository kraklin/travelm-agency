module FallbackCase exposing (main)

import Dict
import Dict.NonEmpty
import State exposing (State)
import Types.Segment exposing (TSegment(..))
import Util.Shared exposing (Generator, buildMain, dynamicOpts, inlineOpts)


main : Generator
main =
    buildMain [ inlineOpts, dynamicOpts ] state


state : State ()
state =
    Dict.singleton "messages" <|
        Dict.NonEmpty.fromList
            ( ( "en"
              , { pairs = Dict.fromList [ ( "text", ( Text "english text", [] ) ) ]
                , fallback = Just "de"
                , resources = ()
                }
              )
            , [ ( "de"
                , { pairs =
                        Dict.fromList
                            [ ( "text", ( Text "german text", [] ) )
                            , ( "justInGerman", ( Text "more german text", [] ) )
                            ]
                  , fallback = Nothing
                  , resources = ()
                  }
                )
              ]
            )
