# Install Morphir

For this tutorial we'll use the Elm frontend to write our Morphir model.  To install, ensure you have NPM installed. 

Run:
```
npm install -g morphir-elm
```

Next we'll setup a new project.
```
mkdir rentals
cd rentals
```

Next we'll write setup the  Morphir project and configuration file, morphir.json
```
mkdir src
echo '{ "name": "Morphir.Example.App", "sourceDirectory": "src", "exposedModules": [ ] }' > morphir.json
```

We don't need Elm, but it can help with other program tasks. If you want to install Elm do:
```
npm install -g elm
elm init
```


[Home](../readme.md) | [Prev](../readme.md) | [Next](step_1_first_logic/readme.md)
