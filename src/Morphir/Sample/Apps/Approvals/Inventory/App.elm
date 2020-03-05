module Morphir.Sample.Apps.Approvals.Inventory.App exposing (..)


import Dict exposing (Dict)
import Morphir.SDK.App exposing (StatefulApp, statefulApp)
import Morphir.Sample.Apps.Shared.Product as Product


{-| This is a type that describes the application to the external world.
It can be referenced in other applications' anti-corruption layers but 
should not be directly referenced from other applications. Check out
how it's referenced from [ACL.elm](../LocateList/ACL.elm).

The declaration makes it clear that this is a stateful app and refers
to other types that desribe the API, events, remote and local state of
the app.
-}
type alias App = 
    StatefulApp API RemoteState LocalState Event


{-| Type that describes the API of the application. Each field is a function
that returns a result with a failure or an event. This type is used in other
applications' ACLs to send commands to the application. The events generated 
will be sent to the update method by the runtime.
-}
type alias API =
    { receiveAvailability : Product.ID -> Int -> Result Never Event
    , requestApproval : Product.ID -> Int -> Result InvalidRequest Event
    }


{-| This type describes the view of the external world from the applications
point of view. This specific application doesn't depend on any external state
so the type is empty.
-}
type alias RemoteState =
    ()


{-| Local state is managed by the application itself. It can only be updated
by this application and only as a result of an event.
-}
type alias LocalState =
    { availability : Dict Product.ID Int
    , requestStates : Dict RequestID RequestState
    }


{-| This type defines all the possible events that could affect the state of
the application. Events can be generated as a result of API calls or external
events through a subscription.
-}
type Event
    = AvailabilityReceived Product.ID Int
    | ApprovalGranted Product.ID Int
    | ApprovalDenied Product.ID
    | ApprovalPending Product.ID Int


{-| Top level declaration for the application. Binds all the lifecycle methods
to their actual implementations.
-}
app : App
app =
    statefulApp
        { api = api
        , init = init
        , update = update
        , subscriptions = subscriptions
        }


{-| Function that returns an implementation of the API based on the remote and 
the local state. Invocations of the API don't directly update the state instead
they generate events which can update the state through the update function.
-}
api : RemoteState -> LocalState -> API
api remote local =
    { receiveAvailability = 
        \productID qty ->
            Ok (AvailabilityReceived productID qty)

    , requestApproval = 
        \productID requestedQty ->
            case local.availability |> Dict.get productID of
                Nothing ->
                    Ok (ApprovalDenied productID)

                Just availableQty ->
                    if availableQty >= requestedQty then
                        Ok (ApprovalGranted productID requestedQty)
                    else
                        Ok (ApprovalDenied productID)
    }


{-| Same as The Elm Architecture with an additional remote state input.
-}
init : RemoteState -> ( LocalState, Cmd Event )
init _ = 
    ( { availability = Dict.empty
      , requestStates = Dict.empty
      }
    , Cmd.none
    )  


{-| Same as The Elm Architecture with an additional remote state input.
-}
update : RemoteState -> Event -> LocalState -> ( LocalState, Cmd Event )
update remote event state =
    case event of
        AvailabilityReceived productID qty ->
            ( { state
                | availability =
                    state.availability 
                        |> Dict.update productID
                            (\maybeAvail ->
                                let
                                    currentQty =
                                        maybeAvail 
                                            |> Maybe.withDefault 0
                                in
                                Just (currentQty + qty)
                            ) 
              }
            , Cmd.none 
            )

        ApprovalGranted productID qty ->
            ( { state
                | availability =
                    state.availability 
                        |> Dict.update productID
                            (\maybeAvail ->
                                let
                                    currentQty =
                                        maybeAvail 
                                            |> Maybe.withDefault 0
                                in
                                Just (currentQty - qty)
                            ) 
              }
            , Cmd.none 
            )

        ApprovalDenied productID ->
            ( state, Cmd.none )


        ApprovalPending productID qty ->
            ( state, Cmd.none )


{-| Same as The Elm Architecture with an additional remote state input.
-}
subscriptions remote local =
    Sub.none


-- Extra types used in the API and state


type InvalidRequest
    = InvalidQuantity Int


type alias RequestID = 
    ( String, Product.ID )


type RequestState
    = Pending
    | Approved
    | Denied        


