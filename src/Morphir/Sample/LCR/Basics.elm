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

module Morphir.Sample.LCR.Basics exposing 
    ( AssetCategoryCodes(..)
    , InsuranceType(..)
    , Entity
    , Currency
    , Balance
    , Ratio
    , Fed5GCode
    )

{-| Asset categories apply to the flows and are specified in the spec.  
    There are a bunch of them, but we're only concerned with these three in this example .
-}
type AssetCategoryCodes
    = Level1Assets
    | Level2aAssets
    | Level2bAssets


{-| Insurance type as specified in the spec.
    There are a bunch of them, but we're only concerned with FDIC in this example .
-}
type InsuranceType
    = FDIC
    | Uninsured


type alias Entity = String


type alias Currency = String


type alias Balance = Float


type alias Ratio = Float


type alias Fed5GCode = String


{-| A currency isn't always itself in 5G.
-}
fed5GCurrency : Currency -> Currency
fed5GCurrency currency = 
    if
        List.member currency ["USD", "EUR", "GBP", "CHF", "JPY", "AUD", "CAD"]
    then
        currency
    else 
        "USD"
