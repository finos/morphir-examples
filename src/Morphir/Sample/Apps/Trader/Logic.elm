{-
Copyright 2020 Morgan Stanley

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-}

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


