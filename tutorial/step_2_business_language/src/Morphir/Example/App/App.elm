module Morphir.Example.App.App exposing (..)

import Morphir.Example.App.Analytics as Analytics
import Morphir.Example.App.BusinessTerms exposing (..)
import Morphir.Example.App.Forecast exposing (..)
import Morphir.Example.App.Rentals exposing (..)
import Morphir.Example.App.Winds exposing (..)


processRequest : Forecast -> CurrentInventory -> ExistingReservations -> ReservationQuantity -> CanceledQuantity -> PendingReturns -> RequestedQuantity -> AllowPartials -> Result Reason ReservationQuantity
processRequest forecast inventory reservations reservationQuantity canceledQuantity returns requestedQuantity allowPartials =
    let
        windCategory : WindCategory
        windCategory =
            categorizeWindForForecast forecast

        probableReservations : ReservationQuantity -> ProbableReservations
        probableReservations =
            Analytics.probableReservations reservationQuantity canceledQuantity
    in
    decide windCategory forecast.shortForcast inventory (probableReservations reservations) returns requestedQuantity allowPartials


categorizeWindForForecast : Forecast -> WindCategory
categorizeWindForForecast forecast =
    let
        windCategory : WindCategory
        windCategory =
            categorizeWind forecast.windSpeed.max
    in
    windCategory
