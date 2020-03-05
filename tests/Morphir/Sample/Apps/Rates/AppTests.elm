module Morphir.Sample.Apps.Rates.AppTests exposing (..)

{-| Rates calculation tests.
-}


import Expect
import Test exposing (Test, test, describe)
import Sample.Rates.App exposing (..)
import Sample.Rate exposing (..)



calculateRatesTests : Test
calculateRatesTests =
    let
        withinThreshold =
            Expect.within (Expect.Absolute 0.000001)

        scenario name benchmark gc price deals expected =
            test name <|
                \_ ->
                    calculateRates benchmark gc price deals
                        |> Expect.all 
                            [ .borrowRate >> maybe withinThreshold expected.borrowRate
                            , .loanRate >> maybe withinThreshold expected.loanRate
                            , .spread >> maybe withinThreshold expected.spread
                            ]
    in
    describe "Product rate calculation"
        [ scenario "No deals should generate no rates" 1.0 1.0 1.0 
            [] 
            { loanRate = Nothing
            , borrowRate = Nothing
            , spread = Nothing
            }
        , scenario "One borrow should generate a borrow rate and no spread" 1.0 1.0 1.0 
            [ Deal Borrow 1500 (Fee 0.2) 
            ] 
            { loanRate = Nothing
            , borrowRate = Just 0.2
            , spread = Nothing
            }
        , scenario "One loan should generate a loan rate and no spread" 1.0 1.0 1.0 
            [ Deal Loan 1500 (Fee 0.3) 
            ] 
            { loanRate = Just 0.3
            , borrowRate = Nothing
            , spread = Nothing
            }
        , scenario "One borrow and one loan should generate a loan rate, a borrow rate and a spread" 1.0 1.0 1.0 
            [ Deal Borrow 1500 (Fee 0.2)
            , Deal Loan 1500 (Fee 0.3) 
            ] 
            { loanRate = Just 0.3
            , borrowRate = Just 0.2
            , spread = Just 0.1
            }
        ]


maybe : (a -> a -> Expect.Expectation) -> Maybe a -> Maybe a -> Expect.Expectation
maybe f maybeExpected maybeValue =
    case maybeExpected of
        Just expected ->
            case maybeValue of
                Just value ->
                    f expected value

                Nothing ->
                    Expect.fail "Expected Just but found Nothing"

        Nothing ->
            case maybeValue of
                Just value ->
                    Expect.fail "Expected Nothing but found Just"

                Nothing ->
                    Expect.pass
