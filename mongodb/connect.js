const MongoClient = require('mongodb').MongoClient
const assert = require('assert')

require('dotenv').config()

const { DB_USERNAME, DB_PASSWORD } = process.env

// Connection URL
const ip0='10.140.0.7'
const ip1='10.140.0.8'
const ip2='10.140.0.9'
const rs='rs'
const url = `mongodb://` +
	`${DB_USERNAME}:${DB_PASSWORD}@` +
	`${ip0}:27017,` +
	`${ip1}:27017,` +
	`${ip2}:27017/` +
	`?replicaSet=${rs}`

// Database Name
const dbName = 'test'

// Create a new MongoClient
const client = new MongoClient(url,  { useUnifiedTopology: true })

// Use connect method to connect to the Server
client.connect(function(err) {
  assert.equal(null, err)
  console.log("Connected successfully to server")

  const db = client.db(dbName)

  insertDocs(db, () => {
    client.close()
  })
})

function insertDocs (db, cb) {
  const col = db.collection('documents')
  col.insertOne({ now: Date.now() }, (err, result) => {
    if (err) {
      console.log(err)
    } else {
      console.log(result)
    }
    cb(result)
  })
}
