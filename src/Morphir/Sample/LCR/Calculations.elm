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

module Morphir.Sample.LCR.Calculations exposing (..)


import Morphir.SDK.Basics exposing (Decimal, max, min)
import Date exposing (Date, Interval(..), Unit(..))
import Morphir.Sample.LCR.Basics exposing (..)
import Morphir.Sample.LCR.Flows exposing (..)
import Morphir.Sample.LCR.Counterparty exposing (..)
import Morphir.Sample.LCR.Inflows as Inflows
import Morphir.Sample.LCR.Outflows as Outflows
import Morphir.Sample.LCR.Product exposing (..)
import Morphir.Sample.LCR.Rules as Rules

-- Forumulas from the OCC: https://www.occ.gov/news-issuances/bulletins/2014/bulletin-2014-51.html
--  https://www.occ.gov/topics/supervision-and-examination/capital-markets/balance-sheet-management/liquidity/Basel-III-LCR-Formulas.pdf
--  https://www.govinfo.gov/content/pkg/FR-2014-10-10/pdf/2014-22520.pdf (page 61477)

{-| This module is broken up into the same structure as the example formulas in the referenced PDF. -}

isMember : Maybe a -> List a -> Bool
isMember ruleM rules =
    ruleM
    |> Maybe.map (\r -> List.member r rules)
    |> Maybe.withDefault False

isHQLA : (ProductId -> Product) -> Flow -> Bool
isHQLA product flow =
    (product flow.productId) |> .isHQLA


{-| Helper function to accumulated steps of a sum across a list. This is used in calculating the maturity mismatch add-on. -}
accumulate starter list =
    let 
        (sum, acc) =
            List.foldl ( \y (x,xs) -> (x+y, (x+y) :: xs)) (starter, []) list
    in
        List.reverse acc


{-| HQLA Amount is the LCR numerator. It has several components, which are specified as nested functions. -}
hqlaAmount : (ProductId -> Product) -> List Flow -> Decimal -> Decimal
hqlaAmount product t0Flows reserveBalanceRequirement =
    let
        level1LiquidAssetsThatAreEligibleHQLA =
            t0Flows
                |> List.filter (\flow -> flow.assetType == Level1Assets && isHQLA product flow) 
                |> List.map .amount
                |> List.sum

        level1LiquidAssetAmount = 
            level1LiquidAssetsThatAreEligibleHQLA - reserveBalanceRequirement


        level2aLiquidAssetsThatAreEligibleHQLA =
            t0Flows
                |> List.filter (\flow -> flow.assetType == Level2aAssets && isHQLA product flow)
                |> List.map .amount
                |> List.sum

        level2aLiquidAssetAmount = 
            0.85 * level2aLiquidAssetsThatAreEligibleHQLA


        level2bLiquidAssetsThatAreEligibleHQLA =
            t0Flows 
                |> List.filter (\flow -> flow.assetType == Level2bAssets && isHQLA product flow) 
                |> List.map .amount
                |> List.sum

        level2bLiquidAssetAmount = 
            0.50 * level2bLiquidAssetsThatAreEligibleHQLA


        unadjustedExcessHQLAAmount = 
            let
                level2CapExcessAmount = 
                    max (level2aLiquidAssetAmount + level2bLiquidAssetAmount - 0.6667 * level1LiquidAssetAmount) 0.0

                level2bCapExcessAmount = 
                    max (level2bLiquidAssetAmount - level2CapExcessAmount - 0.1765 * (level1LiquidAssetAmount + level2aLiquidAssetAmount)) 0.0
            in
            level2CapExcessAmount + level2bCapExcessAmount


        adjustedExcessHQLAAmount = 
            let
                adjustedLevel1LiquidAssetAmount = level1LiquidAssetAmount

                adjustedlevel2aLiquidAssetAmount = level2aLiquidAssetAmount * 0.85

                adjustedlevel2bLiquidAssetAmount = level2bLiquidAssetAmount * 0.50

                adjustedLevel2CapExcessAmount = 
                    max (adjustedlevel2aLiquidAssetAmount + adjustedlevel2bLiquidAssetAmount - 0.6667 * adjustedLevel1LiquidAssetAmount) 0.0

                adjustedlevel2bCapExcessAmount =
                    max (adjustedlevel2bLiquidAssetAmount - adjustedLevel2CapExcessAmount - 0.1765 * (adjustedLevel1LiquidAssetAmount + adjustedlevel2aLiquidAssetAmount)) 0.0
            in
                adjustedLevel2CapExcessAmount + adjustedlevel2bCapExcessAmount
    in
    level1LiquidAssetAmount + level2aLiquidAssetAmount + level2bLiquidAssetAmount - (max unadjustedExcessHQLAAmount adjustedExcessHQLAAmount)


