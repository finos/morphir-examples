module Morphir.SDK.Rule exposing (..)


type RuleSet a b
    = RuleSet (List (a -> Maybe b))


decide : a -> RuleSet a b -> Maybe b
decide data (RuleSet rules) =
    case rules of
        [] ->
            Nothing

        firstRule :: rest ->
            case firstRule data of
                Just result ->
                    Just result

                Nothing ->
                    decide data (RuleSet rest)


matchThenMap : (a -> Bool) -> (a -> b) -> a -> Maybe b
matchThenMap f g a =
    if f a then
        Just (g a)
    else
        Nothing    


type PriorityRuleSet a b
    = PriorityRuleSet (List ( (a -> Maybe b), Int ))


type RuleCollision a b
    = RuleCollision (RuleSet a b)


decideByPriority : a -> PriorityRuleSet a b -> Result (RuleCollision a b) (Maybe b)
decideByPriority data (PriorityRuleSet rules) =
    let
        matchingRules =
            rules
                |> List.filter
                    (\( rule, priority ) ->
                        rule data /= Nothing
                    )

        maxPriority =
            matchingRules
                |> List.map Tuple.second
                |> List.maximum
                |> Maybe.withDefault 0

        maxPriorityRules =
            matchingRules               
                |> List.filterMap
                    (\( rule, priority ) ->
                        if priority == maxPriority then
                            Just rule
                        else
                            Nothing    
                    )
    in    
    case maxPriorityRules of
        [] ->
            Ok Nothing

        [ rule ] ->
            Ok (rule data)    

        multipleRules ->
            Err (RuleCollision (RuleSet multipleRules))


any : a -> Bool
any _ =
    True


is : a -> a -> Bool
is a b =
    a == b


anyOf : List a -> a -> Bool
anyOf list a =
    List.member a list


noneOf : List a -> a -> Bool
noneOf list a =
    not (anyOf list a)    