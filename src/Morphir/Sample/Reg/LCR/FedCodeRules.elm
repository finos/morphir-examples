{-
   Copyright 2020 Morgan Stanley

   Licensed under the Apache License, Version 2_0 (the "License");
   you may not use this file except in compliance with the License_
   You may obtain a copy of the License at

       http://www_apache_org/licenses/LICENSE-2_0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied_
   See the License for the specific language governing permissions and
   limitations under the License_
-}


module Morphir.Sample.Reg.LCR.FedCodeRules exposing (..)

import Dict exposing (Dict)
import Morphir.Sample.Reg.Country as Country exposing (Country)
import Morphir.Sample.Reg.Currency as Currency exposing (Currency(..), country)
import Morphir.Sample.Reg.LCR.CentralBank exposing (CentralBank(..))


type alias PartyID =
    String


type alias CountryCode =
    String


type alias ProductType =
    String


type alias Description5G =
    String


type alias AdjustedAmountUSD =
    Float


type alias AdjustedMXAmount =
    Float


type alias Account =
    String


type alias CostCenterCode =
    String


type alias CostCenterDescription =
    String


type alias LegalEntityCode =
    String


type alias TenQLevel1 =
    String


type alias TenQLevel2 =
    String


type alias TenQLevel3 =
    String


type alias TenQLevel4 =
    String


type alias TenQLevel5 =
    String


type alias TenQLevel6 =
    String


type Money a
    = Money Float


type Usd
    = Usd


type Mx
    = Mx


type alias LegalEntity =
    { code : String -- LegalEntityCode
    , country : Country
    }


type alias CostCenter =
    { code : String -- CostCenterCode
    , description : String -- CostCenterDescription
    }


type alias Counterparty =
    { country : Country
    , description5G : String -- Description5G
    , account : String -- Account
    }


type alias Cashflow =
    { legalEntity : LegalEntity
    , partyId : String -- PartyID
    , currency : Currency
    , counterparty : Counterparty
    , amountUSD : Float -- AdjustedAmountUSD
    , amountMx : Float -- AdjustedMXAmount
    , tenQLevel1 : String -- TenQLevel1
    , tenQLevel2 : String -- TenQLevel2
    , tenQLevel3 : String -- TenQLevel3
    , tenQLevel4 : String -- TenQLevel4
    , tenQLevel5 : String -- TenQLevel5
    , tenQLevel6 : String -- TenQLevel6
    }


type RuleCode
    = IA31
    | IA32
    | IA33
    | IA34
    | IA35
    | IA36
    | IA37
    | IA38
    | IA39
    | IA41
    | IA42
    | IA43
    | IA44
    | IA45
    | IA46
    | IA47
    | IA48
    | IA49
    | IU1
    | IU2
    | IU4
    | OW9
    | OW10
    | Unclassified


type CentralBankSubProduct
    = FRB
    | SNB
    | BOE
    | ECB
    | BOJ
    | RBA
    | BOC
    | OCB
    | Other_Cash_Currency_And_Coin


classify : Dict PartyID CentralBank -> Cashflow -> Maybe RuleCode
classify centralBanks cashflow =
    let
        partyIsCentralBank : Maybe CentralBank
        partyIsCentralBank =
            Dict.get cashflow.partyId centralBanks
    in
    -- It is a central bank
    case partyIsCentralBank of
        Just centralBank ->
            rules_I_A cashflow.tenQLevel6 centralBank

        notCentralBank ->
            if String.toUpper cashflow.tenQLevel5 == "CASH AND DUE FROM BANKS" || String.toUpper cashflow.tenQLevel5 == "OVERNIGHT AND TERM DEPOSITS" || String.toUpper cashflow.tenQLevel5 == "CASH EQUIVALENTS" then
                rule_I_U cashflow.amountUSD cashflow.legalEntity.country cashflow.currency cashflow.counterparty.country

            else
                Nothing


centralBankToSubProduct : CentralBank -> CentralBankSubProduct
centralBankToSubProduct cb =
    case cb of
        Federal_Reserve_Bank ->
            FRB

        Swiss_National_Bank ->
            SNB

        Bank_of_England ->
            BOE

        European_Central_Bank ->
            ECB

        Bank_of_Japan ->
            BOJ

        Reserve_Bank_of_Australia ->
            RBA

        Bank_of_Canada ->
            BOC

        -- TODO What maps to Other Cash Currency and Coin????
        _ ->
            OCB


segregatedCash : String
segregatedCash =
    "Seg Cash"


isCentralBank : Maybe CentralBank -> Bool
isCentralBank m =
    m |> Maybe.map (\x -> True) |> Maybe.withDefault False



--rules_I_A : TenQLevel6 -> CentralBank -> Maybe RuleCode


rules_I_A : String -> CentralBank -> Maybe RuleCode
rules_I_A tenQLevel6 centralBank =
    if tenQLevel6 == segregatedCash then
        Just (rule_I_A_3 centralBank)

    else
        Just (rule_I_A_4 centralBank)


rule_I_A_3 : CentralBank -> RuleCode
rule_I_A_3 centralBank =
    case centralBankToSubProduct centralBank of
        FRB ->
            IA31

        SNB ->
            IA32

        BOE ->
            IA33

        ECB ->
            IA34

        BOJ ->
            IA35

        RBA ->
            IA36

        BOC ->
            IA37

        OCB ->
            IA38

        Other_Cash_Currency_And_Coin ->
            IA39


rule_I_A_4 : CentralBank -> RuleCode
rule_I_A_4 centralBank =
    case centralBankToSubProduct centralBank of
        FRB ->
            IA41

        SNB ->
            IA42

        BOE ->
            IA43

        ECB ->
            IA44

        BOJ ->
            IA45

        RBA ->
            IA46

        BOC ->
            IA47

        OCB ->
            IA48

        Other_Cash_Currency_And_Coin ->
            IA49



--rule_I_U : AdjustedAmountUSD -> Country -> Currency -> Country -> Maybe RuleCode


rule_I_U : Float -> Country -> Currency -> Country -> Maybe RuleCode
rule_I_U adjustedAmountUSD legalEntityCountry cashflowCurrency counterpartyCountry =
    if netCashUSD adjustedAmountUSD >= 0 then
        if isOnshore legalEntityCountry cashflowCurrency counterpartyCountry then
            Just IU1

        else
            Just IU2

    else
        Just IU4


isOnshore : Country -> Currency -> Country -> Bool
isOnshore legalEntityCountry cashflowCurrency counterpartyCountry =
    Just legalEntityCountry == Currency.country cashflowCurrency && legalEntityCountry == counterpartyCountry


netCashUSD : AdjustedAmountUSD -> Float
netCashUSD adjustedAmountUSD =
    -- TODO the calculation
    adjustedAmountUSD
