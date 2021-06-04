module Morphir.Example.App.Rentals exposing (..)


request : Int -> Int -> Int -> Int -> Bool -> Result String Int
request inventory reservations returns requestedAmount allowPartial =
    let
        availability : Int
        availability =
            inventory - reservations + returns
    in
        if requestedAmount <= availability then
            Ok requestedAmount

        else
            if allowPartial && availability > 0 then
                Ok availability
            else
                Err "Insufficient inventory"

