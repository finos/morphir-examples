module Morphir.Example.App.Winds exposing (..)

import Morphir.Example.App.Forecast exposing (..)


type WindCategory
    = Calm
    | Windy
    | DangerousWinds


categorizeWind : MPH -> WindCategory
categorizeWind windSpeed =
    if windSpeed < 15 then
        Calm

    else if windSpeed < 30 then
        Windy

    else
        DangerousWinds


categorizeWindForForecast : Forecast -> WindCategory
categorizeWindForForecast forecast =
    let
        windCategory : WindCategory
        windCategory =
            categorizeWind forecast.windSpeed.max
    in
    windCategory
