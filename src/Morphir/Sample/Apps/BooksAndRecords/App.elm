module Morphir.Sample.Apps.BooksAndRecords.App exposing (..)


import Dict exposing (Dict)
import Morphir.SDK.App exposing (StatefulApp, statefulApp, cmdNone)
import Morphir.Sample.Apps.Shared.Product as Product
import Morphir.Sample.Apps.Shared.Price exposing (..)
import Morphir.Sample.Apps.BooksAndRecords.Deal exposing (..)


type alias App = 
    StatefulApp API RemoteState LocalState Event


type alias API =
    { openDeal : ID -> Product.ID -> Price -> Quantity -> Result OpenRequestFault Event
    , closeDeal : ID -> Result CloseRequestFault Event
    }


type alias RemoteState =
    ()


type alias LocalState = 
    Dict ID Deal


type Event
    = DealOpened ID Product.ID Price Quantity
    | DealClosed ID


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
    { openDeal = \dealID productID price quantity ->
        if price < 0 then
            Err (InvalidPrice dealID price)
        else if price < 0 then
            Err (InvalidQuantity dealID quantity)
        else if Dict.member dealID local then
            Err (DuplicateDeal dealID)
        else
            Ok (DealOpened dealID productID price quantity)

    , closeDeal = \dealID ->
        case local |> Dict.get dealID of
            Nothing ->
                Err (DealNotFound dealID)

            Just _ ->
                Ok (DealClosed dealID)
    }


init : RemoteState -> ( LocalState, Cmd Event )
init _ = 
    cmdNone Dict.empty


update : RemoteState -> Event -> LocalState -> ( LocalState, Cmd Event )
update remote event local =
    case event of
        DealOpened dealID productID price quantity ->
            ( ( local |> Dict.insert dealID (Deal dealID productID price quantity) ), Cmd.none)

        DealClosed dealID ->
            cmdNone ( local |> Dict.remove dealID )


subscriptions remote local =
    Sub.none


-- Extra types used in the API and state


type OpenRequestFault
    = InvalidQuantity ID Int
    | InvalidPrice ID Price
    | DuplicateDeal ID


type CloseRequestFault
    = DealNotFound ID
