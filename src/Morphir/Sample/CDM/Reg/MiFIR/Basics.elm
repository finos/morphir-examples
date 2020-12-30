module Morphir.Sample.CDM.Reg.MiFIR.Basics exposing (..)


exists : Maybe a -> Bool
exists m =
    case m of
        Nothing ->
            False

        _ ->
            True


flatMap : (a -> Maybe b) -> Maybe a -> Maybe b
flatMap f maybe =
    case maybe of
        Just value ->
            f value

        Nothing ->
            Nothing


type alias Number =
    Float


type alias Amount =
    Float


type alias Version =
    Int
