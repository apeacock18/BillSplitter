/**
 * Logs a user in
 * @param {string} username
 * @param {string} password
 * @returns {string} userId
 *
 * Error Codes:
 * 0: User not found
 * 1: Incorrect password
 */
Parse.Cloud.define("login", function(request, response) {
    var username = request.params.username;
    var password = request.params.password;
    var query = new Parse.Query("Users");
    query.equalTo("username", username);
    query.find({
        success: function(results) {
            if(results.length == 0) {
                response.error(0);
            }
            var serverPassword = results[0].get("password");
            if(password == serverPassword) { // Authenticated
                response.success(results[0].id);
            } else { // Incorrect password
                response.error(1);
            }
        },
        error: function() {
            response.error(0); // User not found
        }
    });
});

/**
 * Retrieves the userId for a given username
 * @param {string} username - Username to query
 * @returns String userId
 * 
 * Error Codes:
 * 0: Unknown error
 * 2: Username does not exist
 */
Parse.Cloud.define("userIdFromUsername", function(request, response) {
    var username = request.params.username;
    var query = new Parse.Query("Users");
    query.equalTo("username", username);
    query.find({
        success: function(results) {
            if(results.length == 0) { // User does not exist
                response.error(2);
            } else {
                response.success(results[0].id);
            }
        },
        error: function(error) {
            response.error(0);
        }
    });
});

/**
 * Adds a user to a group
 * @param {string} userId - User to add to the group
 * @param {string} groupId - Group to add user to
 * @returns
 * 
 * Error Codes:
 * 0: Unknown error
 * 1: User is already in group
 */
Parse.Cloud.define("addUserToGroup", function(request, response) {
    var userId = request.params.userId;
    var groupId = request.params.groupId;
    var query = new Parse.Query("Groups");
    query.equalTo("objectId", groupId);
    query.first({
        success: function(result) {
            var contains = false;
            var members = result.get("members");
            if(members != null) {
	            for(var i = 0; i < members.length; i++) {
	                if(members[i] == userId) {
	                    contains = true;
	                    break;
	                }
	            }
            }
            if(contains == true) {
                response.error(2); // Group already contains user
            } else {
                // Add groupId to user
                var UserObject = Parse.Object.extend("Users");
                var user = new UserObject();
                user.id = userId;
                user.add("groups", groupId);
                user.save(null, {
                    success: function(object) {
                        // Add user as member to group
                        var GroupObject = Parse.Object.extend("Groups");
                        var group = new GroupObject();
                        group.id = groupId;
                        group.add("members", userId);

                        if(members.length != 0) {
                            var newStatuses = new Array();
                            var statuses = result.get("status");
                            for(var i = 0; i < statuses.length; i++) {
                                var serialized = statuses[i];
                                var deserialized = JSON.parse(serialized);
                                var statusData = deserialized.data;
                                var obj = new Object;
                                obj.recipient = userId;
                                obj.amount = 0.00;
                                statusData.push(obj);
                                deserialized.data = statusData;
                                newStatuses.push(JSON.stringify(deserialized));
                            }

                            var data = new Array();
                            for(var i = 0; i < members.length; i++) {
                                var obj2 = new Object;
                                obj2.recipient = members[i];
                                obj2.amount = 0.00;
                                data.push(obj2);
                            }
                            var status = new Object;
                            status.id = userId;
                            status.data = data;
                            newStatuses.push(JSON.stringify(status));

                            if(members.length == 1) {
                                var obj3 = new Object;
                                obj3.id = members[0];
                                var obj3Data = new Object;
                                obj3Data.recipient = userId;
                                obj3Data.amount = 0.00;
                                obj3.data = [obj3Data];
                                newStatuses.push(JSON.stringify(obj3));
                            }

                            group.set("status", newStatuses);
                        }

                        group.save(null, {
                            success: function(object2) {
                                var dict = {};
                                dict["user"] = object;
                                dict["group"] = object2;
                                response.success(dict);
                            },
                            error: function(error) {
                                response.error(error);
                            }
                        });
                    },
                    error: function(error) {
                        response.error(error);
                    }
                });
            }
        },
        error: function(error) {
            response.error(error);
        }
    });
});

/**
 * Removes a user from a group
 * @param {string} userId - User to remove from the group
 * @param {string} groupId - Group to remove user from
 * @returns
 * 
 * Error Codes:
 */
Parse.Cloud.define("leaveGroup", function(request, response) {
    var userId = request.params.userId;
    var groupId = request.params.groupId;

    var query = Parse.Query("Users");
    query.equalTo("objectId", userId);
    query.first({
        success: function(result) {
            result.remove("groups", groupId);

            var groupQuery = Parse.Query("Groups");
            query.equalTo("objectId", groupId);
            query.first({
                success: function(result) {
                    result.remove("members", userId);
                    if(result.get("members").length == 0) {
                        var GroupObject = Parse.Object.extend("Groups");
                        var group = new GroupObject();
                        group.id = groupId;
                        group.destroy({
                            success: function(object) {
                                // Hurray
                            },
                            error: function(object, error) {
                                // So sad
                            }
                        });
                    }
                    response.success(true);
                },
                error: function(error) {
                    response.error(error);
                }
            });
        },
        error: function(error) {
            response.error(error);
        }
    });
});

