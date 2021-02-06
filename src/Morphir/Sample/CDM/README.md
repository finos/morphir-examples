# ISDA CDM - Industry Standards
The ISDA Common Domain Model (CDM) 2.0 specification provides a standard blueprint for managing the life cycle of various 
traded products.  More background can be found at the [ISDA CDM Factsheet](https://www.isda.org/2018/11/22/isda-cdm-factsheet/) 
and [Rosetta CDM](https://docs.rosetta-technology.io/cdm/readme.html).

The CDM is defined in the [Rosetta DSL](https://docs.rosetta-technology.io/dsl/index.html).  This example implements
a portion of CDM specification in Morphir to demonstrate how a DSL can be supported by the Morphir IR.  There are a few 
possible approaches to doing this, including compiling the DSL directly into the Morphir IR or, alternatively, transpiling
the DSL into Elm, which is then compiled down to the Morphir IR.  For this example, we take that latter approach to better
demonstrate how the concepts translate between the two languages.

This example explores the [Price spec of MiFIR RTS_22](https://ui.rosetta-technology.io/#/system/read-only-CDM) (requires login).
The implementation can be found at [RTS22](RTS22.elm).