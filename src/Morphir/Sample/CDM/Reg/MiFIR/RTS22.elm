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


module Morphir.Sample.CDM.Reg.MiFIR.RTS22 exposing (..)

import Company.Operations.BooksAndRecords exposing (Quantity)
import List.Nonempty as Nonempty exposing (Nonempty)
import Morphir.SDK.LocalDate exposing (LocalDate)
import Morphir.Sample.CDM.Reg.MiFIR.AncillaryRoleEnum exposing (AncillaryRoleEnum)
import Morphir.Sample.CDM.Reg.MiFIR.Basics exposing (..)
import Morphir.Sample.CDM.Reg.MiFIR.Enums exposing (..)
import Morphir.Sample.CDM.Reg.MiFIR.FloatingRateIndexEnum exposing (FloatingRateIndexEnum(..))
import Morphir.Sample.CDM.Reg.MiFIR.Quantities exposing (NonNegativeQuantity)
import Morphir.Sample.LCR.Flows exposing (Amount)

{-| This example focuses on the Rosetta DSL's reporting functionality.
-}

-- Trade Data Structures --


type PriceType
    = FixedFixedPrice
    | FixedFloatPrice
    | BasisSwapPrice
    | CDSPrice


type alias PriceNotation =
    { price : Price
    , assetIdentifier : Maybe AssetIdentifier
    }


priceNotation : Price -> Maybe AssetIdentifier -> Result String PriceNotation
priceNotation price mAssetIdentifier =
    let
        currencyExists =
            mAssetIdentifier |> Maybe.map .currency |> exists

        rateOptionExists =
            mAssetIdentifier |> Maybe.map .rateOption |> exists
    in
    if exists price.fixedInterestRate && not currencyExists then
        Err "The asset identifier for an interest rate spread must be a rate option."

    else if exists price.floatingInterestRate && not rateOptionExists then
        Err "The asset identifier for a fixed interest rate must be a currency."

    else
        Ok (PriceNotation price mAssetIdentifier)


type alias Price =
    { fixedInterestRate : Maybe FixedInterestRate
    , cashPrice : Maybe CashPrice
    , exchangeRate : Maybe ExchangeRate
    , floatingInterestRate : Maybe FloatingInterestRate
    }


type alias CashPrice =
    { grossPrice : Maybe ActualPrice
    , cleanNetPrice : Maybe ActualPrice
    , netPrice : Maybe ActualPrice
    , accruedInterest : Maybe Number
    , cashflowAmount : Maybe Money
    }


type alias Money =
    { currency : Currency
    , amount : Amount
    }


type alias ExchangeRate =
    { quotedCurrencyPair : QuotedCurrencyPair {}
    , rate : Number
    , spotRate : Maybe Number
    , forwardPoints : Maybe Number
    , pointValue : Maybe Number
    , crossRate : List CrossRate
    }


type alias QuotedCurrencyPair a =
    { a
        | currency1 : Currency
        , currency2 : Currency
        , quoteBasis : QuoteBasisEnum
    }


type alias CrossRate =
    QuotedCurrencyPair
        { rate : Number
        , spotRate : Maybe Number
        , forwardPoints : Maybe Number
        }


type alias ActualPrice =
    { currency : Maybe Currency
    , amount : Number
    , priceExpression : PriceExpressionEnum
    }


type alias FixedInterestRate =
    { rate : Number
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


type alias NaturalPerson =
    { honorific : Maybe String
    , firstName : String
    , middleName : List String
    , initial : List String
    , surname : String
    , suffix : Maybe String
    , dateOfBirth : Maybe LocalDate
    }


type alias TradableProduct =
    { product : Product
    , quantityNotation : Nonempty QuantityNotation
    , priceNotation : Nonempty PriceNotation
    , counterparty : ( Counterparty, Counterparty )
    , ancillaryParty : List AncillaryParty
    , adjustment : Maybe NotionalAdjustmentEnum
    }


type alias Counterparty =
    { role : CounterpartyRoleEnum
    , partyReference : Party
    }


type alias AncillaryParty =
    { role : AncillaryRoleEnum
    , partyReference : Nonempty Party
    , onBehalfOf : Maybe CounterpartyRoleEnum
    }


type alias QuantityNotation =
    { quantity : NonNegativeQuantity
    , assetIdentifier : AssetIdentifier
    }


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
    { fixedRate : List Number
    , floatingRate : List Number
    }



-- Report --


type alias Report =
    { price : Number

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
    , quantity : Amount

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


runReport : List Trade -> List Report
runReport trades =
    List.filterMap mapTrade trades


mapTrade : Trade -> Maybe Report
mapTrade trade =
    let
        -- What should happen if any of the optional prices are not present?  Skip or error?
        price =
            priceOf trade

        quantity =
            trade.tradableProduct.quantityNotation |> Nonempty.head |> .quantity |> .amount
    in
    price
        |> Maybe.map (\p -> Report p quantity)


assetIdentifier : Maybe ProductIdentifier -> Maybe Currency -> Maybe FloatingRateOption -> Result String AssetIdentifier
assetIdentifier mProductId mCurrency mRateOption =
    let
        isValid =
            case ( mProductId, mCurrency, mRateOption ) of
                ( Just p, Nothing, Nothing ) ->
                    True

                ( Nothing, Just _, Nothing ) ->
                    True

                ( Nothing, Nothing, Just p ) ->
                    True

                _ ->
                    False
    in
    if isValid then
        Ok (AssetIdentifier mProductId mCurrency mRateOption)

    else
        Err "condition: one-of"


priceOf : Trade -> Maybe Number
priceOf trade =
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
fixedFixedPrice : Trade -> Maybe Number
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


fixedFloatPrice : Trade -> Maybe Number
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


basisSwapPrice : Trade -> Maybe Number
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


cdsPrice : Trade -> Maybe Number
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
