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


module Morphir.Sample.Reg.LCR.FedCodeRulesTest exposing (..)

{-| Tests the Rules structure.
-}

import Dict
import Expect
import Morphir.Sample.Reg.Country exposing (Country(..))
import Morphir.Sample.Reg.Currency exposing (Currency(..))
import Morphir.Sample.Reg.LCR.CentralBank exposing (CentralBank(..))
import Morphir.Sample.Reg.LCR.FedCodeRules exposing (..)
import Test exposing (Test, describe, test)


cashflow =
    Cashflow
        (LegalEntity "LE1" USA)
        "partyID1"
        USD
        (Counterparty USA "5Gx" "Account1")
        100.0
        90.0
        ""
        ""
        ""
        "Segregated Cash"
        ""
        ""


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
        [ test "basic net USD" <| \_ -> netCashUSD 100 |> Expect.equal 100
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
    describe "Onshore vs Offshore tests"
        [ test "All US" <| \_ -> isOnshore USA USD USA |> Expect.true "Expected True"
        , test "Cashflow EUR vs all USD" <| \_ -> isOnshore USA EUR USA |> Expect.false "Expected False"
        , test "LegalEntity AUS vs all USD" <| \_ -> isOnshore AUS USD USA |> Expect.false "Expected False"
        , test "Counterparty AUS vs all USD" <| \_ -> isOnshore USA USD AUS |> Expect.false "Expected False"
        ]


rule_I_A_3Test : Test
rule_I_A_3Test =
    describe "Rule I.A.3 Test"
        [ test "Federal_Reserve_Bank" <| \_ -> rule_I_A_3 Federal_Reserve_Bank |> Expect.equal [ "3", "1" ]
        , test "Swiss_National_Bank" <| \_ -> rule_I_A_3 Swiss_National_Bank |> Expect.equal [ "3", "2" ]
        , test "Bank_of_England" <| \_ -> rule_I_A_3 Bank_of_England |> Expect.equal [ "3", "3" ]
        , test "European_Central_Bank" <| \_ -> rule_I_A_3 European_Central_Bank |> Expect.equal [ "3", "4" ]
        , test "Bank_of_Japan" <| \_ -> rule_I_A_3 Bank_of_Japan |> Expect.equal [ "3", "5" ]
        , test "Reserve_Bank_of_Australia" <| \_ -> rule_I_A_3 Reserve_Bank_of_Australia |> Expect.equal [ "3", "6" ]
        , test "Bank_of_Canada" <| \_ -> rule_I_A_3 Bank_of_Canada |> Expect.equal [ "3", "7" ]
        , test "Peoples_Bank_of_China" <| \_ -> rule_I_A_3 Peoples_Bank_of_China |> Expect.equal [ "3", "8" ]
        , test "Banco_Central_Do_Brasil" <| \_ -> rule_I_A_3 Banco_Central_Do_Brasil |> Expect.equal [ "3", "8" ]

        --, test "Other_Cash_Currency_And_Coin" <| \_ -> rule_I_A_3 FRB |> Expect.equal "I.A.3.9"
        ]


rule_I_A_4Test : Test
rule_I_A_4Test =
    describe "Rule I.A.4 Test"
        [ test "Federal_Reserve_Bank" <| \_ -> rule_I_A_4 Federal_Reserve_Bank |> Expect.equal [ "4", "1" ]
        , test "Swiss_National_Bank" <| \_ -> rule_I_A_4 Swiss_National_Bank |> Expect.equal [ "4", "2" ]
        , test "Bank_of_England" <| \_ -> rule_I_A_4 Bank_of_England |> Expect.equal [ "4", "3" ]
        , test "European_Central_Bank" <| \_ -> rule_I_A_4 European_Central_Bank |> Expect.equal [ "4", "4" ]
        , test "Bank_of_Japan" <| \_ -> rule_I_A_4 Bank_of_Japan |> Expect.equal [ "4", "5" ]
        , test "Reserve_Bank_of_Australia" <| \_ -> rule_I_A_4 Reserve_Bank_of_Australia |> Expect.equal [ "4", "6" ]
        , test "Bank_of_Canada" <| \_ -> rule_I_A_4 Bank_of_Canada |> Expect.equal [ "4", "7" ]
        , test "Peoples_Bank_of_China" <| \_ -> rule_I_A_4 Peoples_Bank_of_China |> Expect.equal [ "4", "8" ]
        , test "Banco_Central_Do_Brasil" <| \_ -> rule_I_A_4 Banco_Central_Do_Brasil |> Expect.equal [ "4", "8" ]

        --, test "Other_Cash_Currency_And_Coin" <| \_ -> rule_I_A_3 FRB |> Expect.equal ["4","9"]
        ]


rules_I_ATest : Test
rules_I_ATest =
    let
        segCash =
            segregatedCash

        notSegCash =
            "Other"
    in
    describe "Rules I.A test"
        [ test "Not Seg Cash Federal_Reserve_Bank" <| \_ -> rules_I_A notSegCash Federal_Reserve_Bank |> toString |> String.left 5 |> Expect.equal "I.A.3"
        , test "Seg Cash Federal_Reserve_Bank" <| \_ -> rules_I_A segCash Federal_Reserve_Bank |> toString |> String.left 5 |> Expect.equal "I.A.4"
        ]


rule_I_UTest : Test
rule_I_UTest =
    describe "Rules I.U test"
        [ test "negative and onshore" <| \_ -> rule_I_U -1 USA USD USA |> Expect.equal [ "I", "U", "4" ]
        , test "negative and offshore" <| \_ -> rule_I_U -1 USA EUR USA |> Expect.equal [ "I", "U", "4" ]
        , test "0 and onshore" <| \_ -> rule_I_U 0 USA USD USA |> Expect.equal [ "I", "U", "1" ]
        , test "0 and offshore" <| \_ -> rule_I_U 0 USA EUR USA |> Expect.equal [ "I", "U", "2" ]
        , test "positive and onshore" <| \_ -> rule_I_U 1 USA USD USA |> Expect.equal [ "I", "U", "1" ]
        , test "positive and offshore 0" <| \_ -> rule_I_U 1 AUS USD USA |> Expect.equal [ "I", "U", "2" ]
        , test "positive and offshore 1" <| \_ -> rule_I_U 1 USA EUR USA |> Expect.equal [ "I", "U", "2" ]
        , test "positive and offshore 2" <| \_ -> rule_I_U 1 USA USD JPN |> Expect.equal [ "I", "U", "2" ]
        ]


classifyTest : Test
classifyTest =
    describe "6G classification test"
        [ test "I.A.3.1" <| \_ -> classify centralBanks { cashflow | tenQLevel4 = "            ", partyId = "fed" } |> Expect.equal [ "I", "A", "3", "1" ]
        , test "I.A.3.8" <| \_ -> classify centralBanks { cashflow | tenQLevel4 = "            ", partyId = "lux" } |> Expect.equal [ "I", "A", "3", "8" ]
        , test "I.A.4.1" <| \_ -> classify centralBanks { cashflow | tenQLevel4 = segregatedCash, partyId = "fed" } |> Expect.equal [ "I", "A", "4", "1" ]
        , test "I.A.4.2" <| \_ -> classify centralBanks { cashflow | tenQLevel4 = segregatedCash, partyId = "swiss" } |> Expect.equal [ "I", "A", "4", "2" ]
        , test "I.U.1" <| \_ -> classify centralBanks { cashflow | tenQLevel5 = "CASH AND DUE FROM BANKS", partyId = "", amountUSD = 1, legalEntity = LegalEntity "" USA, counterparty = Counterparty USA "" "", currency = USD } |> Expect.equal [ "I", "U", "1" ]
        , test "I.U.2" <| \_ -> classify centralBanks { cashflow | tenQLevel5 = "OVERNIGHT AND TERM DEPOSITS", partyId = "", amountUSD = 0, legalEntity = LegalEntity "" USA, counterparty = Counterparty USA "" "", currency = EUR } |> Expect.equal [ "I", "U", "2" ]
        , test "I.U.4" <| \_ -> classify centralBanks { cashflow | tenQLevel5 = "CASH EQUIVALENTS", partyId = "", amountUSD = -1, legalEntity = LegalEntity "" USA, counterparty = Counterparty USA "" "", currency = USD } |> Expect.equal [ "I", "U", "4" ]
        , test "unclassified" <| \_ -> classify centralBanks { cashflow | partyId = "", amountUSD = -1, legalEntity = LegalEntity "" USA, counterparty = Counterparty USA "" "", currency = USD } |> Expect.equal []
        ]


calculateTest : Test
calculateTest =
    let
        c1 =
            { cashflow | tenQLevel4 = "            ", partyId = "fed" }

        c2 =
            { cashflow | tenQLevel4 = "            ", partyId = "lux" }

        c3 =
            { cashflow | tenQLevel4 = segregatedCash, partyId = "fed" }

        c4 =
            { cashflow | tenQLevel4 = segregatedCash, partyId = "swiss" }
    in
    describe "6G calculation test"
        [ test "I.A.3.1, I.A.3.8, I.A.4.1, I.A.4.2" <|
            \_ ->
                calculate centralBanks [ c1, c2, c3, c4 ]
                    |> Expect.equal
                        [ ( c1, [ "I", "A", "3", "1" ] )
                        , ( c2, [ "I", "A", "3", "8" ] )
                        , ( c3, [ "I", "A", "4", "1" ] )
                        , ( c4, [ "I", "A", "4", "2" ] )
                        ]
        ]
