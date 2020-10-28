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

module Morphir.Sample.LCR.Flows exposing (..)

import Date exposing (Date, Interval(..), Unit(..))
import Morphir.Sample.LCR.Basics exposing (..)
import Morphir.Sample.LCR.Counterparty exposing (CounterpartyId)
import Morphir.Sample.LCR.Product exposing (ProductId)
import Morphir.Sample.LCR.MaturityBucket as MB


type alias BusinessDate = Date


type alias ReportingEntity = Entity


type alias Amount = Float

type alias Flow =
    { amount : Amount
    , assetType : AssetCategoryCodes
    , businessDate : BusinessDate
    , collateralClass : AssetCategoryCodes
    , counterpartyId : CounterpartyId
    , currency : Currency
    , fed5GCode : Fed5GCode
    , insured : InsuranceType
    , isTreasuryControl : Bool
    , isUnencumbered : Bool
    , maturityDate : Date
    , effectiveMaturityDate : Date
    , productId : ProductId
    }
