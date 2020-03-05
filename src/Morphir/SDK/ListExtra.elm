module Morphir.SDK.ListExtra exposing (get)


{-| Get the item at an index in the List or Nothing if the index is out of range.
    get 10 [] == Nothing
    get -1 [1,2,3] == Nothing
    get 1  [1,2,3] == Just 2
-}
get : Int -> List a -> Maybe a
get index list =
  if index < 0 then
    Nothing
  else
    list |> List.drop (index - 1) |> List.head
