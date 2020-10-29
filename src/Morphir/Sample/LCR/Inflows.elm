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

module Morphir.Sample.LCR.Inflows exposing (..)


import Morphir.SDK.LocalDate exposing (LocalDate)
import Morphir.Sample.LCR.Basics exposing (..)
import Morphir.Sample.LCR.Flows exposing (..)
import Morphir.Sample.LCR.Counterparty exposing (..)
import Morphir.Sample.LCR.Rules exposing (..)
import Morphir.Sample.LCR.MaturityBucket exposing (..)


{-| The list of all rules pertaining to inflows. -}
inflowRules : (Flow -> Counterparty) -> LocalDate -> List (Rule Flow)
inflowRules toCounterparty t = 
    [ Rule "20(a)(1)" 1.0 (isRule20a1 t)
    , Rule "20(a)(3)-(6)" 1.0 isRule20a3dash6
    , Rule "22(b)(3)L1" -1.0 isRule22b3L2a
    , Rule "22(b)(3)L2a" -0.85 isRule22b3L2a
    , Rule "22(b)(3)L2b" -0.5 isRule22b3L2b
    , Rule "20(b)" 0.85 isRule20b
    , Rule "20(c)" 0.5 isRule20c
    , Rule "33(b)" 1.0 isRule33b
    , Rule "33(c)" 0.5 (isRule33c toCounterparty t)
    , Rule "33(d)(1)" 1.0 (isRule33d1 toCounterparty)
    , Rule "33(d)(2)" 1.0 (isRule33d2 toCounterparty)
    , Rule "33(e)" 1.0 isRule33e
    , Rule "33(g)" 1.0 isRule33g
    , Rule "33(h)" 0.0 isRule33h
    ]

-- Rule logic is below for (eventual) unit testability

isRule20a1 : LocalDate -> Flow -> Bool
isRule20a1 t flow =
    List.member flow.fed5GCode ["I.A.3.1", "I.A.3.2", "I.A.3.3", "I.A.3.4", "I.A.3.5", "I.A.3.6", "I.A.3.7", "I.A.3.8"]
    && daysToMaturity t flow.maturityDate == 0


isRule20a3dash6 : Flow -> Bool
isRule20a3dash6 flow =
    (
        List.member flow.fed5GCode ["I.A.1", "I.A.2"]
        && flow.collateralClass == Level1Assets
        && flow.isTreasuryControl
    ) 
    ||
    (
        List.member flow.fed5GCode ["I.S.1", "I.S.2", "I.S.4"]
        && flow.collateralClass == Level1Assets
        && flow.isTreasuryControl
        && flow.isUnencumbered
    )


isRule22b3L2a : Flow -> Bool
isRule22b3L2a flow =
    flow.fed5GCode == "S.I.19" && flow.collateralClass == Level2aAssets


isRule22b3L2b : Flow -> Bool
isRule22b3L2b flow =
    flow.fed5GCode == "S.I.19" && flow.collateralClass == Level2bAssets


isRule20b : Flow -> Bool
isRule20b flow =
    (
        List.member flow.fed5GCode ["I.A.1", "I.A.2"]
        && flow.collateralClass == Level2aAssets
        && flow.isTreasuryControl
    ) 
    ||
    (
        List.member flow.fed5GCode ["I.S.1", "I.S.2", "I.S.4"]
        && flow.collateralClass == Level2aAssets
        && flow.isTreasuryControl
        && flow.isUnencumbered
    )

isRule20c : Flow -> Bool
isRule20c flow =
    (
        List.member flow.fed5GCode ["I.A.1", "I.A.2"]
        && flow.collateralClass == Level2bAssets
        && flow.isTreasuryControl
    ) 
    ||
    (
        List.member flow.fed5GCode ["I.S.1", "I.S.2", "I.S.4"]
        && flow.collateralClass == Level2bAssets
        && flow.isTreasuryControl
        && flow.isUnencumbered
    )

isRule33b : { a | fed5GCode : String } -> Bool
isRule33b cashflow =
    cashflow.fed5GCode == "1.O.7"


isRule33c : (Flow -> Counterparty) -> LocalDate -> Flow -> Bool
isRule33c toCounterparty t flow =
    let
        cpty : Counterparty
        cpty = toCounterparty flow

        days : Int
        days = daysToMaturity t flow.maturityDate
    in
    ( 
        List.member flow.fed5GCode ["I.U.5", "I.U.6"]
            && List.member cpty.counterpartyType [ Retail, SmallBusiness ]
            && (0 < days && days <= 30)
    )
    ||
    ( 
        List.member flow.fed5GCode ["I.S.1", "I.S.2", "I.S.4", "I.S.5", "I.S.6", "I.S.7"]
            && cpty.counterpartyType == Retail
            && (0 < days && days <= 30)
    )

isRule33d1 : (Flow -> Counterparty) -> Flow -> Bool
isRule33d1 toCounterparty flow =
    let
        cpty : Counterparty
        cpty = toCounterparty flow
    in
    List.member flow.fed5GCode ["I.U.1", "I.U.2", "I.U.4"]
        ||
        ( List.member flow.fed5GCode ["I.U.5", "I.U.6"]
            && List.member cpty.counterpartyType 
                [ CentralBank
                , Bank
                , SupervisedNonBankFinancialEntity
                , DebtIssuingSpecialPurposeEntity
                , OtherFinancialEntity
                ]
        )


isRule33d2 : (Flow -> Counterparty) -> Flow -> Bool
isRule33d2 toCounterparty flow =
    let
        cpty : Counterparty
        cpty =  toCounterparty flow
    in
    List.member flow.fed5GCode ["I.U.5", "I.U.6"]
        && List.member cpty.counterpartyType 
            [ NonFinancialCorporate
            , Sovereign
            , GovernmentSponsoredEntity
            , PublicSectorEntity
            , MultilateralDevelopmentBank
            , OtherSupranational
            , Other
            ]

isRule33e : Flow -> Bool
isRule33e cashflow =
    cashflow.fed5GCode == "I.O.6" || cashflow.fed5GCode == "I.O.8"

-- isRule33f : a -> b
-- isRule33f flow =
--     Debug.todo "Rule 33(f) is actually a bunch of rules. Too many to do for now..."

isRule33g : { a | fed5GCode : String, isTreasuryControl : Bool } -> Bool
isRule33g cashflow =
    cashflow.fed5GCode == "I.O.5" && cashflow.isTreasuryControl

isRule33h : { a | fed5GCode : String, isTreasuryControl : Bool } -> Bool
isRule33h cashflow =
    cashflow.fed5GCode == "I.O.9" && cashflow.isTreasuryControl
