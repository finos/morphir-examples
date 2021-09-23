module Morphir.Example.App.Rentals exposing (..)

import Morphir.Example.App.Forecast exposing (..)
import Morphir.Example.App.Winds exposing (..)


type alias CurrentInventory =
    Int


type alias ExistingReservations =
    Int


type alias PendingReturns =
    Int


type alias RequestedQuantity =
    Int


type alias ReservedQuantity =
    Int


type alias Availability =
    Int


type alias AllowPartials =
    Bool


type Reason
    = InsufficientAvailability
    | ClosedDueToConditions


type ExpertiseLevel
    = Novice
    | Intermediate
    | Expert


decide : WindCategory -> ForecastDetail -> CurrentInventory -> ExistingReservations -> PendingReturns -> RequestedQuantity -> AllowPartials -> Result Reason ReservedQuantity
decide windCategory forecastDetail inventory reservations returns requestedQuantity allowPartials =
    let
        isClosed : Bool
        isClosed =
            case ( windCategory, forecastDetail ) of
                ( DangerousWinds, _ ) ->
                    True

                ( _, Thunderstorms ) ->
                    True

                _ ->
                    False

        availability : Availability
        availability =
            inventory - reservations + returns
    in
    if isClosed then
        Err ClosedDueToConditions

    else if requestedQuantity <= availability then
        Ok requestedQuantity

    else if allowPartials then
        Ok availability

    else
        Err InsufficientAvailability
