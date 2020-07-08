module Morphir.Sample.Apps.Order.App exposing 
    ( App
    , API
    , Event
    , StateFault
    , LocalState
    , RemoteState
    )


import Dict exposing (Dict)
import Morphir.SDK.StatefulApp exposing (StatefulApp, statefulApp, cmdNone)
import Morphir.Sample.Apps.Shared.Product as Product
import Morphir.Sample.Apps.BooksAndRecords.Deal as Deal
import Morphir.Sample.Apps.Order.Order as Order
import Morphir.Sample.Apps.Shared.Price exposing (..)
import Morphir.Sample.Apps.Shared.Quantity exposing (..)

-- Types
type alias App = 
    StatefulApp API RemoteState LocalState Event


type alias API =
    { buy : Order.BuyRequest -> Result StateFault Event
    , sell : Order.SellRequest -> Result StateFault Event
    }


type alias RemoteState =
    { bookBuy : Order.ID -> Product.ID -> Price -> Int -> Cmd Event
    , bookSell : Order.ID -> Price -> Cmd Event
    , getDeal : Order.ID -> Maybe Deal.Deal
    , getMarketPrice : Product.ID -> Maybe Price
    , getStartOfDayPosition : Product.ID -> Maybe Quantity
    }


type alias LocalState =
    { buys : Dict Order.ID BuyRecord
    , sells : Dict Order.ID SellRecord
    }


type Event 
    = BuyProcessed Order.BuyRequest Order.BuyResponse
    | SellProcessed Order.SellRequest Order.SellResponse


type StateFault
    = DuplicateRequest Order.ID
    | DealNotFound Order.ID
    | MissingPrice Order.ID


type alias BuyRecord = 
    { request : Order.BuyRequest
    , response : Order.BuyResponse
    }


type alias SellRecord = 
    { request : Order.SellRequest
    , response : Order.SellResponse
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
    { buy = (apiBuy remote local)
    , sell = (apiSell remote local)
    }


init : RemoteState -> ( LocalState, Cmd Event )
init _ = 
    cmdNone 
        { buys = Dict.empty
        , sells = Dict.empty
        }


update : RemoteState -> Event -> LocalState -> ( LocalState, Cmd Event )
update remote event local =
    case event of
        -- Update our local state with the new buy request/response
        BuyProcessed request response ->
            let
                newRecord = BuyRecord request response
                ordersUpdated = Dict.insert request.id newRecord local.buys
                dealCommand =
                    case response of
                        -- If we accepted the buy, send it over to booking
                        Order.BuyAccepted orderID productID price quantity -> 
                            remote.bookBuy orderID productID price quantity
                        _ ->
                            Cmd.none
            in
            ({ local | buys = ordersUpdated }, dealCommand)

        -- Update our local state with the new sell request/response
        SellProcessed request response ->
            let
                newRecord = SellRecord request response
                ordersUpdated = Dict.insert request.id newRecord local.sells
                dealCommand =
                    case response of
                        Order.SellAccepted orderID price -> 
                            -- If the sell was accepted, let booking know to close the deal
                            remote.bookSell orderID price
            in
            ({ local | sells = ordersUpdated }, dealCommand)


subscriptions remote local =
    Sub.none


-- Extras
apiBuy : RemoteState -> LocalState -> Order.BuyRequest -> Result StateFault Event
apiBuy remote local request =
        let
            currentMarketPrice = 
                marketPrice remote request.product

            currentAvailility = 
                let 
                    sodp = 
                        (startOfDayPosition remote request.product)
                    buyResponses =
                        local.buys |> Dict.values |> List.map .response
                in 
                Order.availability sodp buyResponses
                
            process = \price ->
                Order.processBuy request price currentAvailility
        in
        currentMarketPrice 
            |> Maybe.map process
            |> Maybe.map (\result -> Ok (BuyProcessed request result))
            |> Maybe.withDefault (Err (MissingPrice request.id))


apiSell : RemoteState -> LocalState -> Order.SellRequest -> Result StateFault Event
apiSell remote local request =
    let
        maybeDeal = remote.getDeal request.id
    in
        case maybeDeal of
            Just deal -> 
                case (marketPrice remote deal.product) of 
                    Just price -> 
                        Ok (SellProcessed request (Order.processSell request price))
                    Nothing -> 
                        Err (MissingPrice request.id)
            Nothing ->
                Err (DealNotFound request.id)


marketPrice : RemoteState -> Product.ID -> Maybe Price
marketPrice remote productId =
    remote.getMarketPrice productId


startOfDayPosition : RemoteState -> Product.ID -> Quantity
startOfDayPosition remote productId =
    remote.getStartOfDayPosition productId |> Maybe.withDefault 0

