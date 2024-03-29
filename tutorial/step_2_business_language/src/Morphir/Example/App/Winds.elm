module Morphir.Example.App.Winds exposing (..)

{-| Categorizes Forecast wind speeds into categories that are meaningful to the rental business.
-}


categorizeWind : Int -> WindCategory
categorizeWind windSpeed =
    if windSpeed < 10 then
        Calm

    else if windSpeed < 20 then
        Windy

    else if windSpeed < 30 then
        HighWinds

    else
        DangerousWinds


type WindCategory
    = Calm
    | Windy
    | HighWinds
    | DangerousWinds
