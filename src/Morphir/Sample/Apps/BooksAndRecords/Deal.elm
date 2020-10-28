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
