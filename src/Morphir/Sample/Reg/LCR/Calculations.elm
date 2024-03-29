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


module Morphir.Sample.Reg.LCR.Calculations exposing (..)

import Morphir.SDK.LocalDate exposing (LocalDate, addDays)
import Morphir.Sample.Reg.LCR.Basics exposing (..)
import Morphir.Sample.Reg.LCR.Counterparty exposing (..)
import Morphir.Sample.Reg.LCR.Flows exposing (..)
import Morphir.Sample.Reg.LCR.Inflows as Inflows
import Morphir.Sample.Reg.LCR.Outflows as Outflows
import Morphir.Sample.Reg.LCR.Product exposing (..)
import Morphir.Sample.Reg.LCR.Rules as Rules



-- Forumulas from the OCC: https://www.occ.gov/news-issuances/bulletins/2014/bulletin-2014-51.html
--  https://www.occ.gov/topics/supervision-and-examination/capital-markets/balance-sheet-management/liquidity/Basel-III-LCR-Formulas.pdf
--  https://www.govinfo.gov/content/pkg/FR-2014-10-10/pdf/2014-22520.pdf (page 61477)
-- {-| This module is broken up into the same structure as the example formulas in the referenced PDF. -}
-- {-| Here's the LCR as it's commonly known. -}


lcr : (Flow -> Counterparty) -> (ProductId -> Product) -> LocalDate -> (LocalDate -> List Flow) -> Balance -> Ratio
lcr toCounterparty product t flowsForDate reserveBalanceRequirement =
    let
        hqla : Balance
        hqla =
            hqlaAmount product (flowsForDate t) reserveBalanceRequirement

        totalNetCashOutflow : Balance
        totalNetCashOutflow =
            totalNetCashOutflowAmount toCounterparty t flowsForDate
    in
    hqla / totalNetCashOutflow


{-| HQLA Amount is the LCR numerator. It has several components, which are specified as nested functions.
-}
hqlaAmount : (ProductId -> Product) -> List Flow -> Balance -> Balance
hqlaAmount product t0Flows reserveBalanceRequirement =
    let
        level1LiquidAssetsThatAreEligibleHQLA : Balance
        level1LiquidAssetsThatAreEligibleHQLA =
            t0Flows
                |> List.filter (\flow -> flow.assetType == Level1Assets && isHQLA product flow)
                |> List.map .amount
                |> List.sum

        level1LiquidAssetAmount : Balance
        level1LiquidAssetAmount =
            level1LiquidAssetsThatAreEligibleHQLA - reserveBalanceRequirement

        level2aLiquidAssetsThatAreEligibleHQLA : Balance
        level2aLiquidAssetsThatAreEligibleHQLA =
            t0Flows
                |> List.filter (\flow -> flow.assetType == Level2aAssets && isHQLA product flow)
                |> List.map .amount
                |> List.sum

        level2aLiquidAssetAmount : Balance
        level2aLiquidAssetAmount =
            0.85 * level2aLiquidAssetsThatAreEligibleHQLA

        level2bLiquidAssetsThatAreEligibleHQLA : Balance
        level2bLiquidAssetsThatAreEligibleHQLA =
            t0Flows
                |> List.filter (\flow -> flow.assetType == Level2bAssets && isHQLA product flow)
                |> List.map .amount
                |> List.sum

        level2bLiquidAssetAmount : Balance
        level2bLiquidAssetAmount =
            0.5 * level2bLiquidAssetsThatAreEligibleHQLA

        unadjustedExcessHQLAAmount : Balance
        unadjustedExcessHQLAAmount =
            let
                level2CapExcessAmount : Balance
                level2CapExcessAmount =
                    max (level2aLiquidAssetAmount + level2bLiquidAssetAmount - 0.6667 * level1LiquidAssetAmount) 0.0

                level2bCapExcessAmount : Balance
                level2bCapExcessAmount =
                    max (level2bLiquidAssetAmount - level2CapExcessAmount - 0.1765 * (level1LiquidAssetAmount + level2aLiquidAssetAmount)) 0.0
            in
            level2CapExcessAmount + level2bCapExcessAmount

        adjustedExcessHQLAAmount : Balance
        adjustedExcessHQLAAmount =
            let
                adjustedLevel1LiquidAssetAmount : Balance
                adjustedLevel1LiquidAssetAmount =
                    level1LiquidAssetAmount

                adjustedlevel2aLiquidAssetAmount : Balance
                adjustedlevel2aLiquidAssetAmount =
                    level2aLiquidAssetAmount * 0.85

                adjustedlevel2bLiquidAssetAmount : Balance
                adjustedlevel2bLiquidAssetAmount =
                    level2bLiquidAssetAmount * 0.5

                adjustedLevel2CapExcessAmount : Balance
                adjustedLevel2CapExcessAmount =
                    max (adjustedlevel2aLiquidAssetAmount + adjustedlevel2bLiquidAssetAmount - 0.6667 * adjustedLevel1LiquidAssetAmount) 0.0

                adjustedlevel2bCapExcessAmount : Balance
                adjustedlevel2bCapExcessAmount =
                    max (adjustedlevel2bLiquidAssetAmount - adjustedLevel2CapExcessAmount - 0.1765 * (adjustedLevel1LiquidAssetAmount + adjustedlevel2aLiquidAssetAmount)) 0.0
            in
            adjustedLevel2CapExcessAmount + adjustedlevel2bCapExcessAmount
    in
    level1LiquidAssetAmount + level2aLiquidAssetAmount + level2bLiquidAssetAmount - max unadjustedExcessHQLAAmount adjustedExcessHQLAAmount


