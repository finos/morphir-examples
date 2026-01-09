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


module Morphir.Sample.Apps.Upstream.Trading.App exposing (..)

{-| This is a stub for an external Trading app. Normally this would
live in an external library but it's included for simplicity. The
application's API is exposed here and in the external library the
implementation would be included as well.
-}

import Dict exposing (Dict)
import Morphir.Sample.Apps.Shared.Client as Client
import Morphir.Sample.Apps.Shared.Product as Product
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
