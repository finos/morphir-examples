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


module Morphir.Sample.Reg.LCR.FedCodeTest exposing (..)

{-| Tests the Rules structure.
-}

import Date exposing (Interval(..), Unit(..))
import Dict
import Expect
import Morphir.Sample.Reg.Country exposing (Country(..))
import Morphir.Sample.Reg.Currency exposing (Currency(..))
import Morphir.Sample.Reg.LCR.CentralBank exposing (CentralBank(..))
import Morphir.Sample.Reg.LCR.FedCode exposing (..)
import Test exposing (Test, describe, test)
import Time exposing (Month(..))


cashflow =
    Cashflow
        (LegalEntity "LE1" (Just USA))
        "partyID1"
        USD
        (Counterparty USA "5Gx" "Account1")
        (Money 100)
        (Money 90)
        ""
        ""
        ""
        ""
        ""
        "Segregated Cash"


centralBanks =
    Dict.fromList
        [ ( "brasil", Banco_Central_Do_Brasil )
        , ( "japan", Bank_of_Japan )
        , ( "england", Bank_of_England )
        , ( "france", Banca_De_France )
        , ( "italy", Bance_Di_Italia )
        , ( "swiss", Swiss_National_Bank )
        , ( "korea", Bank_of_Korea )
        , ( "deutsche", Deutsche_Bundesbank )
        , ( "lux", Banque_Centrale_Du_Luxembourg )
        , ( "china", Peoples_Bank_of_China )
        , ( "india", Reserve_Bank_of_India )
        , ( "russia", Central_Bank_of_The_Russian_Federation )
        , ( "fed", Federal_Reserve_Bank )
        ]


netUsdTest : Test
netUsdTest =
    describe "Net USD tests"
        [ test "basic net USD" <| \_ -> netCashUSD cashflow |> Expect.equal 100
        ]


centralBankToSubProductTest : Test
centralBankToSubProductTest =
    describe "CentralBank to SubPrduct tests"
        [ test "basic net FRB" <| \_ -> centralBankToSubProduct Federal_Reserve_Bank |> Expect.equal FRB
        , test "basic net SNB" <| \_ -> centralBankToSubProduct Swiss_National_Bank |> Expect.equal SNB
        , test "basic net BOE" <| \_ -> centralBankToSubProduct Bank_of_England |> Expect.equal BOE
        , test "basic net ECB" <| \_ -> centralBankToSubProduct European_Central_Bank |> Expect.equal ECB
        , test "basic net BOJ" <| \_ -> centralBankToSubProduct Bank_of_Japan |> Expect.equal BOJ
        , test "basic net RBA" <| \_ -> centralBankToSubProduct Reserve_Bank_of_Australia |> Expect.equal RBA
        , test "basic net BOC" <| \_ -> centralBankToSubProduct Bank_of_Canada |> Expect.equal BOC
        , test "basic net OCB" <| \_ -> centralBankToSubProduct Banque_Centrale_Du_Luxembourg |> Expect.equal OCB
        ]


isOnshoreTest : Test
isOnshoreTest =
    let
        c =
            cashflow
    in
    describe "Onshore vs Offshore tests"
        [ test "All US" <| \_ -> isOnshore c |> Expect.true "Expected True"
        , test "Cashflow EUR vs all USD" <| \_ -> isOnshore { c | currency = EUR } |> Expect.false "Expected False"
        , test "LegalEntity AUS vs all USD" <| \_ -> isOnshore { c | legalEntity = LegalEntity "LE1" (Just AUS) } |> Expect.false "Expected False"
        , test "Counterparty AUS vs all USD" <| \_ -> isOnshore { c | counterparty = Counterparty AUS "" "" } |> Expect.false "Expected False"
        ]


classifyTest : Test
classifyTest =
    let
        c =
            cashflow
    in
    describe "6G classification test"
        [ test "I.A.3.1" <| \_ -> classify { c | partyId = "fed" } centralBanks |> Expect.equal IA31
        , test "I.A.3.2" <| \_ -> classify { c | partyId = "swiss" } centralBanks |> Expect.equal IA32
        ]
