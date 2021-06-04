module Morphir.Example.App.App exposing (..)


request : State a -> Bool -> Int -> TimeUnit -> Response
request state allowPartial requestedAmount startTime =
    let
        available : Int
        available =
            availableForRent state startTime
    in
    if available < requestedAmount then
        if allowPartial then
            Reserved (min available requestedAmount)

        else
            Rejected

    else
        Reserved requestedAmount


availableForRent : State a -> TimeUnit -> Int
availableForRent state byWhen =
    let
        inventory =
            currentInventory state

        estimatedReserved =
            toFloat (currentlyReserved state) * state.averageNoShows |> floor

        probablyReturns =
            toFloat (scheduledReturns state byWhen) * state.averageLateReturnRatio |> floor
    in
    inventory - estimatedReserved + probablyReturns


currentInventory : State a -> Int
currentInventory state =
    state.inventory
        --|> List.filter (\item -> item.location == OnSite)
        |> List.length


currentlyReserved : State a -> Int
currentlyReserved state =
    state.reservations
        |> List.length


scheduledReturns : State a -> TimeUnit -> Int
scheduledReturns state byWhen =
    state.reservations
        |> List.filter (\item -> item.endTime <= byWhen)
        |> List.length


type alias State a =
    { inventory : List a
    , reservations : List Reservation
    , averageNoShows : Float
    , averageLateReturnRatio : Float
    }


type alias Reservation =
    { quantity : Int
    , startTime : TimeUnit
    , endTime : TimeUnit
    }


type Response
    = Rejected
    | Reserved Int


type alias TimeUnit =
    Int


type Location
    = OnSite
    | PendingDelivery
    | BackOrder
