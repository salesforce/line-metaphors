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
		<h1>Tutorial for Part {part==='A'?1:2}</h1>
		{#if part === 'A'}
			<p>In the first part of the study, you will be shown charts about sales of two products in a fictional company, <i>Product A</i> and <i>Product B</i>. You will then be asked to describe each chart in a few sentences.
				Please try to be specific about patterns and details you observe.</p>
			<p>To see the chart, click the <b>Ready</b> button. The input field will appear after a few seconds.</p>
			<p>You will need to enter a minimum number of characters to be able to advance to the next question. This part of the study consists of nine questions.</p>
		{:else}
			<p>In the second part of the study, you will be shown charts similar to the first part. You will then be asked to recreate each chart from memory.
				As before, the charts show the sales prices of two products, A and B, over time.
			</p>
			<p>You will need to move all of the points in the chart in order to be able to advance to the next question.</p>
		{/if}
		<p>Do not reload this page or use the browser navigation buttons! You will lose your place in the study and start from the beginning.</p>
		<StudyCanvas step={{metaphor: 'converge', style: 'line'}} stepNum={1}
			drawAfter={part === 'B'}
			on:renderDone={nextStep} on:redrawDone={nextStep} />
	</Col>
</Row>
{#if nextActive}
	{#if part === 'B'}
		<Row>
			<Col sm={{size: 10, offset: 1}}>
				<p>Recreate the <span class="blue">blue line</span> in the chart you just saw
					to the best of your ability by dragging your mouse in the chart above. <br>
					You will need to move every dot in order to proceed. </p>
			</Col>
		</Row>
	{:else}
		<Row>
			<Col sm="12">
				<p>Describe what you see in the chart above:</p>
			</Col>
		</Row>
		<Row>
			<Col sm="12">
				<textarea id="answer" rows="4" cols="60" placeholder="No response necessary in this tutorial step…"></textarea> 
			</Col>
		</Row>
		<Row>
			<Col>
				<p>Type at least 150 characters to proceed.</p>
			</Col>
		</Row>
	{/if}
	<Row>
		<Col sm={{offset:4, size: 4}}>
			<Button color="primary" disabled={!nextActive} on:click={() => dispatch('done')}>Start Study</Button>
		</Col>
	</Row>
{/if}

<style>
	p {
		text-align: left;
	}
</style>