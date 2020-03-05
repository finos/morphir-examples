# Business Application Modeling

This module is an example of how we can go from modeling individual calculations to modeling entire business applications.
A modeled business application can be translated to a specific technology stack using a combination of code generators. This makes
it possible to move applications between various infrastructure environments without manual effort and implementation risk.
Most importantly it allows teams to build applications that run on its own proprietary infrastructure today but can be 
moved to a cloud solution without changes to the business logic.

Modeling business applications also gives us visibility into how applications interact with each other which combined with
the fine-grained control that code generators provide helps us optimize business workflows front-to-back.

## Code Structure

### Pre-trade example
- *[Shared](Shared/README.md)* - Various definitions used across multiple applications. This would normally be in a separate library but it's included here for simplicity.
- *[Upstream](Upstream/README.md)* - Interface modules that represent upstream applications. These would also be in separate libraries in the real-world but are included here for simplicity.
- *[Rates](Rates/README.md)* - Sample stateless application based on a real-world system that calculates pricing for Secutrities Lending transactions.
- *[Approvals](Approvals/README.md)* - Sample stateful application based on a real-world system that facilitates pre-approval of short sale transactions.

## Front-to-back trade example
- *[BooksAndRecords](BooksAndRecords/README.md)* - Sample books and records back office.
- *[Order](Order/README.md)* - Sample basic trading application.  Depends on BooksAndRecords to book new deals.
- *[Trader](Trader/README.md)* - Sample auto-trading application.  Depends on both to make trading decisions.


### General Module Layout

Each sample application is implemented in an `App.elm` file in a dedicated module. `App.elm` files never depend on each other directly. 
Instead dependencies are defined in the `ACL.elm` module that depends on the main `App.elm` as well as other applications. ACL stands 
for anti-corruption layer and it provides decoupling from other applications by translatine external concepts into an internal 
representation that's optimal from the perspective of the application. ACLs and also provide a declarative approach to defining 
dependencies accross applications.
