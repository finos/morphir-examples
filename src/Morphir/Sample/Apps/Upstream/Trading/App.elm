module Morphir.Sample.Apps.Upstream.Trading.App exposing (..)


{-| This is a stub for an external Trading app. Normally this would
live in an external library but it's included for simplicity. The 
application's API is exposed here and in the external library the 
implementation would be included as well.
-}

import Dict exposing (Dict)
import Morphir.Sample.Apps.Shared.Product as Product
import Morphir.Sample.Apps.Shared.Client as Client
import Morphir.Sample.Apps.Shared.Rate exposing (Rate)


type alias DealID =
    String


type alias Loan =
    { productID : Product.ID
    , borrower : Client.ID
    , quantity : Int
    , rate : Rate
    }


type alias Borrow =
    { productID : Product.ID
    , lender : Client.ID
    , quantity : Int
    , rate : Rate
    }


type alias State =
    { loans : Dict DealID Loan
    , borrows : Dict DealID Borrow
    }
