# LCR - Regulatory Reporting
This project is an example of using modeling to succinctly define business concepts centrally for use in various execution contexts.  It is a series of calculations that would be used as a source for code-generating libraries that firm's would use in their systems.  Code-generation could range from generic generation to target languages to specialized generation to match existing legacy systems.  By defining the rules in a language like Elm, rule owners can take advantage of the precision and also provide a suite of verification test.

The calculation in this sample comes from the U.S. LCR specification.  The LCR is an example of the type of regulatory reporting that is common through out the financial industry.  Historically, regulatory bodies publish lengthy specifications in the form of legal documents along with a set of accompanying helper documents and spreadsheets. 
These get interpreted by a financial institution's legal and business experts into another set of documents.  Next a set of business analysists attempt to map the concepts to their firm's business systems.  Finally, developers attempt to translate these into software.  There is a huge potential for interpretation drift and misunderstanding and the whole process takes a great deal of time and effort.  A huge portion of these regulations are categorization rules and mathematical calculations.  There is much potential benefit for all parties to take these regulations in the form of declarative models that could be tested independently and interpreted automatically onto internal systems.  This project demostrates how a declarative model of regulatory rules could potential be delivered throughout the industry.

## LCR Rules
The U.S. LCR rules are specified and supported in a set of documents:
* https://www.govinfo.gov/content/pkg/FR-2014-10-10/pdf/2014-22520.pdf
* https://www.federalreserve.gov/reportforms/forms/FR_2052a20190331_f.pdf
* https://www.occ.gov/news-issuances/bulletins/2014/bulletin-2014-51.html
* https://www.occ.gov/topics/supervision-and-examination/capital-markets/balance-sheet-management/liquidity/Basel-III-LCR-Formulas.pdf

This project implements a subset of the the rules pertaining to 5G and LCR.  The 5G is concerned with categorizing asset flows so that they can be appropriately handled in the various calculations.  Handling is usually in the form of inclusing in different calculated fields and applying weights to the category.  The LCR (high quality liquid asset amount / total net cash flow amount) is then calculated as a ratio of outflows to inflows and is one of the factors in determining the institution's health.

## Code Structure
* *[Basics](Basics.elm)* - Various common types and the such.
* *[Calculations](Calculations.elm)* - The LCR and 5G calculations.
* *[Flows](Flows.elm)* - A common structure for the various flows.
* *[Inflows](Inflows.elm)* - The rules for categorizing different types of inflows.
* *[Outflows](Outflows.elm)* - The rules for categorizing different types of outflows.
* *[MaturityBucket](MaturityBucket.elm)* - Some arcane rules for grouping flows into buckets based on their maturity date.  The LCR is only concerned with maturity dates up to 30 days. This is all relative to a given date that must be supplied by the caller.
* *[Product](Product.elm)* - The minimal product info needed by these rules.  Note that whether a product is HQLA is determined by another set of rules that firms must manage to more specs.  There's some talk of making the issuer determine them.  For this purpose, we'll assume this has been determined upstream.
* *[Rules](Rules.elm)* - The structure and functions for managing flow rules.
