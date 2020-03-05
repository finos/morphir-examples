module Morphir.Sample.Rules.RuleSet exposing (Trade, Category, ruleSet)


import String exposing (startsWith)
import SDK.Rule exposing (..)


{-| The input to the rule set is usually represented with a record type where each field
corresponds to a fact in the fact set in traditional rule engine terms.
-}
type alias Trade =
    { side : Side
    , entityCode : String
    , account : String
    }


{-| The result of the rule set can be any type. In this case we simply enumerate the possible 
classifications of a trade.
-}
type Category
    = StreetBorrow
    | BookBorrow
    | StreetLoan
    | BookLoan


{-| A rule set is represented as a list of partial functions. Each entry in the rule set is
created using the same helper function that turns the list of predicates into a single predicate
and also specifies the output of the rule. This provides an easy to read tabular format for
the rule set while still supporting very complex matching rules if needed.

Using the power of functional programming we can go beyond simple exact matches and apply more
complex matching rules such as `noneOf`, `anyOf` or `startsWith` directly in the decision table.
-}
ruleSet : RuleSet Trade Category
ruleSet =
    RuleSet
        --      Side        Entity Code                     Account             Category
        [ rule  Borrow      (noneOf [ "12345", "23456" ])   (startsWith "00")   StreetBorrow
        , rule  Borrow      any                             any                 BookBorrow
        , rule  Loan        (anyOf [ "00110", "22556" ])    any                 StreetLoan
        , rule  Loan        any                             any                 BookLoan
        ]


{-| Utility function that defines the specific behavior of rules. Inputs are chosen explicitly to
make rule definition easier and cleaner by using either a specific value to match against or a predicate
function for flexibility.
-}
rule : Side -> (String -> Bool) -> (String -> Bool) -> Category -> Trade -> Maybe Category
rule side matchEntityCode matchAccount category trade =
    if (side == trade.side) && (matchEntityCode trade.entityCode) && (matchAccount trade.account) then
        Just category
    else
        Nothing            


{-| Utility type to describe which side the trade is on.
-}
type Side
    = Borrow
    | Loan        