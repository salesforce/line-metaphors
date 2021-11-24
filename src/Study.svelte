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
	 */
	let phase = 0;

	function nextPhase() {
		switch(phase) {
			case 0:
				phase = 1;
				break;
			case 1:
				steps[step].time = (new Date())-steps[step].time;
				steps[step].part = part;
				if (part === 'A') {
					steps[step].answer = answer.slice();
				} else {
					steps[step].userdata = userdata.slice();
				}
				// console.log(steps[step]);
				dispatch('post', steps[step]);
				step += 1;
				buttonActive = false;
				answer = '';
				if (step < steps.length) {
					console.log(`Step ${step}`);
					phase = 0;
				} else {
					dispatch('done');
					console.log('Done');
				}			
		}
	}

	function savePoints() {
		console.log(JSON.stringify(userdata.map(d => {
			return {
				x: d.x,
				y: d.y.toFixed(2)
			}
		})));
	}

	$: {
		buttonActive = answer.length > 150;
	}

</script>

<Row>
	<Col sm="12">
		<StudyCanvas step={steps[step]} stepNum={step}
			drawAfter={part === 'B'}
			on:renderDone={nextPhase} on:redrawDone={() => buttonActive = true}
			bind:userdata />
	</Col>
</Row>
{#if phase === 1 }
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
				<p>Describe what you see in the chart above:</p>
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
{#if phase === 1}
	<Row>
		<Col sm={{size: 1, offset: 5}}>
			<Button color="secondary" disabled={!buttonActive} on:click={nextPhase}>Done</Button>
		</Col>
		{#if DEBUG && phase === 3}
			<Col sm={{size: 1, offset: 5}}>
				<Button color="secondary" outline on:click={savePoints}>Save Points</Button>
			</Col>
		{/if}
	</Row>
{/if}
	<Row>
		<Col sm="12">Part {part}, Step {step+1}/{steps.length}
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