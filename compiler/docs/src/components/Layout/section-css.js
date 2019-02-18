export default `
	h1 {
    margin-bottom: .3em;
    font-size: 4rem;
    font-weight: 700;
    letter-spacing: -.1rem;
    line-height: 1.3;
	}
	p {
    margin-bottom: 1.4em;
    font-size: 1.6rem;
    line-height: 1.55;
    color: #637381;
	}
	h1 + p {
    line-height: 1.55;
		color: #637381;
		margin-bottom: 1.2em;
    font-size: 2.2rem;
	}
	hr {
		margin-top: 3.2rem;
    margin-bottom: 3.2rem;
    border: 0;
    border-top: .1rem solid currentColor;
    color: #161d25;
	}
	h2 {
    margin-bottom: .8em;
    font-size: 2.2rem;
    font-weight: 500;
    line-height: 1.2;
	}
	h3 {
		font-size: 1.4rem;
    font-weight: 500;
    text-transform: uppercase;
		letter-spacing: .1rem;
    margin-bottom: .8em;
    line-height: 1.6;
	}
	li {
		max-width: 60rem;
    font-size: 1.6rem;
    line-height: 1.55;
    color: #637381;
    position: relative;
    margin-bottom: 1em;
		padding-left: 2.4rem;
		&::before {
			position: absolute;
			top: 10px;
			left: 0;
			display: block;
			content: "";
			background: #637381;
			width: 4px;
			height: 4px;
			border-radius: 2px;
		}
	}
`
