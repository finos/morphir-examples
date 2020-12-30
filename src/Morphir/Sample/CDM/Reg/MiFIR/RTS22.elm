module Morphir.Sample.CDM.Reg.MiFIR.RTS22 exposing (..)

import List.Nonempty as Nonempty exposing (Nonempty)
import Morphir.SDK.LocalDate exposing (LocalDate)
import Morphir.Sample.CDM.Reg.MiFIR.AncillaryRoleEnum exposing (AncillaryRoleEnum)
import Morphir.Sample.CDM.Reg.MiFIR.FloatingRateIndexEnum exposing (FloatingRateIndexEnum(..))


type alias Report =
    { price : Price

    --, reportStatus : ReportStatus
    --, transactionReferenceNumber : TransactionReferenceNumber
    --, tradingVenueTransactionIdentificationCode : TradingVenueTransactionIdentificationCode
    --, executingEntityIdentificationCode : ExecutingEntityIdentificationCode
    --, isInvestmentFirm : IsInvestmentFirm
    --, submittingEntityIdentificationCode : SubmittingEntityIdentificationCode
    --, buyerSeller : BuyerSeller
    --, transmissionOfOrderIndicator : TransmissionOfOrderIndicator
    --, tradingDateTime : TradingDateTime
    --, tradingCapacity : TradingCapacity
    , quantity : Quantity

    --, venueOfExecution : VenueOfExecution
    --, countryOfTheBranchMembership : CountryOfTheBranchMembership
    --, instrumentIdentificationCode : InstrumentIdentificationCode
    --, instrumentFullName : InstrumentFullName
    --, instrumentClassification : InstrumentClassification
    --, notionalCurrency1 : NotionalCurrency1
    --, notionalCurrency2 : NotionalCurrency2
    --, priceMultiplier : PriceMultiplier
    --, underlyingInstrumentCode : UnderlyingInstrumentCode
    --, underlyingIndexName : UnderlyingIndexName
    --, underlyingIndexTermPeriod : UnderlyingIndexTermPeriod
    --, underlyingIndexTermMultiplier : UnderlyingIndexTermMultiplier
    --, expiryDate : ExpiryDate
    --, deliveryType : DeliveryType
    --, investmentDecisionWithinFirm : InvestmentDecisionWithinFirm
    --, personResponsibleForInvestmentDecisionCountry : PersonResponsibleForInvestmentDecisionCountry
    --, executionWithinFirm : ExecutionWithinFirm
    --, personResponsibleForExecutionCountry : PersonResponsibleForExecutionCountry
    --, commodityDerivativeIndicator : CommodityDerivativeIndicator
    --, securitiesFinancingTransactionIndicator : SecuritiesFinancingTransactionIndicator
    }


type alias Quantity =
    { amount : Amount
    , unit : Unit
    }


type alias Number =
    Float


type alias Amount =
    Float


type Unit
    = MWH
    | MMBTU
    | BBL
    | GAL
    | BSH


type PriceType
    = FixedFixedPrice
    | FixedFloatPrice
    | BasisSwapPrice
    | CDSPrice


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


type alias FixedInterestRate =
    { rate : Float
    }


type alias FloatingInterestRate =
    { initialRate : Maybe Number
    , spread : Maybe Number
    , capRate : Maybe Number
    , floorRate : Maybe Number
    , multiplier : Maybe Number
    }


type alias Trade =
    { tradableProduct : TradableProduct
    }


type alias Identifier =
    { issuerReference : Maybe Party
    , issuer : Maybe String
    , assignedIdentifier : AssignedIdentifier
    }


type alias AssignedIdentifier =
    { identifier : String
    , version : Maybe Version
    }


type alias Party =
    { partyId : String
    , name : Maybe String
    , person : List NaturalPerson

    --, account : Maybe Account
    }


type alias Account =
    { partyReference : Maybe Party
    , accountNumber : String
    , accountName : Maybe String
    , accountType : Maybe AccountTypeEnum
    , accountBeneficiary : Maybe Party
    , servicingParty : Maybe Party
    }


type AccountTypeEnum
    = AccountTypeEnum
    | AggregateClient
    | Client
    | House


type alias NaturalPerson =
    { honorific : Maybe String
    , firstName : String
    , middleName : List String
    , initial : List String
    , surname : String
    , suffix : Maybe String
    , dateOfBirth : Maybe LocalDate
    }


type alias Version =
    Int


