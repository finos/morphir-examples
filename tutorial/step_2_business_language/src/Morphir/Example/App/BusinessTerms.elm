module Morphir.Example.App.BusinessTerms exposing (..)


type alias Quantity =
    Int


type alias RentalID =
    String


type alias CurrentInventory =
    Int


type alias ReservationQuantity =
    Int


type alias ExistingReservations =
    Int


type alias PendingReturns =
    Int


type alias ProbableReservations =
    Int


type alias CanceledQuantity =
    Int


type alias CancelationRatio =
    Float


type alias Availability =
    Int


type ExpertiseLevel
    = Novice
    | Intermediate
    | Expert



-- Request specific


type alias RequestedQuantity =
    Int


type alias AllowPartials =
    Bool


type Reason
    = InsufficientAvailability
    | ClosedDueToConditions