{-| Total Net Cash Outflow Amount is the LCR denominator. It has several components, which are specified as nested functions.
The function takes a function to lookup the counterparty for a flow.
the LocalDate (t) from which to calculate the remaining days until the flows maturity
and a function takes a function to lookup flows for a given date,
-}
totalNetCashOutflowAmount : (Flow -> Counterparty) -> LocalDate -> (LocalDate -> List Flow) -> Balance
totalNetCashOutflowAmount toCounterparty t flowsForDate =
    let
        -- List of the next 30 days from t
        dates : List LocalDate
        dates =
            List.range 1 30 |> List.map (\i -> addDays i t)

        -- Aggregating helpers
        spanDates : (Flow -> Bool) -> List Balance
        spanDates filter =
            dates
                |> List.map flowsForDate
                |> List.map (\flows -> flows |> aggregateDaily filter)

        aggregateSpan : (Flow -> Bool) -> Balance
        aggregateSpan flowFilter =
            spanDates flowFilter |> List.sum

        aggregateDaily : (Flow -> Bool) -> List Flow -> Balance
        aggregateDaily flowFilter flows =
            flows
                |> List.filter flowFilter
                |> List.map .amount
                |> List.sum

        -- Non maturity
        nonMaturityOutflowRules : LocalDate -> List (Rules.Rule Flow)
        nonMaturityOutflowRules date =
            Rules.findAll
                [ "32(a)(1)"
                , "32(a)(2)"
                , "32(a)(3)"
                , "32(a)(4)"
                , "32(a)(5)"
                , "32(b)"
                , "32(c)"
                , "32(d)"
                , "32(e)"
                , "32(f)"
                , "32(i)"
                ]
                (Outflows.outflowRules toCounterparty date)

        nonMaturityInflowRules : LocalDate -> List (Rules.Rule Flow)
        nonMaturityInflowRules date =
            Rules.findAll
                [ "33(b)", "33(g)" ]
                (Inflows.inflowRules toCounterparty date)

        nonMaturityOutflowAmount : Balance
        nonMaturityOutflowAmount =
            aggregateSpan (Rules.isAnyApplicable (nonMaturityOutflowRules t))

        nonMaturityInflowAmount : Balance
        nonMaturityInflowAmount =
            aggregateSpan (Rules.isAnyApplicable (nonMaturityInflowRules t))

        -- Maturity
        maturityMismatchOutflowRules : LocalDate -> List (Rules.Rule Flow)
        maturityMismatchOutflowRules =
            \date ->
                Rules.findAll
                    [ "32(g)(1)"
                    , "32(g)(2)"
                    , "32(g)(3)"
                    , "32(g)(4)"
                    , "32(g)(5)"
                    , "32(g)(6)"
                    , "32(g)(7)"
                    , "32(g)(8)"
                    , "32(g)(9)"
                    , "32(h)(1)"
                    , "32(h)(2)"
                    , "32(h)(5)"
                    , "32(j)"
                    , "32(k)"
                    , "32(l)"
                    ]
                    (Outflows.outflowRules toCounterparty date)

        maturityOutflows : List Balance
        maturityOutflows =
            spanDates (Rules.isAnyApplicable (maturityMismatchOutflowRules t))

        maturityOutflowAmount : Balance
        maturityOutflowAmount =
            maturityOutflows |> List.sum

        maturityMismatchInflowRules : LocalDate -> List (Rules.Rule Flow)
        maturityMismatchInflowRules =
            \date ->
                Rules.findAll [ "33(c)", "33(d)", "33(e)", "33(f)" ] (Inflows.inflowRules toCounterparty date)

        maturityInflows : List Balance
        maturityInflows =
            spanDates (Rules.isAnyApplicable (maturityMismatchInflowRules t))

        maturityInflowAmount : Balance
        maturityInflowAmount =
            maturityInflows |> List.sum

        -- Aggregate it all together
        aggregatedOutflowAmount : Balance
        aggregatedOutflowAmount =
            nonMaturityOutflowAmount + maturityOutflowAmount

        aggregatedInflowAmount : Balance
        aggregatedInflowAmount =
            nonMaturityInflowAmount + maturityInflowAmount

        -- This add-on was added later
        maturityMismatchAddOn : Balance
        maturityMismatchAddOn =
            let
                netCumulativeMaturityOutflowAmount : Balance
                netCumulativeMaturityOutflowAmount =
                    List.map2 Tuple.pair (accumulate 0 maturityOutflows) (accumulate 0 maturityInflows)
                        |> List.map (\( o, i ) -> o - i)
                        |> List.maximum
                        |> Maybe.withDefault 0

                netDay30CumulativeMaturityOutflowAmount : Balance
                netDay30CumulativeMaturityOutflowAmount =
                    List.sum maturityOutflows - List.sum maturityInflows

                maxNext30DaysOfCumulativeMaturityOutflowAmountFloor : Balance
                maxNext30DaysOfCumulativeMaturityOutflowAmountFloor =
                    max 0.0 netCumulativeMaturityOutflowAmount

                netDay30CumulativeMaturityOutflowAmountFloor : Balance
                netDay30CumulativeMaturityOutflowAmountFloor =
                    max 0.0 netDay30CumulativeMaturityOutflowAmount
            in
            maxNext30DaysOfCumulativeMaturityOutflowAmountFloor - netDay30CumulativeMaturityOutflowAmountFloor

        cappedInflows : Balance
        cappedInflows =
            min (0.75 * aggregatedOutflowAmount) aggregatedInflowAmount
    in
    aggregatedOutflowAmount - cappedInflows + maturityMismatchAddOn


isMember : Maybe a -> List a -> Bool
isMember ruleM rules =
    ruleM
        |> Maybe.map (\r -> List.member r rules)
        |> Maybe.withDefault False


isHQLA : (ProductId -> Product) -> Flow -> Bool
isHQLA product flow =
    product flow.productId |> .isHQLA


{-| Helper function to accumulated steps of a sum across a list. This is used in calculating the maturity mismatch add-on.
-}
accumulate : number -> List number -> List number
accumulate starter list =
    let
        ( sum, acc ) =
            List.foldl (\y ( x, xs ) -> ( x + y, (x + y) :: xs )) ( starter, [] ) list
    in
    List.reverse acc
