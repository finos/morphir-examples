module Morphir.Sample.Apps.Approvals.LocateList.ACL exposing (..)


import Morphir.SDK.App exposing (sendCommand, subscribe)
import Morphir.SDK.DictExtra as DE
import Morphir.Sample.Apps.Shared.Product as Product
import Morphir.Sample.Apps.Approvals.LocateList.App exposing (..)
import Morphir.Sample.Apps.Approvals.Inventory.App as InventoryApp


{-| This application only depends on `InventoryApp`. This function takes the
remote app type as an input and returns an implementation of the local view
of the remote state.
-}
map : InventoryApp.App -> RemoteState
map inventoryApp =
    { requestApproval = requestApproval inventoryApp
    , trackApprovalState = trackApprovalState inventoryApp
    }


requestApproval : InventoryApp.App -> ListID -> Product.ID -> Int -> Cmd Event
requestApproval inventoryApp listID productID qty =
    inventoryApp 
        |> sendCommand 
            (\api -> api.requestApproval productID qty)
            (\result ->
                result
                    |> Maybe.map (\_ -> [ ApprovalRequestProcessed listID productID Failed ])
                    |> Maybe.withDefault []    
            )


trackApprovalState : InventoryApp.App -> List ( ListID, Product.ID ) -> Sub Event
trackApprovalState inventoryApp requestsToTrack =
    inventoryApp 
        |> subscribe
            (\t1 t2 ->
                DE.changes t1.requestStates t2.requestStates
                    |> List.filterMap
                        (\change ->
                            case change of
                                DE.Update ( listID, productID ) _ newState ->
                                    if requestsToTrack |> List.member ( listID, productID ) then
                                        let
                                            localState =
                                                case newState of
                                                    InventoryApp.Pending ->
                                                        Pending

                                                    InventoryApp.Denied ->
                                                        Denied

                                                    InventoryApp.Approved ->
                                                        Approved
                                        in
                                        Just (ApprovalRequestProcessed listID productID localState)
                                    else
                                        Nothing    

                                _ ->
                                    Nothing    
                        )
            )            