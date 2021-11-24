<script>
	import { onMount } from 'svelte';
	import { from, op } from 'arquero';
	import { Row, Col, Input, Button } from 'sveltestrap';
	import StudyCanvas from './StudyCanvas.svelte';

	let results = [];

	let aq;

	let IDs = [];
	let currentID;
	let part = "A";
	let steps = [];
	let step = 0;

	onMount(async () => {
		const res = await fetch('/data/pilot-results.csv');
		const data = await res.text();
		for (let line of data.split('\n')) {
			if (line.length > 0) {
				results.push(JSON.parse(line));
			}
		}

		aq = from(results, ['id', 'part', 'step', 'metaphor', 'style', 'answer', 'refdata', 'focusdata', 'userdata']);

		IDs = aq.select('id')
			.groupby('id')
			.rollup({id: op.any('id')})
			.objects()
			.map(d => d.id);
		
		currentID = IDs[0];

		console.log(IDs);

	});

	$: {
		if (aq) {
			steps = aq
				.params({currentID: currentID, part: part})
				.filter(d => d.id === currentID)
				.filter(d => d.part === part)
				.orderby('step')
				.objects();
			
			console.log(steps);
		}
	}

</script>

<Row>
	<Col sm={5}>
		<Input type="select" name="participantID" bind:value={currentID}>
			{#each IDs as id}
				<option value={id}>{id}</option>
			{/each}
		</Input>
	</Col>
	<Col sm={3}>
		<Input type="select" name="part" bind:value={part}>
			<option value="A">Part A</option>
			<option value="B">Part B</option>
		</Input>
	</Col>
	<Col sm={2}>
		<Input type="select" name="step" bind:value={step}>
			{#each steps as s, i}
				<option value={i}>{i+1}</option>
			{/each}
		</Input>
	</Col>
	<Col>
		<Button disabled={step === steps.length-1} on:click={() => step += 1}>Next</Button>
	</Col>
</Row>
{#if steps.length > 0}
	<Row>
		<Col>{steps[step].id}, {steps[step].part}, {steps[step].step || step+1}, {steps[step].metaphor}, {steps[step].style}
		</Col>
	</Row>
	<Row>
		<Col>
			<StudyCanvas step={{style: 'line', metaphor: 'cross'}} stepNum={-1}
				userdata={steps[step].userdata} refdata={steps[step].refdata} focusdata={steps[step].focusdata} />
		</Col>
	</Row>
	{#if part === 'A'}
		<Row>
			<Col>
				<textarea id="answer" rows="4" cols="60" readonly
				>{steps[step].answer}</textarea> 
			</Col>
		</Row>
	{/if}
{/if}
