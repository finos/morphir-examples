# Application Modeling
One of the high goals of application development is to allow developers to simply focus on the application's business logic without distraction from technical concerns.  Through the years we've tried various approaches to this, with the most common being development teams taking building blocks from the industry and infrastructure teams in the form of frameworks, platforms, and libraries and composing those into applications by programming to their APIs.  As anyone who's lived in an enterprise environment can attest to, a major issue with this approach is that each application development team needs to keep their project(s) up-to-date with the latest trends.  This is *not* a trivial task and is the source of millions upon millions of dollars of spending.

What if we reversed this flow so that application development teams modeled their application business logic purely and passed that to the infrastructure, along with some requirements, for the infrastructure to decide the best way to run it?  This is the main premis of [Functional Domain Modeling](http://jive.ms.com/groups/functional-domain-modeling).  This would achieve that high goal of letting app developers focus on business value while also giving infrastructure a new level of control and flexibility.  Let's take a look at how this would work?

## Modeling the business
How many times have you joined a new project and tried to figure out what the application does and why by looking at the source code; only to be lost in implementation details to the point of losing track of the application's original purpose?  There's a common culprit here that lurks in the tools we commonly use.  This is, when implementing software with a General Purpose Language (GPL), like Java or Python, the business concepts usually become tightly coupled with the execution.  This makes the system difficult to comprehend *and* poses significant impedements to migrating to different technologies.  Modeling addresses this issue by having developers describe the application's business concepts declaratively such that it enforces a clean separation of business and technology.  So what does this look like?  The applications in the [Apps](../Apps) folder demonstrate a set of modeled applications using the [Elm programming language](http://elm-lang.org).  Specifically, we'll look at a classic sample front-to-back set of applications:

* **[BooksAndRecords](BooksAndRecords)**: This is the core system for storing trade records and managing the book.  It has no dependencies.
* **[Order](Order)**: This is the order processing system.  It accepts trade requests from traders or algorithms, applies verification, and makes fulfillment decisions.  In the event of a trade confirmation, it books that fact into BooksAndRecords.  So it depends on BooksAndRecords.
* **[Trader](Trader)**: This is a trading algorithm.  It monitors the market against the current deals in BooksAndRecords and makes trading decisions based on that.  In order to execute a trade, it makes a request into Orders.  So it depends on both BooksAndRecords and Order.

### Business concepts
An application's business concepts are it's most important asset.  We're capturing those concepts in Elm's data types and functions.  For example, the core data concept in BooksAndRecords is its [Deal](BooksAndRecords/Deal.elm):

```elm
type alias ID = String
type alias Value = Decimal

type alias Deal =
    { id : ID
    , product : Product.ID
    , price : Price
    , quantity : Quantity
    }

value : Deal -> Value
value deal =
    deal.price * (toFloat deal.quantity)
```
This model concisely defines the data and the deal-specific calculation of ```value = price * quantity```.  The main point int looking through the code is that it's all simple data structures and functions.  It is not obscured by copmlex class hierarchies, persistence logic, serialization, etc.  In terms of the [Hexagonal Architecture](https://en.wikipedia.org/wiki/Hexagonal_architecture_(software)) it is the Application Core.  The usage of Elm as the modeling language ensures that because it doesn't allow those things.

### Application domain concepts
[Domain-drive desgin (DDD)](https://en.wikipedia.org/wiki/Domain-driven_design) is big on defining an application's boundaries in terms of domains.  Our applications depend on data that is either owned by the application or owned by another.  DDD likes to calls these Bounded Context, and our apps have them.  Let's look at the [Order App](Order/App.elm) for an example:

```elm
type alias API =
    { buy : Order.BuyRequest -> Result StateFault Event
    , sell : Order.SellRequest -> Result StateFault Event
    }

type alias LocalState =
    { buys : Dict Order.ID BuyRecord
    , sells : Dict Order.ID SellRecord
    }

type alias RemoteState =
    { bookBuy : Order.ID -> Product.ID -> Price -> Int -> Cmd Event
    , bookSell : Order.ID -> Price -> Cmd Event
    , getDeal : Order.ID -> Maybe Deal.Deal
    , getMarketPrice : Product.ID -> Maybe Price
    , getStartOfDayPosition : Product.ID -> Maybe Quantity
    }
```
This is basically stating the Order system:
* Exposes an API for external applications to send buy and sell requests.
* Keeps track of the list of buy and sell requests and their current state.
* Depends on data and APIs from external systems, such as the [BooksAndRecords](BooksAndRecords) API to submit trade facts and the current market price to decide whether to accept a trade request.

Notice here that the model defines the need for application concepts such as persistent state.  What it doesn't do is dictate how that state is implemented.  It could be via event sourcing, a relational database, a distributed cache, or some future approach.

Another DDD concept is the [Anti-Corruption Layer (ACL)](https://docs.microsoft.com/en-us/azure/architecture/patterns/anti-corruption-layer).  An example from [Order's ACL](Order/ACL.elm) shows how to map from Order concepts into BooksAndRecords:

```elm
bookBuy : BookingApp.App -> Order.ID -> Product.ID -> Price -> Quantity -> Cmd App.Event
bookBuy bookingApp orderId productId price quantity =
    bookingApp 
        |> sendCommand 
            (\api -> api.openDeal orderId productId price quantity) 
            (\fault -> [])
```
You might argue this isn't a business concept so shouldn't be in the model. It is a bit fuzzy and we err on the side of thinking that mapping between business concept domains is also a business concept.

#### In summary
The noteable application concepts in these modules include:
* Defining the **business concepts** in declarative data types and functions.
* Exposing an **API** to other applications.
* Keeping **internal state** across requests.
* Depending on a **stream of events** from other applications.

## Bringing it to the real world
So, this is great.  How does it execute?  Through a healty amount of automation (aka: code generation or Dev Bots) as described below.

### Source code
First and foremost, we need executable code.  We have some options here.  The native Elm compiler compiles down to JavaScript, so we can use nodejs to run the code.  Alternatively, the fact that this is a declarative model means it can be processed and cross-compiled to another language.  The choice depends on your environment, so we'll use Java as the most common.

### API
This is where things get interesting.  The applications models have all of the information that's required to generate API specifications and implementation for any of the latest API standards.  For instance, we will want to generate a complete OpenAPI specification for integration with Firm's API standard.  That opens client/server generation in a variety of languages.  Alternatively, given the Firm's Spring Boot guidance, we will generate Java classes directly with the appropriate annotations. One interesting question regarding Firm practices is whether the API should be via a synchronous REST endpoint or asynchronous MQ endpoint.  This type of decision usually has to be answered early on, but we can save it for later.

### Pub/Sub
The model defines a few points of event processing of streams from external systems.  For example, market data into Trader:
```elm
type alias RemoteState =
    { trackMarketPrices : Sub Event
    , getDeals : Product.ID -> List Deal.Deal
    , sell : List Deal.ID -> Cmd Event
    }
```
It's pretty straight-forward to realize that ```trackMarketPrices``` can map to a Kafka topic and then to generate that endpoint.

### Constraints and verification
Contract-driven development seeks to optimize testing distributed applications by specifying contracts between the components.  These contracts can be used to generate mock services for testing so that clients don't rely on remote services being running.  The current set of contract tests relies on a sampling of test scenarios.  This is helpful, but far from complete.  FDM models contain the full constraint logic as part of the definition.  This allows the creation of mock stubs in a variety of languages that will perform the *exact* verification logic that will run in the server.  That's far better test coverage than a sampling of test cases.

## Common use cases
Why might we want to consider this approach to application development?  Let's look at how it applies to some common scenarios that have been vexing enterprise developers for years.

### Upgrading libraries and hygiene
The common enterprise approach to hygiene, like keeping up with the latest libraries, is to have the application developers periodically upgrade them as part of their normal development flow.  This runs into a few issues in the enterprise:
* *It forces teams to create tests for all of their dependent libraries*: Is the next version of serializer going to handle all of your classes and polymorphism correctly?  We've seen upgrades break enough to know that we should catch them in testing, but writing tests for all aspects of your library dependencies is a daunting task that's rarely complete enough.  So teams tend to put upgrades off until they can no longer hold off.  Which brings up:
* *Technology evolution is rarely timed well with business requirements*: It's not a fun conversation to tell your clients that delivering business value is being put hold.
* *It leaves regulations and infrastructure vulnerable to individual application teams*: Infrastructure has no direct control to enforce something like a wholesale security upgrade, leaving them vulnerable to non-compliance.
* *Many projects aren't touched after they're done*: They work, why mess with them when we've got new projects to focus on?
* *More*: There's more, but who really wants to read a list of problems...

FDM addresses the hygiene issue by introducing efficiency through automation. Performing an upgrade is just a matter of modifying the code generators. The key is that the models provide enough information to also automate full test coverage.  The combination allows the devops and infrastructure team perform wholesale upgrades and fully test every application without burdening the application development teams at all.

### Best practices and infrastructure consistency
This is really an extension of the hygiene discussion.  Firms tend to balance authoratative control with developer enablement by suggesting, but not requiring, a set of blueprints and best practices.  The goal is to establish consistency across the plant, which translates to greater efficiency and lower risk.  The reality with blueprints is that they evolve.  The projects that adopted them don't, at least not at the same pace.  So all of those environments-on-demand YAML files get out-of-date just like libraries.

FDM encodes the best practices in the automation layer (Dev Bots), which removes the burden from the application development team to keep up-to-date.

### Sharing logic
It is quite common that different and heterogenuous components of a system need to execute the same logic.  For example form validation needs to be done in Java on the server for correctness and also in TypeScript in the brower for user experience.  Or, sometimes things like categorization logic need to be shared in realtime stream processing in Java and in SQL for batch processing.  It's also possible that categorization logic needs to be consistent across completely different systems.  In these cases, teams resort to either writing duplicate code or standing up a single microservice.  The former is error prone and the latter is brittle (try calling a microservice from a SQL query).

FDM promotes a shared model approach such that shared logic can be mastered in a model that then triggers code generation into heterogenuous systems as needed.  This is more effecient, less risk, more flexible, and much more conducive understanding the system.

### Evolving technologies
* How do you try Spark if your logic is currently in stored procedures?  
* What if after testing, you determine that the data warehouse was actually much better after all?
* What happens if the business says that they want that screen the check once a day to notify them of relevant events real-time instead?
* What if it became apparent that a distributed microservice would peform much better as a library invoked from the same JVM?
* What if infrastructure did a comprehensive analysis of application network traffic and came to the conclusion that [gRpc](https://grpc.io/) would result in significant cost savings?

In the current state of application development, the business concepts are so tightly coupled to the technology choice of the moment that trialing and evolving to new technologies is an expensive undertaking.  This puts enourmous pressure on teams to *make the right technical choice upfront*.  The problem is that technology evolves so quickly that the right choice only lasts for a short window.  And when significant investment is pored into a particular technology, it's very difficult to pivot or reverse course.  The result is often that our point-in-time technology decisions end up driving the business capabilities rather than the other way around.

FDM treats core business concepts as a vital asset to be protected from the technology choice of the moment.  This translates to agility to adopt alternate technologies.  That same logic can be run in the database in SQL, in Java over an event stream, and in TypeScript in the UI.  This greatly reduces the burden that application development teams faces with *choosing the right technology*.  This, in turn, makes teams less married to the choices they make.

It also opens up new opportunities to make choices based on relevant information.  When it's easy to switch distributed microservice to collocated library or from XML to gRPC or from Spark to MemSQL, those decisions can be instrumented and automated.

### Testing
FDM focuses on describing the business concepts in a way that is processable through automation.  That ability means that we can understand enough to generate a full set of testing as well.  This is an advantage of Functional Programming that is utilized through tools such as [QuickCheck](https://hackage.haskell.org/package/QuickCheck).  Functional Programming also utilizes a much more powerful compiler that catches a huge portion of the errors that can occure in procedural languages, which is great for modeling business concepts.

## Questions
* **Does this mean app dev teams lose all control over execution?**
FDM revolves around Dev Bots - the automatic processing of models.  While Dev Bot management can be centralized and controlled, FDM promotes tools for teams to create their own Dev Bots.  Which is just a long way of saying that teams have the same control, just shifted to later in the development process.


* **Why do we need a new language instead of Java?**  Java is a general purpose language (GPL), which includes functionality outside of modeling, such as file IO, database calls, etc.  As much as we try to avoid it with fancy abstractions and approaches like Hexagonal Architecture, tight coupling of business concepts to technology eventually leaks in.  In addition, most GPLs allow developers to specify *how* something should execute, which makes figuring out *what* they want to do difficult.  A purely functional language like Elm completely prohibits such capabilities so that all that's left is a description of *what* you want to do, not *how*.  This is great for ensuring that developers treat business modeling with the care that it deservices.  It also makes processing for transpilation into other languages far easier.  It does this all without losing the expressivity that's required to describe the majority of the business problems that we face.

* **Where does testing happen?**
Models can be written in a variety of languages.  We've settled on Elm for now, which has a complete set of testing frameworks that integrate with standard SDLC.  So tests can be created in the language of the model for maximum efficiency.  In addition, much testing can be automated by analyzing and processing the model.  So even more tests can be generated in the target backend language.

* **Is this an all-or-none proposition?**
Teams can choose to model the portion of their applications that make the most sense for them.  At the simplest level, teams can simply model data and generate boilerplate code.  One level up would include modeling business logic and generating libraries in the target language of choice.  Finally, teams might choose to model the entire application as we've done in this example.

* **What's the risk if I adopt FDM then decide to go back?**
FDM generates code into a variety of languages. At any point, you can just adopt the generated code and leave the models behind.  So there is actually very little risk to trying FDM.