/**
 * Creates a new group
 * @param {string} name - The name for the new group
 * @returns {string} groupId
 */
Parse.Cloud.define("createGroup", function(request, response) {
    var name = request.params.name;
    var GroupObject = Parse.Object.extend("Groups");
    var group = new GroupObject();
    group.set("name", name);
    group.set("members", []);
    group.set("status", []);
    group.set("transactions", []);
    group.save(null, {
        success: function(object) {
            response.success(object.id);
        },
        error: function(error) {
            response.error(error);
        }
    });

});

/**
 * Creates a new password
 * @param {string} username
 * @param {string} password - Hashed password (SHA-512)
 * @param {string} email
 * @param {string} phoneNumber
 * @param {string} name - Full Name
 * @param {string} username - Last Name
 * @returns 
 */
Parse.Cloud.define("create", function(request, response) {
    var username = request.params.username;
    var password = request.params.password;
    var email = request.params.email;
    var phoneNumber = request.params.phoneNumber;
    var name = request.params.name;
    var UserClass = Parse.Object.extend("Users");
    var user = new UserClass();
    user.set("username", username);
    user.set("password", password);
    user.set("email", email);
    user.set("phoneNumber", phoneNumber);
    user.set("name", name);
    user.set("groups", []);
    var query = new Parse.Query("Users");
    query.equalTo("username", username);
    query.find({
        success: function(results) {
            if(results.length == 0) {
                user.save(null, {
                    success: function(object) {
                        response.success(object.id);
                    },
                    error: function(object, error) {
                        response.error(0);
                    }
                });
            } else {
                response.error(1); // User already exists
            }
        },
        error: function() {
            response.error(0); // Unknown error
        }
    });
});


/* Transactions */

/**
 * Start a transaction between group members.
 * @param {string} groupId
 * @param {string} payee - The user who should be receiving money.
 * @param {<string, double>} split - A dictionary with keys of users with values containing the percentage the user should pay. eg. {"gomeow": 25}
 * @param {double} amount - The Amount to be split.
 * @param {string} description - A description of the transaction
 * @param {string} date - A date in the format MM-dd-yyyy
 *
 * Error Codes:
 * 0: Unknown error
 * 1: Split does not add up to 100% of amount
 */
Parse.Cloud.define("newTransaction", function(request, response) {
    var groupId = request.params.groupId;
    var payee = request.params.payee;
    var split = request.params.split;
    var transactionAmount = request.params.amount;
    var date = request.params.date;
    var description = request.params.description;
    var amountToPay = new Array();
    var totalPercentage = 0;

    var transaction = new Object;
    transaction.payee = payee;
    transaction.date = date;
    transaction.amount = transactionAmount;
    transaction.description = description;
    transaction.split = split;

    /* Calculate how much each person should pay. */
    for (var userId in split) {
        if(!split.hasOwnProperty(userId)) {
            continue;
        }
        amountToPay[userId] = transactionAmount * split[userId];
        totalPercentage += split[userId];
    }

    /* Modify groups */
    var statusQuery = new Parse.Query("Groups");
    statusQuery.equalTo("objectId", groupId);
    statusQuery.first({
        success: function(result) {
            var statusArray = result.get("status");
            var newStatuses = new Array();
            for(var i = 0; i < statusArray.length; i++) {
                var status = JSON.parse(statusArray[i]);
                var statusData = status.data;
                if(status.id == payee) {
                    for(var j = 0; j < statusData.length; j++) {
                        var recipient = statusData[j].recipient;
                        if(amountToPay.hasOwnProperty(recipient)) {
                            var amount = statusData[j].amount;
                            amount -= amountToPay[recipient];
                            statusData[j].amount = amount;
                        }
                    }
                } else {
                    for(var j = 0; j < statusData.length; j++) {
                        var recipient = statusData[j].recipient;
                        if(recipient == payee) {
                            var amount = statusData[j].amount;
                            if(amount == null) {
                                amount = 0.0;
                            }
                            amount += amountToPay[status.id];
                            statusData[j].amount = amount;
                        }
                    }
                }
                newStatuses.push(JSON.stringify(status));
            }

            var GroupClass = Parse.Object.extend("Groups");
            var group = new GroupClass();
            group.set("objectId", groupId);
            group.set("status", newStatuses);
            group.add("transactions", JSON.stringify(transaction));
            group.save(null, {
                success: function(object) {
                    response.success(object);
                },
                error: function(object, error) {
                    response.error(error);
                }
            });
        },
        error: function(error) {
            response.error(error);
        }
    });
});
