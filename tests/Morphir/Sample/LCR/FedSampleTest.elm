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

module Morphir.Sample.LCR.FedSampleTest exposing (..)

{-| Test based on LCR examples.
-}


import Expect
import Test exposing (Test, test, describe)

import SDK.MaybeExtra exposing (..)
import SDK.ListExtra exposing (..)
import Sample.LCR.Basics exposing (..)
import Sample.LCR.Calculations exposing (..)
import Sample.LCR.Flows exposing (..)
import Sample.LCR.Counterparty exposing (..)
import Sample.LCR.Inflows as Inflows
import Sample.LCR.Outflows as Outflows
import Sample.LCR.Product exposing (..)
import Sample.LCR.Rules as Rules
import Date exposing (Interval(..), Unit(..))
import Time exposing (Month(..))

-- Test based on sample from:
-- https://www.govinfo.gov/content/pkg/FR-2014-10-10/pdf/2014-22520.pdf (page 61477)

paperSample : Test
paperSample =
  let
    t0  = Date.fromCalendarDate 2019 Time.Sep 19
    t1  = Date.add Days 1 t0
    cptyId = "cp1"
    productId = "ABCDEFGHI"

    rule32bOutflows =
      [{ amount = 300, assetType = Level1Assets, businessDate = t1, collateralClass = Level1Assets, counterpartyId = cptyId, currency = "USD"
      , fed5GCode = "O.W.1", insured = FDIC, isTreasuryControl = True, isUnencumbered = True, maturityDate = t1
      , effectiveMaturityDate = t1, productId = productId
      }]

    rule32lOutflows = 
      [100,20,10,15,20,0,0,10,15,25,35,10,0,0,5,15,5,10,15,0,0,20,20,5,40,8,0,0,5,2]
        |> List.indexedMap ( \index num -> (num, Date.add Days index t1) )
        |> List.map
          ( \(num, date) -> 
            { amount = num, assetType = Level1Assets, businessDate = date, collateralClass = Level1Assets, counterpartyId = cptyId, currency = "USD"
            , fed5GCode = "O.O.22", insured = FDIC, isTreasuryControl = True, isUnencumbered = True, maturityDate = date
            , effectiveMaturityDate = date, productId = productId
            }
          )

    rule33eInflows = 
      [90,5,5,20,15,0,0,8,7,20,5,15,0,0,5,5,5,5,20,0,0,45,40,20,5,125,0,0,10,5]
        |> List.indexedMap ( \index num -> (num, Date.add Days index t1) )
        |> List.map
          ( \(num, date) -> 
            { amount = num, assetType = Level2aAssets, businessDate = date, collateralClass = Level1Assets, counterpartyId = cptyId, currency = "USD"
            , fed5GCode = "I.O.6", insured = FDIC, isTreasuryControl = True, isUnencumbered = True, maturityDate = date
            , effectiveMaturityDate = date, productId = productId
            }
          )

    rule32bInflows =
      [{ amount = 100, assetType = Level2aAssets, businessDate = t1, collateralClass = Level1Assets, counterpartyId = cptyId, currency = "USD"
      , fed5GCode = "1.O.7", insured = FDIC, isTreasuryControl = True, isUnencumbered = True, maturityDate = t1
      , effectiveMaturityDate = t1, productId = productId
      }]


    -- Data resolution / Database mimic
    dateToFlows = \date ->
      let
        index = Date.diff Days t1 date
      in 
        List.append (rule32lOutflows |> get index |> toList) (rule33eInflows |> get index |> toList) 
          |> List.append (rule32bOutflows |> get index |> toList)
          |> List.append (rule32bInflows |> get index |> toList)

    state = 
      { countepartyDB = \flow -> { counterpartyId = flow.counterpartyId, counterpartyType = Bank }
      , productDB = \pid -> { productId = productId, productType = Cash, isHQLA = True }
      }

  in
  describe "Fed Sample Calculations" 
      [ test "Outflow Sum"              <| \_ -> Expect.equal 410 (rule32lOutflows |> List.map .amount |> List.sum)
      , test "Inflow Sum"               <| \_ -> Expect.equal 480 (rule33eInflows |> List.map .amount |> List.sum)
      , test "Total Net Cash Outflows"  <| \_ -> Expect.within (Expect.Absolute 0.01) 262.5 (totalNetCashOutflowAmount state.countepartyDB t1 dateToFlows)
      , test "LCR Calc"                 <| \_ -> Expect.within (Expect.Absolute 0.01) 2.14 (lcr state.countepartyDB state.productDB t1 dateToFlows 0)
      ]
