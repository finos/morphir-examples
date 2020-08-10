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

module Morphir.Sample.Apps.Rates.ACL exposing (..)

{-| This module is our anti-corruption layer that translates external states into an
internal representation. 

@docs ExternalState, subscribe

-}

import Dict exposing (Dict)
import Morphir.Sample.Apps.Rates.App exposing (..)
import Morphir.Sample.Apps.Upstream.Trading.App as TradingApp
import Morphir.Sample.Apps.Upstream.Product.App as ProductApp
import Morphir.Sample.Apps.Upstream.Market.App as MarketApp

{-| This function describes the mapping from various remote systems to the internal
representation. The function can have any number of inputs each representing an remote
system that we depend on.
-}
map : TradingApp.State -> ProductApp.LocalState -> MarketApp.LocalState -> RemoteState
map tradingState productState marketState =
    let
        -- Utility function to map remote deal shape to the internal.
        -- The remote representation doesn't have a side so we pass that in.
        mapDeal =
            \theDeal side ->
                { side = side
                , quantity = theDeal.quantity
                , rate = theDeal.rate
                }

        -- Utility function to map a dictionary of deals keyed by deal ID to a dictionary keyed by product ID
        -- where each value is a list of deals. In other words it groups deals by product.
        mapDeals =
            \theDeals side ->
                theDeals
                    |> Dict.toList
                    |> List.foldl
                        (\( dealID, deal ) soFar ->
                            soFar
                                |> Dict.update deal.productID
                                    (\maybeProductDeals ->
                                        case maybeProductDeals of
                                            Nothing ->
                                                Just [ mapDeal deal side ]

                                            Just productDeals ->
                                                Just (mapDeal deal side :: productDeals)
                                    )
                        )
                        Dict.empty

        -- The external representation stores borrow and loans in separate collections. We union them here using 
        -- side to differentiate later.
        deals =
            Dict.union
                (mapDeals tradingState.borrows Borrow)
                (mapDeals tradingState.loans Loan)

        -- Map only the products that we have a deal for.
        products =
            productState
                |> Dict.filter
                    (\productID _ ->
                        deals
                            |> Dict.keys
                            |> List.member productID
                    )
                |> Dict.map
                    (\productID product ->
                        { price = product.price
                        , marketID = product.market
                        }
                    )

        -- Collect all the market ids for our products.
        markets =
            products
                |> Dict.values
                |> List.map .marketID            

        -- Map benchmark rates for the markets we have products for.
        benchmarkRates =
            marketState
                |> Dict.filter
                    (\marketID _ ->
                        markets
                            |> List.member marketID
                    )
                |> Dict.map
                    (\_ market ->
                        market.benchmarkRate
                    )    

        -- Map GC rates for the markets we have products for.
        gcRates =
            marketState
                |> Dict.filter
                    (\marketID _ ->
                        markets
                            |> List.member marketID
                    )
                |> Dict.map
                    (\_ market ->
                        market.gcRate
                    )    
    in
    RemoteState
        benchmarkRates
        gcRates
        products
        deals