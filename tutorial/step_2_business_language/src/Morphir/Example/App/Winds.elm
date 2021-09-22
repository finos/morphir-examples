module Morphir.Example.App.Winds exposing (..)

import Morphir.Example.App.Forecast exposing (..)


type WindCategory
    = Calm
    | Windy
    | HighWinds
    | DangerousWinds


categorizeWind : MPH -> WindCategory
categorizeWind windSpeed =
    if windSpeed < 10 then
        Calm

    else if windSpeed < 20 then
        HighWinds

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
