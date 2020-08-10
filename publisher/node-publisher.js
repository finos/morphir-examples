/*
Copyright 2020 Morgan Stanley

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

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