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
        [ test "Federal_Reserve_Bank" <| \_ -> rule_I_A_3 Federal_Reserve_Bank |> Expect.equal IA31
        , test "Swiss_National_Bank" <| \_ -> rule_I_A_3 Swiss_National_Bank |> Expect.equal IA32
        , test "Bank_of_England" <| \_ -> rule_I_A_3 Bank_of_England |> Expect.equal IA33
        , test "European_Central_Bank" <| \_ -> rule_I_A_3 European_Central_Bank |> Expect.equal IA34
        , test "Bank_of_Japan" <| \_ -> rule_I_A_3 Bank_of_Japan |> Expect.equal IA35
        , test "Reserve_Bank_of_Australia" <| \_ -> rule_I_A_3 Reserve_Bank_of_Australia |> Expect.equal IA36
        , test "Bank_of_Canada" <| \_ -> rule_I_A_3 Bank_of_Canada |> Expect.equal IA37
        , test "Peoples_Bank_of_China" <| \_ -> rule_I_A_3 Peoples_Bank_of_China |> Expect.equal IA38
        , test "Banco_Central_Do_Brasil" <| \_ -> rule_I_A_3 Banco_Central_Do_Brasil |> Expect.equal IA38

        --, test "Other_Cash_Currency_And_Coin" <| \_ -> rule_I_A_3 FRB |> Expect.equal IA39
        ]


rule_I_A_4Test : Test
rule_I_A_4Test =
    describe "Rule I.A.4 Test"
        [ test "Federal_Reserve_Bank" <| \_ -> rule_I_A_4 Federal_Reserve_Bank |> Expect.equal IA41
        , test "Swiss_National_Bank" <| \_ -> rule_I_A_4 Swiss_National_Bank |> Expect.equal IA42
        , test "Bank_of_England" <| \_ -> rule_I_A_4 Bank_of_England |> Expect.equal IA43
        , test "European_Central_Bank" <| \_ -> rule_I_A_4 European_Central_Bank |> Expect.equal IA44
        , test "Bank_of_Japan" <| \_ -> rule_I_A_4 Bank_of_Japan |> Expect.equal IA45
        , test "Reserve_Bank_of_Australia" <| \_ -> rule_I_A_4 Reserve_Bank_of_Australia |> Expect.equal IA46
        , test "Bank_of_Canada" <| \_ -> rule_I_A_4 Bank_of_Canada |> Expect.equal IA47
        , test "Peoples_Bank_of_China" <| \_ -> rule_I_A_4 Peoples_Bank_of_China |> Expect.equal IA48
        , test "Banco_Central_Do_Brasil" <| \_ -> rule_I_A_4 Banco_Central_Do_Brasil |> Expect.equal IA48

        --, test "Other_Cash_Currency_And_Coin" <| \_ -> rule_I_A_3 FRB |> Expect.equal IA39
        ]


rules_I_ATest : Test
rules_I_ATest =
    let
        segCash =
            segregatedCash

        notSegCash =
            "Other"
    in
    describe "Rules I.A Test"
        [ test "Seg Cash Federal_Reserve_Bank" <| \_ -> rules_I_A segCash Federal_Reserve_Bank |> Debug.toString |> String.left 8 |> Expect.equal "Just IA3"
        , test "Not Seg Cash Federal_Reserve_Bank" <| \_ -> rules_I_A notSegCash Federal_Reserve_Bank |> Debug.toString |> String.left 8 |> Expect.equal "Just IA4"
        ]


classifyTest : Test
classifyTest =
    let
        segFed =
            { cashflow | tenQLevel6 = segregatedCash, partyId = "fed" }

        segSwiss =
            { cashflow | tenQLevel6 = segregatedCash, partyId = "swiss" }

        unsegFed =
            { cashflow | tenQLevel6 = "", partyId = "fed" }

        unsegSwiss =
            { cashflow | tenQLevel6 = "", partyId = "lux" }
    in
    describe "6G classification test"
        [ test "I.A.3.1" <| \_ -> classify centralBanks segFed |> Expect.equal (Just IA31)
        , test "I.A.3.2" <| \_ -> classify centralBanks segSwiss |> Expect.equal (Just IA32)
        , test "I.A.4.1" <| \_ -> classify centralBanks unsegFed |> Expect.equal (Just IA41)
        , test "I.A.4.2" <| \_ -> classify centralBanks unsegSwiss |> Expect.equal (Just IA48)
        ]