type alias TradableProduct =
    { product : Product
    , quantityNotation : Nonempty QuantityNotation
    , priceNotation : Nonempty PriceNotation
    , counterparty : ( Counterparty, Counterparty )
    , ancillaryParty : List AncillaryParty
    , adjustment : Maybe NotionalAdjustmentEnum
    }


type NotionalAdjustmentEnum
    = Execution
    | PortfolioRebalancing
    | Standard


type alias Counterparty =
    { role : CounterpartyRoleEnum
    , partyReference : Party
    }


type alias AncillaryParty =
    { role : AncillaryRoleEnum
    , partyReference : Nonempty Party
    , onBehalfOf : Maybe CounterpartyRoleEnum
    }


type CounterpartyRoleEnum
    = Party1
    | Party2


type alias QuantityNotation =
    { quantity : NonNegativeQuantity
    , assetIdentifier : AssetIdentifier
    }


type alias NonNegativeQuantity =
    -- TODO
    Float


type alias AssetIdentifier =
    { productIdentifier : Maybe ProductIdentifier
    , currency : Maybe Currency
    , rateOption : Maybe FloatingRateOption
    }


type alias FloatingRateOption =
    { floatingRateIndex : FloatingRateIndexEnum
    , indexTenor : Maybe Period
    }


type alias Period =
    { periodMultiplier : Int
    , period : PeriodEnum
    }


type PeriodEnum
    = D
    | W
    | M
    | Y


type alias ProductIdentifier =
    { identifier : String
    }


type alias Currency =
    -- TODO
    String


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
    , creditDefaultPayout : Maybe CreditDefaultPayout
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
        |> Nonempty.toList
        |> List.filterMap (\x -> x.price.fixedInterestRate)
        |> List.map .rate
        |> List.maximum



-- FixedFloat


isFixedFloat : Trade -> Bool
isFixedFloat trade =
    let
        fixedCount =
            trade.tradableProduct.product.contractualProduct.economicTerms.payout.interestRatePayout
                |> Maybe.map (\x -> x.rateSpecification.fixedRate)
                |> Maybe.withDefault []
                |> List.length

        floatingCount =
            trade.tradableProduct.product.contractualProduct.economicTerms.payout.interestRatePayout
                |> Maybe.map (\x -> x.rateSpecification.floatingRate)
                |> Maybe.withDefault []
                |> List.length
    in
    fixedCount == 1 && floatingCount == 1


fixedFloatPrice : Trade -> Maybe Float
fixedFloatPrice trade =
    -- TODO : Is this the correct interpretation of the above?
    trade.tradableProduct.priceNotation
        |> Nonempty.toList
        |> List.filterMap (\x -> x.price.fixedInterestRate)
        |> List.map .rate
        |> List.maximum



-- BasisSwap


isIRSwapBasis : Trade -> Bool
isIRSwapBasis trade =
    let
        count =
            trade.tradableProduct.product.contractualProduct.economicTerms.payout.interestRatePayout
                |> Maybe.map (\x -> x.rateSpecification.floatingRate)
                |> Maybe.withDefault []
                |> List.length
    in
    count == 2


basisSwapPrice : Trade -> Maybe Float
basisSwapPrice trade =
    trade.tradableProduct.priceNotation
        |> Nonempty.toList
        |> List.filterMap (\x -> x.price.floatingInterestRate)
        |> List.filterMap .initialRate
        |> List.head



-- CDS


isCreditDefaultSwap : Trade -> Bool
isCreditDefaultSwap trade =
    trade.tradableProduct.product.contractualProduct.economicTerms.payout.creditDefaultPayout |> exists


cdsPrice : Trade -> Maybe Float
cdsPrice trade =
    let
        mp =
            trade.tradableProduct.priceNotation
                |> Nonempty.toList
                |> List.head
                |> Maybe.map .price

        fixedRate =
            mp
                |> Maybe.map .fixedInterestRate
                |> Maybe.withDefault Nothing
                |> Maybe.map .rate

        floatingRate =
            mp
                |> Maybe.map .floatingInterestRate
                |> Maybe.withDefault Nothing
                |> Maybe.map .initialRate
    in
    case ( fixedRate, floatingRate ) of
        ( Just rate, _ ) ->
            if rate /= 0 then
                Just rate

            else
                Nothing

        ( _, Just (Just initialRate) ) ->
            Just initialRate

        _ ->
            Just 0


exists : Maybe a -> Bool
exists m =
    case m of
        Nothing ->
            False

        _ ->
            True
