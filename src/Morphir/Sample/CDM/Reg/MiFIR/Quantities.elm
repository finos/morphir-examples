module Morphir.Sample.CDM.Reg.MiFIR.Quantities exposing
    ( NonNegativeQuantity
    , Quantity
    , UnitEnum(..)
    , nonNegativeQuantity
    )

import Morphir.Sample.CDM.Reg.MiFIR.Basics exposing (Amount)


type alias Quantity a =
    { a
        | amount : Amount
        , unit : UnitEnum
    }


type UnitEnum
    = MWH
    | MMBTU
    | BBL
    | GAL
    | BSH


type alias NonNegativeQuantity =
    Quantity
        {}


nonNegativeQuantity : Amount -> UnitEnum -> Result String NonNegativeQuantity
nonNegativeQuantity amount unit =
    if amount < 0 then
        Err "amount must be greater or equal to 0"

    else
        Ok { amount = amount, unit = unit }
