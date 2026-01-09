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


module Morphir.Sample.Reg.LCR.RulesTest exposing (..)

{-| Tests the Rules structure.
-}

import Date exposing (Interval(..), Unit(..))
import Expect
import Morphir.Sample.Reg.LCR.Rules exposing (..)
import Test exposing (Test, describe, test)
import Time exposing (Month(..))


rulesTest : Test
rulesTest =
    let
        negative =
            { name = "negative", weight = 1, applies = \n -> n < 0 }

        positive =
            { name = "positive", weight = 1, applies = \n -> n > 0 }

        zero =
            { name = "zero", weight = 1, applies = \n -> n == 0 }
    in
    describe "Rules tests"
        [ test "foo" <| \_ -> False |> Expect.equal False
        , test "isApplicable negative vs -1" <| \_ -> (isApplicable -1 negative) |> Expect.equal True
        , test "isApplicable negative vs 0" <| \_ -> (isApplicable 0 negative) |> Expect.equal False
        , test "isApplicable negative vs 1" <| \_ -> (isApplicable 1 negative) |> Expect.equal False
        , test "isApplicable positive vs -1" <| \_ -> (isApplicable -1 negative) |> Expect.equal True
        , test "isApplicable positive vs 0" <| \_ -> (isApplicable 0 negative) |> Expect.equal False
        , test "isApplicable positive vs 1" <| \_ -> (isApplicable 1 negative) |> Expect.equal False
        , test "isApplicable zero vs -1" <| \_ -> (isApplicable -1 negative) |> Expect.equal True
        , test "isApplicable zero vs 0" <| \_ -> (isApplicable 0 negative) |> Expect.equal False
        , test "isApplicable zero vs 1" <| \_ -> (isApplicable 1 negative) |> Expect.equal False
        , test "findApplicable for -1" <| \_ -> Expect.equal (Just negative) (findApplicable -1 [ negative, positive, zero ])
        , test "findApplicable for 1" <| \_ -> Expect.equal (Just positive) (findApplicable 1 [ negative, positive, zero ])
        , test "findApplicable for 0" <| \_ -> Expect.equal (Just zero) (findApplicable 0 [ negative, positive, zero ])
        , test "findApplicable for nothing" <| \_ -> Expect.equal Nothing (findApplicable 0 [ negative, positive ])
        , test "isAnyApplicable for -1" <| \_ -> Expect.equal True (isAnyApplicable [ negative, positive, zero ] -1)
        , test "isAnyApplicable for 1" <| \_ -> Expect.equal True (isAnyApplicable [ negative, positive, zero ] 0)
        , test "isAnyApplicable for 0" <| \_ -> Expect.equal True (isAnyApplicable [ negative, positive, zero ] 1)
        , test "isAnyApplicable for nothing" <| \_ -> Expect.equal False (isAnyApplicable [ negative, positive ] 0)
        , test "find negative" <| \_ -> Expect.equal (Just negative) (find "negative" [ negative, positive, zero ])
        , test "find positive" <| \_ -> Expect.equal (Just positive) (find "positive" [ negative, positive, zero ])
        , test "find zero" <| \_ -> Expect.equal (Just zero) (find "zero" [ negative, positive, zero ])
        , test "find not" <| \_ -> Expect.equal Nothing (find "not" [ negative, positive, zero ])
        , test "findAll negative" <| \_ -> Expect.equal [ negative ] (findAll [ "negative" ] [ negative, positive, zero ])
        , test "findAll positive and zero" <| \_ -> Expect.equal [ positive, zero ] (findAll [ "zero", "positive" ] [ negative, positive, zero ])
        , test "findAll zero and positive" <| \_ -> Expect.equal [ zero, positive ] (findAll [ "zero", "positive" ] [ zero, negative, positive ])
        , test "findAll not" <| \_ -> Expect.equal [] (findAll [ "not" ] [ negative, positive, zero ])
        , test "findAll empty names" <| \_ -> Expect.equal [] (findAll [] [ negative, positive, zero ])
        , test "findAll empty rules" <| \_ -> Expect.equal [] (findAll [ "negative" ] [])
        ]
