module Types.Features exposing (Feature(..), Features, addFeature, combine, combineMap, default, isActive)

{-| Conditionals that change the output of the code generator that are inferred by the given translation files

    Intl : Need dependency on the intl-proxy package. Allows for usage of the Browsers Intl API in generated code.

    Html : Will produce Html instead of String as a return value (or Element/Element.WithContext (TODO))

    Debug : Change default values to show errors when they happen. (TODO)

-}

import List.Extra


type Feature
    = Intl
    | Debug


type Features
    = Features (List Feature)


default : Features
default =
    Features []


addFeature : Feature -> Features -> Features
addFeature feature (Features features) =
    Features (feature :: features)


isActive : Feature -> Features -> Bool
isActive feature (Features features) =
    List.member feature features


combineMap : (a -> Features) -> List a -> Features
combineMap f =
    List.map f >> combine


combine : List Features -> Features
combine =
    List.concatMap unwrap >> List.Extra.unique >> Features


unwrap : Features -> List Feature
unwrap (Features features) =
    features
