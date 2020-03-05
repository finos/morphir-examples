module Morphir.Sample.LCR.Counterparty exposing (..)


type alias CounterpartyId = String


type CounterpartyType 
    = Bank
    | Retail
    | SmallBusiness
    | NonFinancialCorporate
    | Sovereign
    | CentralBank
    | GovernmentSponsoredEntity
    | PublicSectorEntity
    | MultilateralDevelopmentBank
    | OtherSupranational
    | SupervisedNonBankFinancialEntity
    | DebtIssuingSpecialPurposeEntity
    | OtherFinancialEntity
    | Other


type alias Counterparty = 
    { counterpartyId : CounterpartyId
    , counterpartyType : CounterpartyType
    }
