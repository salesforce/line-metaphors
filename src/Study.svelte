<script>
	import { Row, Col, Button } from 'sveltestrap';
	import StudyCanvas from './StudyCanvas.svelte';

	import { createEventDispatcher } from 'svelte';

	const dispatch = createEventDispatcher();

	export let steps;
	export let part;
	export let DEBUG = false;

	let userdata = [];

	let step = 0;

	let buttonActive = false;

	let answer = '';

	/**
	 * 0 ... show stimulus
	 * 1 ... wait for redraw
	 * 2 ... switch to next step
	 * 3 ... tutorial, wait for click on "Next Step" (switches to 1)
	 */
	let phase = 0;

	function nextPhase() {
		switch(phase) {
			case 0:
				phase = 1;
			break;
			case 1:
				if (steps[step].id === -1) {
					phase = 3;
				} else {
					steps[step].time = (new Date())-steps[step].time;
					steps[step].part = part;
					steps[step].step = step;
					if (part === 'A') {
						steps[step].answer = answer.slice();
					} else {
						steps[step].userdata = userdata.slice();
					}
					// console.log(steps[step]);
					dispatch('post', steps[step]);
					buttonActive = false;
					answer = '';
					if (step < steps.length-1) {
						step += 1;
						console.log(`Step ${step}`);
						phase = 0;
					} else {
						dispatch('done');
						console.log('Done');
					}
				}
			break;
			case 3:
				step += 1;
				phase = 0;
				buttonActive = false;
			break;
		}
	}

	function exportSteps() {
		const stimuli = steps.map(s => {
			return {
				part:		s.part,
				stepID:		s.stepID,
				metaphor:	s.metaphor,
				style:		s.style,
				refdata:	s.refdata,
				focusdata:	s.focusdata
			} } );
		console.log(JSON.stringify(stimuli));
	}

	$: {
		buttonActive = answer.length > 150;
	}

</script>

<Row>
	<Col sm="12">
		<StudyCanvas step={steps[step]} stepNum={step} {DEBUG}
			drawAfter={part === 'B'} showFocus={phase === 3}
			on:renderDone={nextPhase} on:redrawDone={() => buttonActive = true}
			bind:userdata />
	</Col>
</Row>
{#if steps[step].id === -1}
	<Row>
		<Col sm={{size: 10, offset: 1}}><p><i>For the first three steps of this part, you will be shown the original chart for reference once you are done drawing yours.</i></p>
		</Col>
	</Row>
{/if}
{#if phase === 1 || phase === 3}
	{#if part === 'B'}
		<Row>
			<Col sm={{size: 10, offset: 1}}>
				<p>Recreate the <span class="blue">blue {steps[step].style === 'points' ? 'dots' : 'line'}</span> in the chart you just saw
					to the best of your ability by dragging your mouse in the chart above. <br>
					You will need to move every dot in order to proceed. </p>
			</Col>
		</Row>
	{:else}
		<Row>
			<Col sm="12">
				<p>Describe the behavior of the <span class="blue">blue {steps[step].style === 'points' ? 'dots' : 'line'}</span> (Product A) in the chart above:</p>
			</Col>
		</Row>
		<Row>
			<Col sm="12">
				<textarea id="answer" rows="4" cols="60" placeholder="Enter response here…"
					bind:value={answer}></textarea> 
			</Col>
		</Row>
		<Row>
			<Col>
				<p>Type at least 150 characters to proceed.</p>
			</Col>
		</Row>
	{/if}
{/if}
{#if phase === 1 || phase === 3}
	<Row>
		<Col sm={{size: 1, offset: 5}}>
			<Button color="secondary" disabled={!buttonActive && !DEBUG} on:click={nextPhase}>Done</Button>
		</Col>
		{#if steps[step].id === -1 && phase === 3}
			<Col sm={{size: 3, offset: 1}}>
				<Button color="primary" on:click={nextPhase}>Next Step</Button>
			</Col>
		{/if}
		{#if DEBUG}
			<Col><Button outline on:click={exportSteps}>Export Stimuli</Button></Col>
		{/if}
	</Row>
{/if}
	<Row>
		<Col sm="12">Part {part==='A'?'1 (Description)':'2 (Reconstruction)'}, Step {step+1}/{steps.length}
		</Col>
	</Row>

<style>
	p { 
		text-align: left;
	}

	.blue {
		font-weight: bold;
		color: steelblue;
	}

</style>