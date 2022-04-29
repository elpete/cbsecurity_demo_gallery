component singleton threadsafe {

	property name="auth" inject="AuthenticationService@personalAccessTokens";
	property name="wirebox" inject="wirebox";

	/**
	 * This function is called once an incoming event matches a security rule.
	 * You will receive the security rule that matched and an instance of the ColdBox controller.
	 *
	 * You must return a struct with three keys:
	 * - allow:boolean True, user can continue access, false, invalid access actions will ensue
	 * - type:string(authentication|authorization) The type of block that ocurred.  Either an authentication or an authorization issue.
	 * - messages:string Info/debug messages
	 *
	 * @return { allow:boolean, type:string(authentication|authorization), messages:string }
	 */
	struct function ruleValidator( required rule, required controller ) {
		return validateSecurity( arguments.rule.permissions, arguments.controller );
	}

	/**
	 * This function is called once access to a handler/action is detected.
	 * You will receive the secured annotation value and an instance of the ColdBox Controller
	 *
	 * You must return a struct with three keys:
	 * - allow:boolean True, user can continue access, false, invalid access actions will ensue
	 * - type:string(authentication|authorization) The type of block that ocurred.  Either an authentication or an authorization issue.
	 * - messages:string Info/debug messages
	 *
	 * @return { allow:boolean, type:string(authentication|authorization), messages:string }
	 */
	struct function annotationValidator( required securedValue, required controller ) {
		return validateSecurity( arguments.securedValue, arguments.controller );
	}

	private function validateSecurity( required permissions, required controller ) {
		var results = {
			"allow"    : false,
			"type"     : "authentication",
			"messages" : ""
		};

		var event = arguments.controller.getRequestService().getContext();
		var apiToken = event.getHTTPHeader( "X-Api-Token", "" );

		var user = variables.wirebox.getInstance( "User" )
			.whereHas( "accessTokens", ( q ) => {
				q.where( "token", apiToken );
			} )
			.first();

		if ( !isNull( user ) ) {
			auth.login( user );
			results.allow = true;
		}

		return results;
	}

}