{-| Total Net Cash Outflow Amount is the LCR denominator. It has several components, which are specified as nested functions. 
    The function takes a function to lookup the counterparty for a flow.
    the date (t) from which to calculate the remaining days until the flows maturity
    and a function takes a function to lookup flows for a given date, 
-}
totalNetCashOutflowAmount : (Flow -> Counterparty) -> Date -> (Date -> List Flow) -> Decimal
totalNetCashOutflowAmount toCounterparty t flowsForDate =
    let
        -- List of the next 30 days from t
        dates = 
            List.range 1 30 |> List.map (\i -> Date.add Days i t)

        -- Aggregating helpers
        spanDates = \filter ->
            dates
                |> List.map flowsForDate
                |> List.map (\flows -> flows |> aggregateDaily filter)

        aggregateSpan = \filter ->
            spanDates filter |> List.sum

        aggregateDaily = \filter flows ->
            flows
                |> List.filter filter
                |> List.map .amount
                |> List.sum

        -- Non maturity
        nonMaturityOutflowRules = \date ->
            Rules.findAll
                [ "32(a)(1)", "32(a)(2)", "32(a)(3)", "32(a)(4)", "32(a)(5)"
                , "32(b)", "32(c)", "32(d)", "32(e)", "32(f)", "32(i)"
                ]
                (Outflows.outflowRules toCounterparty date)
        
        nonMaturityInflowRules =  \date ->
            Rules.findAll
                [ "33(b)", "33(g)" ]
                (Inflows.inflowRules toCounterparty date)


        nonMaturityOutflowAmount =
            aggregateSpan (Rules.isAnyApplicable (nonMaturityOutflowRules t))
        
        nonMaturityInflowAmount = 
            aggregateSpan (Rules.isAnyApplicable (nonMaturityInflowRules t))

        -- Maturity
        maturityMismatchOutflowRules = \date ->
            Rules.findAll 
                ["32(g)(1)", "32(g)(2)", "32(g)(3)", "32(g)(4)", "32(g)(5)", "32(g)(6)", "32(g)(7)", "32(g)(8)", "32(g)(9)"
                ,"32(h)(1)", "32(h)(2)", "32(h)(5)", "32(j)", "32(k)", "32(l)"
                ] (Outflows.outflowRules toCounterparty date)

        maturityOutflows = 
            spanDates (Rules.isAnyApplicable (maturityMismatchOutflowRules t))

        maturityOutflowAmount = 
            maturityOutflows |> List.sum

        maturityMismatchInflowRules = \date ->
            Rules.findAll [ "33(c)", "33(d)", "33(e)", "33(f)" ] (Inflows.inflowRules toCounterparty date)

        maturityInflows = 
            spanDates (Rules.isAnyApplicable (maturityMismatchInflowRules t))

        maturityInflowAmount = 
            maturityInflows |> List.sum

        -- Aggregate it all together
        aggregatedOutflowAmount = 
            nonMaturityOutflowAmount + maturityOutflowAmount
        
        aggregatedInflowAmount = 
            nonMaturityInflowAmount + maturityInflowAmount
      
        -- This add-on was added later
        maturityMismatchAddOn = 
            let
                netCumulativeMaturityOutflowAmount = 
                    (List.map2 Tuple.pair (accumulate 0 maturityOutflows) (accumulate 0 maturityInflows))
                        |> List.map (\(o, i) -> o - i)
                        |> List.maximum
                        |> Maybe.withDefault 0


                netDay30CumulativeMaturityOutflowAmount = 
                    (List.sum maturityOutflows) - (List.sum maturityInflows)
                
                maxNext30DaysOfCumulativeMaturityOutflowAmountFloor = 
                    max 0.0 netCumulativeMaturityOutflowAmount
                
                netDay30CumulativeMaturityOutflowAmountFloor = 
                    max 0.0 netDay30CumulativeMaturityOutflowAmount
            in
            maxNext30DaysOfCumulativeMaturityOutflowAmountFloor - netDay30CumulativeMaturityOutflowAmountFloor

        cappedInflows =
            min (0.75 * aggregatedOutflowAmount) aggregatedInflowAmount
    in
    aggregatedOutflowAmount - cappedInflows + maturityMismatchAddOn


{-| Woohoo.  Here's the LCR. -}
lcr : (Flow -> Counterparty) -> (ProductId -> Product) -> Date -> (Date -> List Flow) -> Decimal -> Decimal
lcr toCounterparty product t flowsForDate reserveBalanceRequirement = 
    let
        hqla                = hqlaAmount product (flowsForDate t) reserveBalanceRequirement
        totalNetCashOutflow = totalNetCashOutflowAmount toCounterparty t flowsForDate
    in
        hqla / totalNetCashOutflow
