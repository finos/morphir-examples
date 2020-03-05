module Morphir.Sample.LCR.Basics exposing 
    ( AssetCategoryCodes(..)
    , InsuranceType(..)
    , Entity
    , Currency
    , Fed5GCode
    )


import Date exposing (Date, Unit(..))
import Time exposing (Month(..))

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
