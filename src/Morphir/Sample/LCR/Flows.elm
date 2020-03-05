module Morphir.Sample.LCR.Flows exposing (..)


import Morphir.SDK.Basics exposing (Decimal)
import Date exposing (Date, Interval(..), Unit(..))
import Morphir.Sample.LCR.Basics exposing (..)
import Morphir.Sample.LCR.Counterparty exposing (CounterpartyId)
import Morphir.Sample.LCR.Product exposing (ProductId)
import Morphir.Sample.LCR.MaturityBucket as MB


type alias BusinessDate = Date


type alias ReportingEntity = Entity


type alias Flow =
    { amount : Decimal
    , assetType : AssetCategoryCodes
    , businessDate : BusinessDate
    , collateralClass : AssetCategoryCodes
    , counterpartyId : CounterpartyId
    , currency : Currency
    , fed5GCode : Fed5GCode
    , insured : InsuranceType
    , isTreasuryControl : Bool
    , isUnencumbered : Bool
    , maturityDate : Date
    , effectiveMaturityDate : Date
    , productId : ProductId
    }
