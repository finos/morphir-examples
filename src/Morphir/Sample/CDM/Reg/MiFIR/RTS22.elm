module Morphir.Sample.CDM.MiFIR.RTS22 exposing (..)


type PriceType
    = FixedFixedPrice
    | FixedFloatPrice
    | BasisSwapPrice
    | CDSPrice


type alias Report =
    { price : Float
    }


type alias PriceNotation =
    { price : Price
    }


type alias Price =
    { fixedInterestRate : Maybe FixedInterestRate

    -- TODO: We don't need these right now
    --, cashPrice : Maybe CashPrice
    --, exchangeRate : Maybe ExchangeRate
    , floatingInterestRate : Maybe FloatingInterestRate
    }


type alias FloatingInterestRate =
    { initialRate : Float
    , initialRate : Maybe Float
    , spread : Maybe Float
    , capRate : Maybe Float
    , floorRate : Maybe Float
    , multiplier : Maybe Float
    }


type alias FixedInterestRate =
    { rate : Float
    }


type alias Trade =
    { tradableProduct : TradableProduct
    }


type alias TradableProduct =
    { product : Product
    , priceNotation : List PriceNotation
    }


type alias Product =
    { contractualProduct : ContractualProduct
    }


type alias ContractualProduct =
    { economicTerms : EconomicTerms
    }


type alias EconomicTerms =
    { payout : Payout
    }


type alias Payout =
    { interestRatePayout : Maybe InterestRatePayout
    , crediteDefaultPayout : Maybe CreditDefaultPayout
    }


type alias CreditDefaultPayout =
    -- TODO: Empty for now
    {}


type alias InterestRatePayout =
    { rateSpecification : RateSpecification
    }


type alias RateSpecification =
    { fixedRate : List Float
    , floatingRate : List Float
    }


price : Trade -> Maybe Float
price trade =
    priceType trade
        |> Maybe.map
            (\pt ->
                case pt of
                    FixedFixedPrice ->
                        fixedFixedPrice trade

                    FixedFloatPrice ->
                        fixedFloatPrice trade

                    BasisSwapPrice ->
                        basisSwapPrice trade

                    CDSPrice ->
                        cdsPrice trade
            )
        |> Maybe.withDefault Nothing


priceType : Trade -> Maybe PriceType
priceType trade =
    if isFixedFixed trade then
        Just FixedFixedPrice

    else if isFixedFixed trade then
        Just FixedFloatPrice

    else if isIRSwapBasis trade then
        Just BasisSwapPrice

    else if isCreditDefaultSwap trade then
        Just CDSPrice

    else
        Nothing



-- FixedFixed


isFixedFixed : Trade -> Bool
isFixedFixed trade =
    let
        count =
            trade.tradableProduct.product.contractualProduct.economicTerms.payout.interestRatePayout
                |> Maybe.map (\x -> x.rateSpecification.fixedRate)
                |> Maybe.withDefault []
                |> List.length
    in
    count == 2


{-| reporting rule FixedFixedPrice
filter when rule IsFixedFixed then
extract Trade -> tradableProduct -> priceNotation -> price -> fixedInterestRate then
maxBy FixedInterestRate -> rate then
extract FixedInterestRate -> rate as "Price"
-}
fixedFixedPrice : Trade -> Maybe Float
fixedFixedPrice trade =
    trade.tradableProduct.priceNotation
        |> List.filterMap (\x -> x.price.fixedInterestRate)
        |> List.map .rate
        |> List.maximum



-- FixedFloat


isFixedFloat : Trade -> Bool
isFixedFloat trade =
    let
    List.length trade.tradableProduct.product.contractualProduct.economicTerms.payout.interestRatePayout.rateSpecification.fixedRate
        == 1
        && List.length trade.tradableProduct.product.contractualProduct.economicTerms.payout.interestRatePayout.rateSpecification.floatingRate
        == 1


fixedFloatPrice : Trade -> Maybe Float
fixedFloatPrice trade =
    -- TODO : Is this the correct interpretation of the above?
    trade.tradableProduct.priceNotation
        |> List.filterMap (\x -> x.price.fixedInterestRate)
        |> List.map .rate
        |> List.maximum



-- BasisSwap


isIRSwapBasis : Trade -> Bool
isIRSwapBasis trade =
    List.length trade.tradableProduct.product.contractualProduct.economicTerms.payout.interestRatePayout.rateSpecification.floatingRate == 2


basisSwapPrice : Trade -> Maybe Float
basisSwapPrice trade =
    trade.tradableProduct.priceNotation
        |> List.filterMap (\x -> x.price.floatingInterestRate)
        |> List.filterMap .initialRate
        |> List.head



-- CDS


isCreditDefaultSwap : Trade -> Bool
isCreditDefaultSwap trade =
    trade |> .tradableProduct |> .product |> .contractualProduct |> .economicTerms |> .payout |> .creditDefaultPayout |> exists


cdsPrice : Trade -> Maybe Float
cdsPrice trade =
    let
        p =
            trade.tradableProduct.priceNotation.price
    in
    if p.fixedInterestRate.rate /= 0 then
        p.fixedInterestRate.rate

    else
        p.floatingInterestRate.initialRate


exists : Maybe a -> Bool
exists m =
    case m of
        Nothing ->
            False

        _ ->
            True
