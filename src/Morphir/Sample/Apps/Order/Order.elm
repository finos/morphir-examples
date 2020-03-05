module Morphir.Sample.Apps.Order.Order exposing (..)


import Morphir.Sample.Apps.Shared.Price exposing (..)
import Morphir.Sample.Apps.Shared.Product as Product
import Morphir.Sample.Apps.Shared.Quantity exposing (..)


{-| Order price can either be market or limit. 
  * Market will take the current market price at the time the order is processed.
  * Limit takes the specific price that is supplied. 

This kind OR relationship between types is difficult to express in most OOP languages.
Enums come close to it but if the types are different structurally an enum cannot model 
that. In this example one type has no extra info while the other has a Price value 
associated to it. This happens very frequently in our domain and not having a direct way 
to model it creates a lot of friction.  
-}
type OrderPrice
    = Market
    | Limit Price


{-| Type aliases are great when you want to defer a decision about the structure of a value.
In this example we knew that we needed an order request ID and that we might need to structure 
it in a certain way in the future but for now we just want to model it as a string. If we just
used a string in our models we would have lost thhis information and changing to a different 
type would also require changes in many places. With an alias you can change the type right here 
and will be applied everywhere where it's used.
-}
type alias ID = String 


{-| An order request is modeled using a record type which is almost like a POJO but it's immutable
and automatically defines equality by comparing all fields. This makes records ideal for messaging.
-}
type alias Request a =
    { a | id: ID
    , requestPrice : OrderPrice
    }


type alias BuyRequest = Request
    { quantity : Quantity
    , product : Product.ID
    }


type alias SellRequest = Request
    { dealId : String
    }


{-| Union types are great for modeling the different kind of violations that we can capture in our 
validation rules. Just as before we do more than just enums since the different violations are structurally
different.
-}
type Violations
    = InvalidPrice Price
    | InvalidQuantity Quantity


{-| In this example we thought that differentiating validation errors from rejections due to business
reasons is usefult so we captured them in a separate type.
-}
type RejectReason
    = InsufficientInventory
    | DisagreeablePrice


{-| Union types are great for modeling results too. Here we have 3 different types of results.
An order can be:
  * Accepted if everything goes well, or
  * Invalid if a validation rule was violated, or
  * Rejected if the order was valid but we didn't accpt it for business reasons.
-}
type BuyResponse
    = BuyAccepted ID Product.ID Price Quantity
    | BuyInvalid ID (List Violations)
    | BuyRejected ID (List RejectReason)


type SellResponse 
    = SellAccepted ID Price


-- Our own representation of a Deal to avoid tight coupled dependency on BooksAndRecords in core logic
type alias Deal =
    { id : ID
    , product : Product.ID
    , price : Price
    , quantity : Quantity
    }

-- type Response = Buy BuyResponse | Sell SellResponse


{- Simple helper -}
getId : BuyResponse -> ID
getId response = 
    case response of
        BuyAccepted id _ _ _ -> id
        BuyInvalid id _ -> id
        BuyRejected id _ -> id


{-| Validation takes in the order request and retuns a list of violations. An empty list of violations 
means the order request is valid.
-}
validate : BuyRequest -> List Violations
validate request =
    let 
        priceCheck = 
            case request.requestPrice of
                Market ->
                    []
                Limit p ->
                    if 
                        p < 0
                    then
                        [InvalidPrice p] 
                    else 
                        []

        quantityCheck =
            if 
                request.quantity <= 0 
            then 
                [InvalidQuantity request.quantity] 
            else
                []
    in
    priceCheck ++ quantityCheck


{-| This is where modeling request price as a union pays off. We don't have to handle invalid states
like a limit request without a price or a market request with a price defined. We can focus on handling
requests that are valid from a business perspective which means that there is less noise and the code
becomes more readable.
-}
lockinPrice : OrderPrice -> Price -> Price
lockinPrice requestPrice marketPrice =
    case requestPrice of
        Market -> 
            marketPrice

        Limit p -> 
            p


{-| This is where the business decision is made. Similar to validation lack of rejections means that
the order request was accepted.
-}
acceptability : BuyRequest -> Price -> Quantity -> List RejectReason
acceptability request marketPrice availableInventory =
    let
        -- Quantity needs to be greater than 0.
        availabilityCheck = 
            if availableInventory < request.quantity then 
                [InsufficientInventory]
            else
                []

        -- Bid price can be within a threshold (no less than 90%) of the market price.
        priceCheck = 
            if (lockinPrice request.requestPrice marketPrice) < marketPrice * 0.9 then
                [DisagreeablePrice]
            else
                []
    in
    availabilityCheck ++ priceCheck


{-| Finally we process the request request and return a result. This is a simplified example
so we didn't pass in the current state of the system but in a real implementation we would 
do that to make the code predictable. 
-}
processBuy : BuyRequest -> Price -> Quantity -> BuyResponse
processBuy request marketPrice availableInventory =
    let 
        violations = validate request
    
        rejections = acceptability request marketPrice availableInventory

        lockPrice = lockinPrice request.requestPrice marketPrice
    in
    -- This is where we make the final decision about how to respond.
    -- As you can see it's very easy to read it. No technical details mentioned.
    -- Just pure business-logic.
    if not (List.isEmpty violations) then 
        BuyInvalid request.id violations
    else if not (List.isEmpty rejections) then 
        BuyRejected request.id rejections
    else
        BuyAccepted request.id request.product lockPrice request.quantity




{-| Finally we process the request request and return a result. This is a simplified example
so we didn't pass in the current state of the system but in a real implementation we would 
do that to make the code predictable. 
-}
processSell : SellRequest -> Price -> SellResponse
processSell request marketPrice =
    let 
        lockPrice = lockinPrice request.requestPrice marketPrice
    in
        SellAccepted request.id lockPrice


{-| Calculate the currently available inventory based on start of day position minus sum of previous buys.
This is the kind of important business logic we want to preserve across technical implementations.
-}
availability : Quantity -> List BuyResponse -> Quantity
availability startOfDayPosition buys =
    let
        sumOfBuys = buys 
            |> List.map (\response -> 
                case response of 
                    BuyAccepted _ _ _ quantity -> quantity
                    _ -> 0
            )
            |> List.sum
    in
    startOfDayPosition - sumOfBuys