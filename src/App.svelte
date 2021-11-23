<script>
	import Consent from './Consent.svelte';
	import Tutorial from './Tutorial.svelte';
	import Study from './Study.svelte';
	import Demographics from './Demographics.svelte';
	import ThankYou from './ThankYou.svelte';

	import { Container } from 'sveltestrap';
	import { shuffle } from 'd3-array';

	const metaphors = ['cross'] //, 'approach', 'converge']; //  'diverge',
	const styles = ['plain', 'arrow', 'animate', 'points'];
	// const metaphors = ['converge']; //  'diverge',
	// const styles = ['points'];

	const ALPHA = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

	const POST_URL = '/post.php';

	/**
	 * 0 ... consent
	 * 1 ... Tutorial for Part A
	 * 2 ... Study, Part A
	 * 3 ... Tutorial for Part B
	 * 4 ... Study, Part B
	 * 5 ... Demographics
	 * 6 ... Thank You!
	 */
	let stage = 2;

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
	const studyID = gup('STUDY_ID') || 'UNKNOWN';

	function post(message) {
		console.log(`POST: ${JSON.stringify(message.detail)}`);
		// fetch(POST_URL, {
		// 	method: "POST",
		// 	headers: {'Content-Type': 'application/json'},
		// 	body: JSON.stringify(message.detail)
		// });
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

	console.log(`StudyID: ${studyID}, userID: ${prolificID}`);
	console.log(steps);

</script>

<main>
	<Container>
		{#if stage === 0}
			<Consent {prolificID} on:done={nextStage} />
		{:else if stage === 1}
			<Tutorial part="A" on:done={nextStage} />
		{:else if stage === 2}
			<Study {steps} part="A" on:done={nextStage} on:post={post} />
		{:else if stage === 3}
			<Tutorial part="B" on:done={nextStage} />
		{:else if stage === 4}
			<Study {steps} part="B" on:done={nextStage} on:post={post} />
		{:else if stage === 5}
			<Demographics {prolificID} on:done={nextStage} on:post={post} />
		{:else if stage === 6}
			<ThankYou studyCode={studyID} />
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

	@media (min-width: 640px) {
		main {
			max-width: none;
		}
	}
</style>
