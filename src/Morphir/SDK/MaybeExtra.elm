module Morphir.SDK.MaybeExtra exposing (toList)


{-| Return an empty list on `Nothing` or a list with one element, where the element is the value of `Just`.
    maybeToList Nothing == []
    maybeToList (Just 1) == [1]
-}
toList : Maybe a -> List a
toList m =
  case m of
    Nothing -> []
    Just x -> [x]
