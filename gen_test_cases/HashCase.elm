module HashCase exposing (..)

import Dict
import Dict.NonEmpty
import State exposing (State)
import Types.Segment exposing (TSegment(..))
import Util.Shared exposing (Generator, buildMain, dynamicOpts)


main : Generator
main =
    buildMain [ { dynamicOpts | addContentHash = True } ] state


state : State ()
state =
    Dict.singleton "messages" <|
        Dict.NonEmpty.fromList
            ( ( "en"
              , { pairs = Dict.fromList [ ( "text", ( Text "english text", [] ) ) ]
                , fallback = Nothing
                , resources = ()
                }
              )
            , [ ( "de"
                , { pairs = Dict.fromList [ ( "text", ( Text "german text", [] ) ) ]
                  , fallback = Nothing
                  , resources = ()
                  }
                )
              ]
            )
