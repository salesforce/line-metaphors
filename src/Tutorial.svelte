<script>
	import StudyCanvas from './StudyCanvas.svelte';
	import { Button, Row, Col } from 'sveltestrap';
	import { createEventDispatcher } from 'svelte';

	const dispatch = createEventDispatcher();
	
	export let part;

	let nextActive = false;

	function nextStep() {
		nextActive = true;
	}

</script>

<Row>
	<Col sm="12">
		<h1>Tutorial for Part {part}</h1>
		{#if part === 'A'}
			<p>In the first part of the study, you will be shown charts and then be asked to describe them in a few sentences.
				Please try to be specific about patterns and details you observe.</p>
			<p>You will need to enter a minimum number of characters to be able to advance to the next question.</p>
		{:else}
			<p>In the second part of the study, you will be shown charts and then be asked to recreate them from memory.
				The charts show the sales prices of two products, A and B, over time.
			</p>
			<p>You will need to move all of the points in the chart in order to be able to advance to the next question.</p>
		{/if}
		<StudyCanvas step={{metaphor: 'approach', style: 'line'}} stepNum={1}
			clear={part === 'A'} drawAfter={part === 'B'}
			on:renderDone={part == 'A' ? nextStep : null} on:redrawDone={nextStep} />
	</Col>
</Row>
<Row>
	<Col sm={{offset:4, size: 4}}>
		<Button color="primary" disabled={!nextActive} on:click={() => dispatch('done')}>Start Study</Button>
	</Col>
</Row>

<style>
	p {
		text-align: left;
	}
</style>