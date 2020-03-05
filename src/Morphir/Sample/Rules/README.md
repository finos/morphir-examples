# Overview

Rule engines are frequently used in the financial services domain to encode various accounting and classification rules.
A rule is a combination of a predicate and an action that will be executed when the predicate is matched. In traditional
rules engines the action usually inserts new facts in the fact database. Rules are usually organized into rule sets
and when the rule set is executed in a sequential mode the engine executes the action of the first matching rule. 

This behavior can be directly encoded as a pattern-match or if-else chain in Elm. Encoding rule sets this way has many 
advantages. Most importantly the language can check if all possible inputs were handled in the code. Check the `Direct` 
example below to see how that's done.

For more complex rule sets we can use a more indirect approach where rules are explicitly encoded as standalone functions
that can be applied sequentially. Check out the `RuleSet` example below to see how that could be done.

## Rule Execution

Most rules engines execute the rules using some variation of the Rete algorithm which can efficiently evaluate large
number of predicates on the same fact set. Rete can execute more efficient than if-else chains or pattern-matches in
a programming language so you might think that but fortunately we have flexibility in how we translate our logic


## Code Structure

- *[Direct](Direct.elm)* - Shows how decition trees and decision tables can be directly encoded as pattern matches.
- *[RuleSet](RuleSet.elm)* - Shows a more complex example that allows matching by arbitrary boolean expressions 
  instead of the simple exact match or wildcard approach that decision tables have.
