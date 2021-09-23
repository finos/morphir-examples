module Morphir.Example.App.App exposing (..)

import Morphir.Example.App.Forecast exposing (..)
import Morphir.Example.App.Rentals exposing (..)
import Morphir.Example.App.Winds exposing (..)


processRequest : Forecast -> CurrentInventory -> ExistingReservations -> PendingReturns -> RequestedQuantity -> AllowPartials -> Result Reason ReservedQuantity
processRequest forecast inventory reservations returns requestedQuantity allowPartials =
    let
        windCategory : WindCategory
        windCategory =
            categorizeWindForForecast forecast
    in
    decide windCategory forecast.shortForcast inventory reservations returns requestedQuantity allowPartials


categorizeWindForForecast : Forecast -> WindCategory
categorizeWindForForecast forecast =
    let
        windCategory : WindCategory
        windCategory =
            categorizeWind forecast.windSpeed.max
    in
    windCategory
