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



module Company.Operations.BooksAndRecords exposing (..)

import Morphir.SDK.StatefulApp exposing (StatefulApp)


type alias ID =
    String


type alias ProductID =
    String


type alias Price =
    Float


type alias Quantity =
    Int


type alias Deal =
    { id : ID
    , product : ProductID
    , price : Price
    , quantity : Quantity
    }


type DealCmd
    = OpenDeal ID ProductID Price Quantity
    | CloseDeal ID


type DealEvent
    = DealOpened ID ProductID Price Quantity
    | DealClosed ID
    | InvalidQuantity ID Quantity
    | InvalidPrice ID Price
    | DuplicateDeal ID
    | DealNotFound ID


type alias App =
    StatefulApp ID DealCmd Deal DealEvent


app : App
app =
    StatefulApp logic


logic : ID -> Maybe Deal -> DealCmd -> ( ID, Maybe Deal, DealEvent )
logic dealId deal dealCmd =
    case deal of
        Just _ ->
            case dealCmd of
                CloseDeal _ ->
                    ( dealId, Nothing, DealClosed dealId )

                OpenDeal _ _ _ _ ->
                    ( dealId, deal, DuplicateDeal dealId )

        Nothing ->
            case dealCmd of
                OpenDeal id productId price qty ->
                    if price < 0 then
                        ( dealId, deal, InvalidPrice id price )

                    else if qty < 0 then
                        ( dealId, deal, InvalidQuantity id qty )

                    else
                        ( dealId
                        , Deal id productId price qty |> Just
                        , DealOpened id productId price qty
                        )

                CloseDeal _ ->
                    ( dealId, deal, DealNotFound dealId )
