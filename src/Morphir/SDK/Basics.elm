module Morphir.SDK.Basics exposing
  ( Int8, Int16, Int32, Int64, Float32, Float64, Decimal
  , add, sub, mul, fdiv, idiv, pow
  , toDecimal, round, floor, ceiling, truncate
  , eq, neq
  , lt, gt, le, ge, max, min, compare, Order
  , not, and, or, xor
  , append
  , modBy, remainderBy, negate, abs, clamp, sqrt
  , toString
  , identity, always, pipeLeft, pipeRight, composeLeft, composeRight
  ) 


{-| Tons of useful functions that get imported by default.
# Math
@docs Int, Decimal, add, sub, mul, fdiv, idiv, pow
# Int to Decimal / Decimal to Int
@docs toDecimal, round, floor, ceiling, truncate
# Equality
@docs eq, neq
# Comparison
These functions only work on `comparable` types. This includes numbers,
characters, strings, lists of comparable things, and tuples of comparable
things.
@docs lt, gt, le, ge, max, min, compare, Order
# Booleans
@docs Bool, not, and, or, xor
# Append Strings and Lists
@docs append
# Fancier Math
@docs modBy, remainderBy, negate, abs, clamp, sqrt
# Function Helpers
@docs identity, always, apL, apR, composeL, composeR
-}

import Morphir.Core.Native exposing (Native, native)
import Morphir.Core.Annotation exposing (undefined)

-- MATHEMATICS


{-| Represents an 8 bit integer value.
-}
type alias Int8 =
    Native Int


{-| Represents a 16 bit integer value.
-}
type alias Int16 =
    Native Int


{-| Represents a 32 bit integer value.
-}
type alias Int32 =
    Native Int


{-| Represents a 64 bit integer value.
-}
type alias Int64 =
    Native Int


{-| Represents a 32 bit floating-point value.
-}
type alias Float32 =
    Native Float


{-| Represents a 64 bit floating-point value.
-}
type alias Float64 =
    Native Float


{-| Represents a Decimal number. Backed by Float in Elm for simplicity but
in all other backends it uses decimal arithmetices as expected.
-}
type alias Decimal = 
  Native Float


