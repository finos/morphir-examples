module Morphir.Sample.Reg.CDM.MiFIR.Enums exposing (..)


type PriceExpressionEnum
    = AbsoluteTerms
    | PercentageOfNotional


type QuoteBasisEnum
    = Currency1PerCurrency2
    | Currency2PerCurrency1


type AccountTypeEnum
    = AccountTypeEnum
    | AggregateClient
    | Client
    | House


type NotionalAdjustmentEnum
    = Execution
    | PortfolioRebalancing
    | Standard


type CounterpartyRoleEnum
    = Party1
    | Party2


type PeriodEnum
    = D
    | W
    | M
    | Y
