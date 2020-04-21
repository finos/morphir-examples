const readline = require('readline')
const http = require('http')

const rl = readline.createInterface({
	input: process.stdin,
	output: process.stdout
})

function ask() {

	rl.question('Topic to publish message to: ', topic => {

		rl.question('JSON message to publish: \n', msg => {

			const options = {
				hostname: 'localhost',
				port: 3500,
				path: `/v1.0/publish/${topic}`,
				method: 'POST',
				headers: {
					'Content-Type': 'application/json'
				}
			} 

			const req = http.request(options, (res) => {
				console.log(`STATUS: ${res.statusCode}`) 
				console.log(`HEADERS: ${JSON.stringify(res.headers)}`) 
				res.setEncoding('utf8') 
				res.on('data', (chunk) => {
					console.log(`BODY: ${chunk}`) 
				}) 
				res.on('end', () => {
					console.log('Message sent!')
					ask()
				}) 
			}) 

			req.on('error', (e) => {
				console.error(`problem with request: ${e.message}`)
				console.log("Try again: \n")
				ask()
			}) 

			req.write(msg)
			req.end()

		})
	})
}

console.log("Json message publisher. Dapr URL: 'localhost/3500/v1.0/publish/<topic>' \n")
ask()