{-| Add two numbers. The `number` type variable means this operation can be
specialized to `Int -> Int -> Int` or to `Float -> Float -> Float`. So you
can do things like this:
    3002 + 4004 == 7006  -- all ints
    3.14 + 3.14 == 6.28  -- all floats
You _cannot_ add an `Int` and a `Float` directly though. Use functions like
[toFloat](#toFloat) or [round](#round) to convert both values to the same type.
So if you needed to add a list length to a `Float` for some reason, you
could say one of these:
    3.14 + toFloat (List.length [1,2,3]) == 6.14
    round 3.14 + List.length [1,2,3]     == 6
**Note:** Languages like Java and JavaScript automatically convert `Int` values
to `Float` values when you mix and match. This can make it difficult to be sure
exactly what type of number you are dealing with. When you try to _infer_ these
conversions (as Scala does) it can be even more confusing. Elm has opted for a
design that makes all conversions explicit.
-}
add : number -> number -> number
add a b =
  native (a + b)


{-| Subtract numbers like `4 - 3 == 1`.
See [`(+)`](#+) for docs on the `number` type variable.
-}
sub : number -> number -> number
sub a b =
  native (a - b)


{-| Multiply numbers like `2 * 3 == 6`.
See [`(+)`](#+) for docs on the `number` type variable.
-}
mul : number -> number -> number
mul a b =
  native (a * b)


{-| Floating-point division:
    3.14 / 2 == 1.57
-}
fdiv : rational -> rational -> rational
fdiv a b =
  undefined


{-| Integer division:
    3 // 2 == 1
Notice that the remainder is discarded.
-}
idiv : Int -> Int -> Int
idiv a b =
  native (a // b)


{-| Exponentiation
    3^2 == 9
    3^3 == 27
-}
pow : number -> number -> number
pow a b =
  native (a ^ b)



-- INT TO DECIMAL / DECIMAL TO INT


{-| Convert an integer into a decimal. Useful when mixing `Int` and `Decimal`
values like this:
    halfOf : Int -> Decimal
    halfOf number =
      toDecimal number / 2
-}
toDecimal : Int -> Decimal
toDecimal a =
  native (Basics.toFloat a)


{-| Turn any kind of value into a string. When you view the resulting string
with `Text.fromString` it should look just like the value it came from.

    toString 42 == "42"
    toString [1,2] == "[1,2]"
    toString "he said, \"hi\"" == "\"he said, \\\"hi\\\"\""
-}
toString : a -> String
toString a =
  native (Debug.toString a)

{-| Round a number to the nearest integer.
    round 1.0 == 1
    round 1.2 == 1
    round 1.5 == 2
    round 1.8 == 2
    round -1.2 == -1
    round -1.5 == -1
    round -1.8 == -2
-}
round : Decimal -> Int
round a =
  native (Basics.round a)


{-| Floor function, rounding down.
    floor 1.0 == 1
    floor 1.2 == 1
    floor 1.5 == 1
    floor 1.8 == 1
    floor -1.2 == -2
    floor -1.5 == -2
    floor -1.8 == -2
-}
floor : Decimal -> Int
floor a =
  native (Basics.floor a)


{-| Ceiling function, rounding up.
    ceiling 1.0 == 1
    ceiling 1.2 == 2
    ceiling 1.5 == 2
    ceiling 1.8 == 2
    ceiling -1.2 == -1
    ceiling -1.5 == -1
    ceiling -1.8 == -1
-}
ceiling : Decimal -> Int
ceiling a =
  native (Basics.ceiling a)


{-| Truncate a number, rounding towards zero.
    truncate 1.0 == 1
    truncate 1.2 == 1
    truncate 1.5 == 1
    truncate 1.8 == 1
    truncate -1.2 == -1
    truncate -1.5 == -1
    truncate -1.8 == -1
-}
truncate : Decimal -> Int
truncate a =
  native (Basics.truncate a)



-- EQUALITY


{-| Check if values are &ldquo;the same&rdquo;.
**Note:** Elm uses structural equality on tuples, records, and user-defined
union types. This means the values `(3, 4)` and `(3, 4)` are definitely equal.
This is not true in languages like JavaScript that use reference equality on
objects.
**Note:** Equality (in the Elm sense) is not possible for certain types. For
example, the functions `(\n -> n + 1)` and `(\n -> 1 + n)` are &ldquo;the
same&rdquo; but detecting this in general is [undecidable][]. In a future
release, the compiler will detect when `(==)` is used with problematic
types and provide a helpful error message. This will require quite serious
infrastructure work that makes sense to batch with another big project, so the
stopgap is to crash as quickly as possible. Problematic types include functions
and JavaScript values like `Json.Encode.Value` which could contain functions
if passed through a port.
[undecidable]: https://en.wikipedia.org/wiki/Undecidable_problem
-}
eq : a -> a -> Bool
eq a b =
  native (a == b)


{-| Check if values are not &ldquo;the same&rdquo;.
So `(a /= b)` is the same as `(not (a == b))`.
-}
neq : a -> a -> Bool
neq a b =
  native (a /= b) 



-- COMPARISONS


{-|-}
lt : comparable -> comparable -> Bool
lt a b =
  native (a < b)


{-|-}
gt : comparable -> comparable -> Bool
gt a b =
  native (a > b)


{-|-}
le : comparable -> comparable -> Bool
le a b =
  native (a <= b)


{-|-}
ge : comparable -> comparable -> Bool
ge a b =
  native (a >= b)


{-| Find the smaller of two comparables.
    min 42 12345678 == 42
    min "abc" "xyz" == "abc"
-}
min : comparable -> comparable -> comparable
min x y =
  native (Basics.min x y)


{-| Find the larger of two comparables.
    max 42 12345678 == 12345678
    max "abc" "xyz" == "xyz"
-}
max : comparable -> comparable -> comparable
max x y =
  native (Basics.max x y)


{-| Compare any two comparable values. Comparable values include `String`,
`Char`, `Int`, `Float`, or a list or tuple containing comparable values. These
are also the only values that work as `Dict` keys or `Set` members.
    compare 3 4 == LT
    compare 4 4 == EQ
    compare 5 4 == GT
-}
compare : comparable -> comparable -> Order
compare a b =
  native (Basics.compare a b)


{-| Represents the relative ordering of two things.
The relations are less than, equal to, and greater than.
-}
type alias Order = 
  Native Basics.Order



-- BOOLEANS



{-| Negate a boolean value.
    not True == False
    not False == True
-}
not : Bool -> Bool
not a =
  native (Basics.not a)


{-| The logical AND operator. `True` if both inputs are `True`.
    True  && True  == True
    True  && False == False
    False && True  == False
    False && False == False
**Note:** When used in the infix position, like `(left && right)`, the operator
short-circuits. This means if `left` is `False` we do not bother evaluating `right`
and just return `False` overall.
-}
and : Bool -> Bool -> Bool
and a b =
  native (a && b)


{-| The logical OR operator. `True` if one or both inputs are `True`.
    True  || True  == True
    True  || False == True
    False || True  == True
    False || False == False
**Note:** When used in the infix position, like `(left || right)`, the operator
short-circuits. This means if `left` is `True` we do not bother evaluating `right`
and just return `True` overall.
-}
or : Bool -> Bool -> Bool
or a b =
  native (a || b)


{-| The exclusive-or operator. `True` if exactly one input is `True`.
    xor True  True  == False
    xor True  False == True
    xor False True  == True
    xor False False == False
-}
xor : Bool -> Bool -> Bool
xor a b =
  native (Basics.xor a b)



-- APPEND


{-| Put two appendable things together. This includes strings, lists, and text.
    "hello" ++ "world" == "helloworld"
    [1,1,2] ++ [3,5,8] == [1,1,2,3,5,8]
-}
append : appendable -> appendable -> appendable
append a b =
  native (a ++ b)



-- FANCIER MATH

{-| Perform [modular arithmetic](https://en.wikipedia.org/wiki/Modular_arithmetic).
A common trick is to use (n mod 2) to detect even and odd numbers:
    modBy 2 0 == 0
    modBy 2 1 == 1
    modBy 2 2 == 0
    modBy 2 3 == 1
Our `modBy` function works in the typical mathematical way when you run into
negative numbers:
    List.map (modBy 4) [ -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5 ]
    --                 [  3,  0,  1,  2,  3,  0,  1,  2,  3,  0,  1 ]
Use [`remainderBy`](#remainderBy) for a different treatment of negative numbers,
or read Daan Leijen’s [Division and Modulus for Computer Scientists][dm] for more
information.
[dm]: https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/divmodnote-letter.pdf
-}
modBy : Int -> Int -> Int
modBy a b =
  native (Basics.modBy a b)


{-| Get the remainder after division. Here are bunch of examples of dividing by four:
    List.map (remainderBy 4) [ -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5 ]
    --                       [ -1,  0, -3, -2, -1,  0,  1,  2,  3,  0,  1 ]
Use [`modBy`](#modBy) for a different treatment of negative numbers,
or read Daan Leijen’s [Division and Modulus for Computer Scientists][dm] for more
information.
[dm]: https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/divmodnote-letter.pdf
-}
remainderBy : Int -> Int -> Int
remainderBy a b =
  native (Basics.remainderBy a b)


{-| Negate a number.

    negate 42 == -42
    negate -42 == 42
    negate 0 == 0
-}
negate : number -> number
negate n =
  native (Basics.negate n)


{-| Get the [absolute value][abs] of a number.
    abs 16   == 16
    abs -4   == 4
    abs -8.5 == 8.5
    abs 3.14 == 3.14
[abs]: https://en.wikipedia.org/wiki/Absolute_value
-}
abs : number -> number
abs n =
  native (Basics.abs n)


{-| Clamps a number within a given range. With the expression
`clamp 100 200 x` the results are as follows:
    100     if x < 100
     x      if 100 <= x < 200
    200     if 200 <= x
-}
clamp : number -> number -> number -> number
clamp low high number =
  native (Basics.clamp low high number)


{-| Take the square root of a number.
    sqrt  4 == 2
    sqrt  9 == 3
    sqrt 16 == 4
    sqrt 25 == 5
-}
sqrt : Decimal -> Decimal
sqrt a =
  native (Basics.sqrt a)



-- FUNCTION HELPERS


{-| Function composition, passing results along in the suggested direction. For
example, the following code checks if the square root of a number is odd:
    not << isEven << sqrt
You can think of this operator as equivalent to the following:
    (g << f)  ==  (\x -> g (f x))
So our example expands out to something like this:
    \n -> not (isEven (sqrt n))
-}
composeLeft : (b -> c) -> (a -> b) -> (a -> c)
composeLeft g f x =
  g (f x)


{-| Function composition, passing results along in the suggested direction. For
example, the following code checks if the square root of a number is odd:
    sqrt >> isEven >> not
-}
composeRight : (a -> b) -> (b -> c) -> (a -> c)
composeRight f g x =
  g (f x)


{-| Saying `x |> f` is exactly the same as `f x`.
It is called the “pipe” operator because it lets you write “pipelined” code.
For example, say we have a `sanitize` function for turning user input into
integers:
    -- BEFORE
    sanitize : String -> Maybe Int
    sanitize input =
      String.toInt (String.trim input)
We can rewrite it like this:
    -- AFTER
    sanitize : String -> Maybe Int
    sanitize input =
      input
        |> String.trim
        |> String.toInt
Totally equivalent! I recommend trying to rewrite code that uses `x |> f`
into code like `f x` until there are no pipes left. That can help you build
your intuition.
**Note:** This can be overused! I think folks find it quite neat, but when you
have three or four steps, the code often gets clearer if you break out a
top-level helper function. Now the transformation has a name. The arguments are
named. It has a type annotation. It is much more self-documenting that way!
Testing the logic gets easier too. Nice side benefit!
-}
pipeRight : a -> (a -> b) -> b
pipeRight x f =
  f x


{-| Saying `f <| x` is exactly the same as `f x`.
It can help you avoid parentheses, which can be nice sometimes. Maybe you want
to apply a function to a `case` expression? That sort of thing.
-}
pipeLeft : (a -> b) -> a -> b
pipeLeft f x =
  f x


{-| Given a value, returns exactly the same value. This is called
[the identity function](https://en.wikipedia.org/wiki/Identity_function).
-}
identity : a -> a
identity x =
  x


{-| Create a function that *always* returns the same value. Useful with
functions like `map`:
    List.map (always 0) [1,2,3,4,5] == [0,0,0,0,0]
    -- List.map (\_ -> 0) [1,2,3,4,5] == [0,0,0,0,0]
    -- always = (\x _ -> x)
-}
always : a -> b -> a
always a _ =
  a