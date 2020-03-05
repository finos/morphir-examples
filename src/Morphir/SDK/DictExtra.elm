module Morphir.SDK.DictExtra exposing (..)


import Dict exposing (Dict)


filterMap : (comparable -> a -> Maybe b) -> Dict comparable a -> Dict comparable b
filterMap f dict =
    dict
        |> Dict.toList
        |> List.filterMap 
            (\( k, a ) -> 
                f k a
                    |> Maybe.map (\v -> ( k, v ))
            )
        |> Dict.fromList


getAndThen : Dict comparable a -> comparable -> (a -> Maybe b) -> Maybe b
getAndThen dict key f =
    dict
        |> Dict.get key
        |> Maybe.andThen f


getMap : Dict comparable a -> comparable -> (a -> b) -> Maybe b
getMap dict key f =
    dict
        |> Dict.get key
        |> Maybe.map f        


type DictEvent comparable v 
    = Insert comparable v
    | Update comparable v v
    | Delete comparable v
        

changes : Dict comparable v -> Dict comparable v -> List (DictEvent comparable v)
changes dict1 dict2 =
    [] -- TODO: implement


filterByKey : (comparable -> Bool) -> List (DictEvent comparable v) -> List (DictEvent comparable v)
filterByKey f list =
    list
        |> List.filter
            (\change ->
                case change of
                    Insert key _ ->
                        f key

                    Update key _ _ ->
                        f key

                    Delete key _ ->
                        f key
            )    