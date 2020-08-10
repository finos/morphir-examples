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

module Morphir.Sample.Apps.Approvals.LocateList.App exposing (..)


import Dict exposing (Dict)
import Morphir.SDK.App exposing (StatefulApp, statefulApp)
import Morphir.Sample.Apps.Shared.Product as Product


{-| This is a type that describes the application to the external world.

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
    { receiveLocateList : ListID -> List ( Product.ID, Int ) -> Result ListRejected Event
    }


{-| This type describes the view of the external world from the applications
point of view. This specific application sends approval requests and listens
to approval request state updates. The type should represent the application's
needs and don't have to replicate remote applications' API. Translating these
functions to remote API calls is the responsibility of the anti-corruption layer.

The state exposes 2 functions in this case:
- *requestApproval* - Creates a command to initiate an approval request. The
  command is bound to an event that is sent to the application when the command 
  completes. In-line with The Elm Architecture the function is used in the update 
  method to return a batch of commands. The translation between the remote API 
  and local events is done in the ACL.
- *trackApprovalState* - Creates a subscription to specific set of approval requests.
  See the subsriptions function to see how it's used. The translation between the 
  remote state changes and local events is done in the ACL.

-}
type alias RemoteState =
    { requestApproval : ListID -> Product.ID -> Int -> Cmd Event
    , trackApprovalState : List ( ListID, Product.ID ) -> Sub Event
    }


{-| Local state is managed by the application itself. It can only be updated
by this application and only as a result of an event.
-}
type alias LocalState =
    { locateLists : Dict ListID LocateList
    }


{-| This type defines all the possible events that could affect the state of
the application. Events can be generated as a result of API calls or external
events through a subscription.
-}
type Event
    = LocateListReceived ListID (List ( Product.ID, Int ))
    | ApprovalRequestProcessed ListID Product.ID RequestState


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
    { receiveLocateList = 
        \listID requests ->
            case local.locateLists |> Dict.get listID of
                Just existingList ->
                    Err DuplicateList

                Nothing ->
                    Ok (LocateListReceived listID requests)            
    }


{-| Same as The Elm Architecture with an additional remote state input.
-}
init : RemoteState -> ( LocalState, Cmd Event )
init _ = 
    ( { locateLists = Dict.empty
      }
    , Cmd.none
    )  


{-| Same as The Elm Architecture with an additional remote state input.
-}
update : RemoteState -> Event -> LocalState -> ( LocalState, Cmd Event )
update remote event state =
    case event of
        LocateListReceived listID requests ->
            ( { state
                | locateLists =
                    state.locateLists 
                        |> Dict.insert listID 
                            (requests
                                |> List.map
                                    (\( productID, qty ) ->
                                        ( productID, Received )
                                    )
                                |> Dict.fromList    
                            )    
              }
            , requests
                |> List.map
                    (\( productID, qty ) ->
                        remote.requestApproval listID productID qty
                    )
                |> Cmd.batch    
            )

        ApprovalRequestProcessed listID productID newState ->
            ( { state
                | locateLists =
                    state.locateLists 
                        |> Dict.update listID 
                            (\requestStates ->
                                requestStates
                                    |> Maybe.withDefault Dict.empty
                                    |> Dict.insert productID newState
                                    |> Just
                            )
              }
            , Cmd.none 
            )


{-| Same as The Elm Architecture with an additional remote state input.
-}
subscriptions remote local =
    local.locateLists
        |> Dict.toList
        |> List.concatMap
            (\( listID, requestStates ) ->
                requestStates
                    |> Dict.toList
                    |> List.filterMap
                        (\( productID, requestState ) ->
                            case requestState of
                                Pending ->
                                    Just ( listID, productID )

                                _ ->
                                    Nothing    
                        )
            )
        |> remote.trackApprovalState


-- Extra types used in the API and state


type alias ListID = String


type ListRejected 
    = DuplicateList


type alias LocateList =
    Dict Product.ID RequestState


type RequestState 
    = Received
    | Failed
    | Pending
    | Approved
    | Denied
