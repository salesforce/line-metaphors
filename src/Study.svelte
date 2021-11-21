<script>
	import { Row, Col, Button } from 'sveltestrap';
	import StudyCanvas from './StudyCanvas.svelte';

	import { createEventDispatcher } from 'svelte';

	const dispatch = createEventDispatcher();

	const DEBUG = true;

	export let steps;
	export let part;

	let userdata = [];

	let step = 0;

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
				if (part === 'A') {
					steps[step].userdata = userdata.slice();
				}
				console.log(steps[step]);
				step += 1;
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
</script>

<Row>
	<Col sm="12">
		<StudyCanvas step={steps[step]} stepNum={step} clear={false} drawAfter={true}
			on:done={nextPhase} bind:userdata />
	</Col>
</Row>
{#if phase === 1 }
	{#if part === 'A'}
		<Row>
			<Col sm={{size: 10, offset: 1}}>
				<p>Recreate the chart you saw earlier to the best of your ability <br> by dragging your mouse in the chart above.</p>
			</Col>
		</Row>
	{:else}
		<Row>
			<Col sm="12">
				Describe what you saw in the chart above:
			</Col>
		</Row>
		<Row>
			<Col sm="12">
				<textarea id="answer" rows="5" cols="40" placeholder="Enter response here…"></textarea> 
			</Col>
		</Row>
	{/if}
{/if}
{#if phase === 1}
	<Row>
		<Col sm={{size: 1, offset: 5}}>
			<Button color="secondary" on:click={nextPhase}>Done</Button>
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

</style>