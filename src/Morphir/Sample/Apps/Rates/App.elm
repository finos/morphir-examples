module Morphir.Sample.Apps.Rates.App exposing (..)

import Dict exposing (Dict)
import Morphir.SDK.Average as Average
import Morphir.SDK.DictExtra as DE
import Morphir.SDK.App exposing (StatelessApp, statelessApp)
import Morphir.Sample.Apps.Shared.Product as Product
import Morphir.Sample.Apps.Shared.Market as Market
import Morphir.Sample.Apps.Shared.Rate exposing (..)

{-| This is where the main Rates application logic is modeled. 

@docs State, map, calculateRates

-}

app : StatelessApp RemoteState State
app =
    statelessApp map


{-| This type is the internal representation of the remote state. 
-}
type alias RemoteState =
    { benchmarkRates : Dict Market.ID Float
    , gcRates : Dict Market.ID Float
    , products : Dict Product.ID Product
    , deals : Dict Product.ID (List Deal)
    }


{-| This type represents the state of the application. The state can be used by other applications
through an anti-corruption layer (see [ACL.elm](ACL.elm) in the same module).
-}
type alias State =
    Dict Product.ID ProductRates


type alias Market =
    { defaultBenchmarkValue : Float
    , gcRate : Float
    }


type alias Product =
    { price : Float
    , marketID : Market.ID
    }


type Side 
    = Borrow 
    | Loan


type alias Deal =
    { side : Side
    , quantity : Int
    , rate : Rate
    }
    

type alias ProductRates =
    { loanRate : Maybe Float
    , borrowRate : Maybe Float
    , spread : Maybe Float
    }


{-| This is an application that doesn't manage it's own state so all it does is map external states
to a combined state through some aggregation.
-}
map : RemoteState -> State
map state =
    state.deals
        |> DE.filterMap
            (\productID deals ->
                DE.getAndThen state.products productID
                    (\product ->
                        DE.getAndThen state.benchmarkRates product.marketID
                            (\benchmarkRate ->
                                DE.getMap state.gcRates product.marketID
                                    (\gcRate ->
                                        calculateRates benchmarkRate gcRate product.price deals
                                    )
                            )
                    )
            )


{-| This function encapsulates the core rate calculation. It takes a list of deals and 
returns all the calculated rates for those deals. It takes some additional reference data 
that is required for the calculation.
-}
calculateRates : Float -> Float -> Float -> List Deal -> ProductRates
calculateRates benchmarkRate gcRate price deals =
    let
        -- The various rate types that a deal can have are not comparable so before
        -- the actual calculation we normalize the rates to be comparable.
        normalizedDealRate =
            \deal ->
                case deal.rate of
                    Fee fee ->
                        fee

                    Rebate rebate ->
                        benchmarkRate - rebate

                    GC ->
                        gcRate    

        -- The deal value is calculated by simply multiplying the quantity withe the price.
        dealValue =
            \deal ->
                price * (toFloat deal.quantity)

        -- Calculate the weighted average rate of borrows
        borrowRate =
            deals
                |> List.filter (\d -> d.side == Borrow)
                |> Average.weighted dealValue normalizedDealRate


        -- Calculate the weighted average rate of loans
        loanRate =
            deals
                |> List.filter (\d -> d.side == Loan)
                |> Average.weighted dealValue normalizedDealRate

        -- Calculate the spread
        spread =
            Maybe.map2 (-)
                loanRate
                borrowRate
    in
    ProductRates loanRate borrowRate spread
