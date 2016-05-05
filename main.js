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
Parse.Cloud.define("addUserToGroup", function(request, response) {
	var userId = request.params.userId;
	var groupId = request.params.groupId;
	var query = Parse.Query("Groups");
	query.equalTo("objectId", groupId);
	query.find({
		success: function(result) {
			if(result.get("members").contains(userId)) {
				response.error(1); // Group already contains user
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
Parse.Cloud.define("createGroup", function(request, response) {
	var name = request.params.name;
	var GroupObject = Parse.Object.extend("Groups");
	var group = new GroupObject();
	group.set("name", name);
	group.save(null, {
		success: function(object) {
			response.success(object.id);
		},
		error: function(error) {
			response.error(error);
		}
	});

});
Parse.Cloud.define("create", function(request, response) {
	var username = request.params.username;
	var password = request.params.password;
	var email = request.params.email;
	var phoneNumber = request.params.phoneNumber;
	var fName = request.params.fName;
	var lName = request.params.lName;
	var UserClass = Parse.Object.extend("Users");
	var user = new UserClass();
	user.set("username", username);
	user.set("password", password);
	user.set("email", email);
	user.set("phoneNumber", phoneNumber);
	user.set("fName", fName);
	user.set("lName", lName);
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
