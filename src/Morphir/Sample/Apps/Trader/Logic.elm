module Morphir.Sample.Apps.Trader.Logic exposing (..)


import Dict exposing (Dict)
import Morphir.Sample.Apps.Shared.Product as Product
import Morphir.Sample.Apps.BooksAndRecords.Deal exposing (Deal)
import Morphir.Sample.Apps.Shared.Price exposing (..)


type Action
    = Sell (List Deal)


processPriceChange : Price -> List Deal -> Maybe Action
processPriceChange marketPrice deals =
    let
        shouldSell = 
            \deal -> 
                deal.price > (marketPrice * 1.25) -- Sell for profit
                || deal.price < (marketPrice * 0.75) -- Sell to cut loss, presumably with a corresponding hedge

        respond = \result -> 
            if List.isEmpty result then 
                Nothing 
            else
                Just (Sell result)
    in
    deals |> List.filter shouldSell |> respond


