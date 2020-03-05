# Samples
These are samples of various flavors of Morphir models (rewritten into pure Elm).

### LCR
This is an example of pure rules processing.  There are a large number of such projects and often the business logic needs to be shared across systems (things like account and asset categorization).  The standard approach is to share this via enriched data feeds from one system to the other, resulting in a complex web of feed dependencies.  Attempts have been made to share libraries.  These usually fail due to the fact that classes and technologies differ greatly across systems and library version management across teams becomes an extreme burden.  To solve this problem, Morphir takes the approach of sharing the models, including logic, and allowing teams to manage the code generation into their respective technologies as needed.  Morphir provides generic Java code generation for free for those who can use it.

### Apps
These are examples of full low-code style application definitions.  They require a abstraction level above base Morphir (or Elm) meaning that we apply specialized backends to process them.  The goal is to process them into full distributed systems using both internal infrastructure tools, public cloud, or others.  They would still be processed to the standard set of transpiled languages using the basic code generation, so are still useful without the specialized generators.
