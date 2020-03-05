module Morphir.SDK.App exposing (..)


type StatelessApp remotestate view = 
    StatelessApp (remotestate -> view)


statelessApp : (remotestate -> view) -> StatelessApp remotestate view
statelessApp f =
    StatelessApp f


type StatefulApp api remotestate localstate event = 
    StatefulApp
        { api : remotestate -> localstate -> api
        , init : remotestate -> ( localstate, Cmd event )
        , update : remotestate -> event -> localstate -> ( localstate, Cmd event )
        , subscriptions : remotestate -> localstate -> Sub event
        }


sendCommand : (api -> Result x event) -> (Maybe x -> List a) -> StatefulApp api remotestate localstate event -> Cmd a
sendCommand command mapResult app =
    Cmd.none


subscribe : (localstate -> localstate -> List a) -> StatefulApp api remotestate localstate event -> Sub a
subscribe query app =
    Sub.none


statefulApp :
    { api : remotestate -> localstate -> api
    , init : remotestate -> ( localstate, Cmd event )
    , update : remotestate -> event -> localstate -> ( localstate, Cmd event )
    , subscriptions : remotestate -> localstate -> Sub event
    }
    -> StatefulApp api remotestate localstate event
statefulApp app =
    StatefulApp app


{-| Just a helper for readability -}
cmdNone : a -> (a, Cmd msg)
cmdNone a =
    (a, Cmd.none)