module Morphir.Sample.Apps.BooksAndRecords.Deal exposing (..)


import Morphir.Sample.Apps.Shared.Product as Product
import Morphir.Sample.Apps.Shared.Client as Client
import Morphir.Sample.Apps.Shared.Price exposing (..)
import Morphir.Sample.Apps.Shared.Quantity exposing (..)


type alias ID = String


type alias Value = Float


type alias Deal =
    { id : ID
    , product : Product.ID
    , price : Price
    , quantity : Quantity
    }


value : Deal -> Value
value deal =
    deal.price * (toFloat deal.quantity)
