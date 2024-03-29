<script>
	import Consent from './Consent.svelte';
	import Tutorial from './Tutorial.svelte';
	import Study from './Study.svelte';
	import Demographics from './Demographics.svelte';
	import ThankYou from './ThankYou.svelte';
	import Explorer from './Explorer.svelte';

	import { Container } from 'sveltestrap';
	import { shuffle } from 'd3-array';
	import { json } from 'd3-fetch';

	const metaphors = ['converge', 'diverge', 'cross'] //, 'approach', 'converge']; //  'diverge',
	const styles = ['plain', 'arrow', 'animate']; // 'points'
	const repeats = 3;

	const ALPHA = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

	const DEBUG = window.location.href.includes('localhost');

	const POST_URL = '/post.php';

	/**
	 * 0 ... Consent
	 * 1 ... Tutorial for Part A
	 * 2 ... Study, Part A
	 * 3 ... Tutorial for Part B
	 * 4 ... Study, Part B
	 * (5 ... Demographics)
	 * 5 ... Thank You!
	 * 
	 * 1000 ... Explorer
	 */
	let stage = 1000;

	function nextStage(message) {
		if (Number.isInteger(message.detail)) {
			stage = message.detail;
		} else {
			stage += 1;
		}
		// console.log(stage);
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

	const prolificID = gup('PROLIFIC_PID').substr(-6) || 'X'+[...new Array(5)].map(v => ALPHA[Math.floor(Math.random()*26)]).join('');

	function post(message) {
		if (DEBUG)
			console.log(`POST: ${JSON.stringify(message.detail)}`);

		fetch(POST_URL, {
			method: "POST",
			headers: {'Content-Type': 'application/json'},
			body: JSON.stringify(message.detail)
		}).then(response => {
			if (DEBUG) console.log(response);
		});
	}

	let stepsA = [];
	json('stimuli-partA.json').then(data => {
		stepsA = data;
		for (let i = 0; i < stepsA.length; i += 1) {
			stepsA[i].id = prolificID;
		}
		shuffle(stepsA);
	});

	let stepsB = [];
	json('stimuli-partB.json').then(data => {
		stepsB = data;
		for (let i = 0; i < stepsB.length; i += 1) {
			stepsB[i].id = prolificID;
		}
		shuffle(stepsB);
		// Tutorial steps
		stepsB.unshift({metaphor: 'cross', style: 'animate', id: -1});
		stepsB.unshift({metaphor: 'diverge', style: 'arrow', id: -1});
		stepsB.unshift({metaphor: 'converge', style: 'plain', id: -1});

		// stage = 4;
	});

	// for (let m of metaphors) {
	// 	for (let s of styles) {
	// 		stepsA.push({
	// 			metaphor:	m,
	// 			style:		s,
	// 			id:			prolificID
	// 		});
	// 		for (let i = 0; i < repeats; i += 1) {
	// 			stepsB.push({
	// 				metaphor:	m,
	// 				style:		s,
	// 				id:			prolificID
	// 			});
	// 		}
	// 	}
	// }
	// comment out for step generation so we get the correct repeat numbers
	// shuffle(stepsA);
	// shuffle(stepsB);

	// console.log(`StudyID: ${studyID}, userID: ${prolificID}`);
	// console.log(stepsB);

</script>

<main>
	<Container>
		{#if stage === 0}
			<Consent on:done={nextStage} {DEBUG} />
		{:else if stage === 1}
			<Tutorial part="A" on:done={nextStage} />
		{:else if stage === 2}
			<Study steps={stepsA} part="A" on:done={nextStage} on:post={post} {DEBUG} />
		{:else if stage === 3}
			<Tutorial part="B" on:done={nextStage} />
		{:else if stage === 4}
			<Study steps={stepsB} part="B" on:done={nextStage} on:post={post} {DEBUG} />
		<!-- {:else if stage === 5}
			<Demographics {prolificID} on:done={nextStage} on:post={post} {DEBUG} /> -->
		{:else if stage === 5}
			<ThankYou on:post={post} {prolificID} />
		{:else if stage === 1000}
			<Explorer on:back={() => stage = 0} />
		{/if}
	</Container>
</main>

<style>
	main {
		text-align: center;
		padding: 1em;
		max-width: 700px;
		margin: 0 auto;
	}
</style>
