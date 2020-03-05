module Morphir.Sample.LCR.Rules exposing (..)


import Morphir.SDK.Basics exposing (Decimal)
import Morphir.Sample.LCR.Basics exposing (..)
import Morphir.Sample.LCR.Flows exposing (..)
import Morphir.Sample.LCR.Counterparty exposing (..)


type alias Rule a =
    { name : String
    , weight : Decimal
    , applies : a -> Bool
    }


isApplicable : a -> (Rule a) -> Bool
isApplicable a rule =
    rule.applies a


findApplicable : a -> List (Rule a) -> Maybe (Rule a)
findApplicable a rules =
    rules
        |> List.filter (isApplicable a)
        |> List.head


isAnyApplicable : List (Rule a) -> a -> Bool
isAnyApplicable rules a  =
    rules
        |> List.filter (isApplicable a)
        |> List.isEmpty
        |> not


find : String -> List (Rule a) -> Maybe (Rule a)
find  name rules =
    rules
        |> List.filter (\r -> r.name == name)
        |> List.head


findAll : List String -> List (Rule a) -> List (Rule a)
findAll  names rules =
    rules
        |> List.filter (\r -> List.member r.name names)
