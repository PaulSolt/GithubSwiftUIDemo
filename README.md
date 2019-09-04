# GithubSwiftUIDemo
Demo code base on mecid.github.io Github SwiftUI Demo

Based on 
https://mecid.github.io/2019/06/05/swiftui-making-real-world-app/

And the github responses


## Invalid Request Error (Blank query)

https://api.github.com/search/repositories?q=

	{
	  "message": "Validation Failed",
	  "errors": [
	    {
	      "resource": "Search",
	      "field": "q",
	      "code": "missing"
	    }
	  ],
	  "documentation_url": "https://developer.github.com/v3/search"
	}

## Invalid error (Malformed URL with trailing slash)

  https://api.github.com/search/repositories/?q=PaulSolt

	"{\"message\":\"Not Found\",\"documentation_url\":\"https://developer.github.com/v3\"}"
