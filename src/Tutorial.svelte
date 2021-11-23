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
			<p>In this part of the study, you will look at charts and then be asked to recreate them from memory.
				The charts show the sales prices of two products, A and B, over time.
			</p>
		{:else}
			<p>In this second part of the study, you will…</p>
		{/if}
		<StudyCanvas step={{metaphor: 'approach', style: 'line'}} stepNum={1}
			clear={part === 'B'} drawAfter={part === 'A'}
			on:renderDone={nextStep} />
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