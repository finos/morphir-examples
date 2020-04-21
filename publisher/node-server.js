const express = require('express')
const app = express()

app.get('/', (_req, res) => { res.send("Hello from node dapr publisher") })
app.listen(3000, () => {
	console.log("Json message publisher. Dapr URL: 'localhost/3500/v1.0/publish/<topic>' \n")
})