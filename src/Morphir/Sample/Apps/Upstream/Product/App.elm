module Morphir.Sample.Apps.Upstream.Product.App exposing (..)


import Dict exposing (Dict)
import Morphir.SDK.App exposing (StatefulApp)
import Morphir.Sample.Apps.Shared.Market as Market
import Morphir.Sample.Apps.Shared.Price exposing (Price)
import Morphir.Sample.Apps.Shared.Product as Product
import Morphir.Sample.Apps.Shared.Quantity exposing (..)


{-| This is a stub for an external Product app. Normally this would
live in an external library but it's included for simplicity. The 
application's API is exposed here and in the external library the 
implementation would be included as well.
-}


type alias ProductState =
    { market : Market.ID
    , price : Price
    , startOfDayPosition : Quantity
    }


-- Types
type alias App = 
    StatefulApp API RemoteState LocalState Event


type alias API =
    {}


type alias RemoteState =
    ()


type alias LocalState =
    Dict Product.ID ProductState


type Event = 
    Event
