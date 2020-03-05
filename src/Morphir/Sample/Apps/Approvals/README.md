# Approvals

Sample model based on a real-world system that facilitates pre-approval of short sale transactions. The system
is made up of two stateful applications: one for managing the inventory for each product ([InventoryApp](Inventory/App.elm)) 
and one from managing the lifecycle of batch requests from clients ([LocateListApp](LocateList/App.elm)).

`LocateListApp` depends on `InventoryApp` to execute each individual request. The dependency and mapping between
the two apps is defined in [ACL.elm](LocateList/ACL.elm)

## Stateful Apps

Stateful apps are parameterized by 4 different types that describe how they interact with the external world
and how they manage their internal state. These are the following:

- *API* - Exposes functions that allow some external actor to initiate an action. Each function returns a result 
  that is either a failure or in case of a success an event. Internally these functions use the state to decide
  if the action should fail or succeed.
- *Event* - Events are generated as a result of sucessful actions (either external or internal) and usually result 
  in internal state changes.  
- *RemoteState* - Defines a view of the external world from the application's perspective. The application cannot 
  change the external state directly. It can oly send commands to other applications to have the state changed.
- *LocalState* - Defines the application's internal state. Only the application can directly modify it's internal
  state and modifications can only happen as a result of an event.