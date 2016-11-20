# Me

A super slim and in-place solution to the *nested asynchronous computations* problem

The mindset of software developers is changing, async programming represents 70% of the code in a cloud-based app and nested closures/blocks are a bad idea most of the time in terms of maintainability, readability and control (confusion about multiple vars with the same name in the same scope).

In order to deal with it, we wrote **Me**, a super slim piece of software (less than 200 lines) that acts like a magic by chaining your code instead of nesting it.

## Example

### Old method

```
MyAPI.login {
	//Do your stuff and then request posts...
	MyAPI.posts {
		//Do your stuff and then request comments...
		MyAPI.comments {
			//Do your stuff and then request likes...
			MyAPI.likes {
				//We are done here
			}
		}
	}
}
```

### Me method

```
Me.start { (me) -> (Void) in
	MyAPI.login {
		//Do your stuff and then request posts...
		me.runNext()
	}
}.next { (caller, me) -> (Void) in
	MyAPI.posts {
		//Do your stuff and then request comments...
		me.runNext()
	}
}.next { (caller, me) -> (Void) in
	MyAPI.comments {
		//Do your stuff and then request likes...
		me.runNext()
	}
}.next { (caller, me) -> (Void) in
	MyAPI.likes {
		//We are done here
		me.end()
	}
}.run()
```

As you can see, the 'shifting' has been solved and the developer has the full control of the code's flow.

**So, what the heck is the `Me` object??**

The `Me` object is a proxy, an holder of the current block and the next in the chain.

- `Me.start` command, here you can add your first block, and then continue with:

- `.next` command, as parameters there are two `Me` objects, the first one refers to the `Me` caller, and the other refers to the `Me` object that holds the current block that you are working on.

- `.run()` command, start the first block, you must add it at the end of the chain.


Inside each block, you must add an `instruction` for the next block that should be executed, this is accomplished with `runNext()` or `end()`

- `me.runNext()` is the command used to call the next block, it should be called when your async call is returned and you are ready to run the next block.

- `me.end()` expresses the intention to end the chaining and release all the `Me` objects and the blocks associated to it.

**N.B. If you don't call runNext(), the next block will not be executed**

**N.B. If you don't call end(), nothing will be released**


## Pros

- Easy to read
- Easy to maintain
- Me doesn't ask you to write your own proxy (like Promise), you can just refactor your nested blocks and split them in different `.next` blocks.
- Me is built on top of the [Grand Central Dispatcher](https://en.wikipedia.org/wiki/Grand_Central_Dispatch), it's safe and allows you to run the code in your own queue
- Allows you to jump to a particular block and check the name of the caller
- Allows you to set all of your parameters in the `parameters` dictionary

## Cons

- The code will be few lines longer (2/3 for each block) compared to the nested code
- You can't forget to add `runNext()` or `end()` at the end of the execution, otherwise the next block will not be executed or the memory will not be released
- You can't pass parameters directly as block parameters, but you must specify them into the `parameters` dictionary

## Contacts

We would love to know if you are using `Me` in your app, send an email to <pasquale.ambrosini@gmail.com>
