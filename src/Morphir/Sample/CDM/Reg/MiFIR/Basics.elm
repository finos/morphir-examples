module Morphir.Sample.CDM.Reg.MiFIR.Basics exposing (..)


exists : Maybe a -> Bool
exists m =
    case m of
        Nothing ->
            False

        _ ->
            True


type alias Number =
    Float


type alias Amount =
    Float


type alias Version =
    Int
