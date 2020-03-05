module Morphir.SDK.Average exposing (..)


weighted : (a -> Float) -> (a -> Float) -> List a -> Maybe Float
weighted getWeight getValue list =
    if List.isEmpty list then
        Nothing
    else    
        let
            totalWeight =
                list 
                    |> List.map getWeight 
                    |> List.sum

            totalWeightedValue =
                list 
                    |> List.map (\a -> getWeight a * getValue a) 
                    |> List.sum
        in
        Just (totalWeightedValue / totalWeight)