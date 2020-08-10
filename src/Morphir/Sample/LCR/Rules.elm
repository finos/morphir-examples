{-
Copyright 2020 Morgan Stanley

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-}

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
