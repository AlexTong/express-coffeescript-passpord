records = [
	{id: 1, username: 'jack', password: 'secret', displayName: 'Jack', emails: [{value: 'jack@example.com'}]},
	{id: 2, username: 'jill', password: 'birthday', displayName: 'Jill', emails: [{value: 'jill@example.com'}]}
]
exports.findById = (id, cb)->
	process.nextTick(()->
		idx = id - 1;
		if records[idx]
			cb(null, records[idx])
		else
			cb(new Error('User ' + id + ' does not exist'))
	);
exports.findByUsername = (username, cb)->
	process.nextTick(()->
		for record in records
			if (record.username == username) then return cb(null, record);

		return cb(null, null)
	);