module Morphir.Sample.Apps.Trader.App exposing (..)


import Morphir.Sample.Apps.Trader.Logic exposing (..)
import Dict exposing (Dict)
import Morphir.SDK.StatefulApp exposing (StatefulApp, statefulApp, cmdNone)
import Morphir.Sample.Apps.Shared.Product as Product
import Morphir.Sample.Apps.BooksAndRecords.App as BookApp
import Morphir.Sample.Apps.BooksAndRecords.Deal as Deal
import Morphir.Sample.Apps.Order.App as OrderApp
import Morphir.Sample.Apps.Order.Order as Order
import Morphir.Sample.Apps.Shared.Price exposing (..)
import Morphir.Sample.Apps.Shared.Quantity exposing (..)

-- Types
type alias App = 
    StatefulApp API RemoteState LocalState Event


type alias API =
    ()


type alias RemoteState =
    { trackMarketPrices : Sub Event
    , getDeals : Product.ID -> List Deal.Deal
    , sell : List Deal.ID -> Cmd Event
    }


type alias LocalState =
    ()


type Event = 
    PriceChanged Product.ID Price


type alias Position =
    { quantity : Quantity
    , value : Deal.Value
    }


-- Functions
app : App
app =
    statefulApp
        { api = api
        , init = init
        , update = update
        , subscriptions = subscriptions
        }


api : RemoteState -> LocalState -> API
api remote local =
    ()


init : RemoteState -> ( LocalState, Cmd Event )
init _ = 
    cmdNone ()


update : RemoteState -> Event -> LocalState -> ( LocalState, Cmd Event )
update remote event local =
    case event of
        PriceChanged productId price -> 
            let
                action = (remote.getDeals productId) |> (processPriceChange price)
                todo = \a -> case a of Sell deals -> remote.sell (deals |> List.map .id)
                command = action |> Maybe.map todo |> Maybe.withDefault Cmd.none
                    
            in
            (local, command)


subscriptions : RemoteState -> LocalState -> Sub Event
subscriptions remote local =
    Debug.todo "On Monday"
