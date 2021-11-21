<script>
	import Consent from './Consent.svelte';
	import Study from './Study.svelte';
	import ThankYou from './ThankYou.svelte';

	import { Container } from 'sveltestrap';
	import { shuffle } from 'd3-array';

	const metaphors = ['cross', 'approach', 'converge']; //  'diverge',
	const styles = ['plain', 'arrow', 'animate', 'points'];
	// const metaphors = ['converge']; //  'diverge',
	// const styles = ['points'];

	const ALPHA = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	const studyCode = 'ABCDEFG';

	/**
	 * 0 ... consent
	 * 1 ... study
	 * 2 ... demographics?
	 * 3 ... Thank You!
	 */
	let stage = 1;

	function nextStage() {
		stage += 1;
	}

	// from Michael's truncation experiment code,
	// slightly modified
	function gup(name) {
		let regexS = `[\\?&]${name}=([^&#]*)`;
		let regex = new RegExp(regexS);
		let tmpURL = window.location.href;
		let results = regex.exec(tmpURL);
		if (results == null)
			return '';
		else
			return results[1];
	}

	const prolificID = gup('PROLIFIC_PID') || 'TEST_'+[...new Array(5)].map(v => ALPHA[Math.floor(Math.random()*26)]).join('');

	function post(message) {
		fetch(url, {
			method: "POST",
			headers: {'Content-Type': 'application/json'},
			body: JSON.stringify(message.detail)
		});
	}
	
	let steps = [];

	for (let m of metaphors) {
		for (let s of styles) {
			steps.push({
				metaphor:	m,
				style:		s,
				id:			prolificID
			});
		}
	}

	shuffle(steps);

	console.log(steps);

</script>

<main>
	<Container>
		{#if stage === 0}
			<Consent {prolificID} on:done={nextStage} />
		{:else if stage === 1}
			<Study {steps} part="A" on:done={nextStage} on:post={post} />
		{:else if stage === 2}
			<Study {steps} part="B" on:done={nextStage} on:post={post} />
		{:else if stage === 3}
			<ThankYou {studyCode} />
		{/if}
	</Container>
</main>

<style>
	main {
		text-align: center;
		padding: 1em;
		max-width: 240px;
		margin: 0 auto;
	}
</style>
