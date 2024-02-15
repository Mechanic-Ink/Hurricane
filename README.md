![Logo](public/img/logo.png)

## Full stack web development in Go

Hurricane is a collection of scripts that sets you up to work on the frontend and backend of a web app with live reloading using [Air](https://github.com/cosmtrek/air).
You can write JSX-style code in .gox files which will be transpiled into [Vecty](https://github.com/hexops/vecty) code using [gox](https://github.com/8byt/gox)

```Go
func (p *page) Render() vecty.ComponentOrHTML {
	return <div class="flex flex-col min-h-screen overflow-hidden">
		<Header/>
		<main class="grow text-center justify-center">
			<h1 class="text-4xl">This is how the code looks like</h1>
			<p>
				Download Hurricane Today!
			</p>
			<br/>
			{router.Link("/", "Back to main page", router.LinkOptions{Class:"underline"})}
		</main>
		<Footer/>
	</div>
}
```