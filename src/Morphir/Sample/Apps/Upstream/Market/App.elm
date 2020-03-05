module Morphir.Sample.Apps.Upstream.Market.App exposing (..)

{-| This is a stub for an external Market app. Normally this would
live in an external library but it's included for simplicity. The 
application's API is exposed here and in the external library the 
implementation would be included as well.
-}

import Dict exposing (Dict)
import Morphir.SDK.App exposing (StatefulApp, statefulApp, cmdNone)
import Morphir.Sample.Apps.Shared.Market as Market
import Morphir.Sample.Apps.Shared.Product as Product
import Morphir.Sample.Apps.Shared.Price exposing(Price)


type alias Market =
    { benchmarkRate : Float
    , gcRate : Float
    }


type alias State =
    Dict Market.ID Market


-- Types
type alias App = 
    StatefulApp API RemoteState LocalState Event


type alias API =
    {}


type alias RemoteState =
    ()


type alias LocalState =
    Dict Market.ID Market


type Event = 
    Event
