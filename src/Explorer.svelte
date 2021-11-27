<script>
	import { from, op } from 'arquero';
	import { Row, Col, Input, Button, FormGroup } from 'sveltestrap';
	import StudyCanvas from './StudyCanvas.svelte';
	import { createEventDispatcher } from 'svelte';

	const dispatch = createEventDispatcher();

	let rawResults = [];

	let resultsTable;

	let IDs = [];
	let currentID;
	let part = "A";
	let steps = [];
	let step = 0;

	let stepIDs = [];
	let currentStepID;
	let overlaySteps = [];

	let pilotOrMain = 'main';
	let byStepID = false;

	async function loadData(study) {
		const res = await fetch(`/data/${study}-results.jsonl`);
		const data = await res.text();
		for (let line of data.split('\n')) {
			if (line.length > 0) {
				let d = JSON.parse(line);
				d.id = d.id.substr(d.id.length-6);
				rawResults.push(d);
			}
		}

		resultsTable = from(rawResults, ['id', 'part', 'step', 'metaphor', 'style', 'stepID', 'answer', 'time', 'refdata', 'focusdata', 'userdata']);

		IDs = resultsTable.select('id')
			.groupby('id')
			.rollup({id: op.any('id')})
			.orderby('id')
			.objects()
			.map(d => d.id);
		
		currentID = IDs[0];

		if (study === 'main') {
			stepIDs = resultsTable.select('stepID', 'part')
				.filter(d => d.part === 'B')
				.groupby('stepID')
				.rollup({stepID: op.any('stepID')})
				.orderby('stepID')
				.objects()
				.map(d => d.stepID);

			currentStepID = stepIDs[0];
			// console.log(stepIDs);
		}
	}

	function querySteps(stepID) {
		if (resultsTable) {
			return resultsTable.select('stepID', 'part', 'userdata', 'focusdata', 'refdata', 'id')
				.params({stepID: stepID})
				.filter(d => d.stepID === stepID && d.part === 'B')
				.orderby('stepID', 'id')
				.objects();
		} else {
			return [];
		}
	}

	$: {
		if (resultsTable) {
			steps = resultsTable
				.params({currentID: currentID, part: part})
				.filter(d => d.id === currentID)
				.filter(d => d.part === part)
				.orderby('step')
				.objects();
			
			// console.log(steps);
		}
	}

	$: loadData(pilotOrMain);

	$: {
		if (currentID) {
			step = 0;
		}
	}

	$: overlaySteps = querySteps(currentStepID);

	$: if (byStepID) {
		step = 0;
	}

	$: currentStepID = stepIDs[step];

	$: if (part === 'A') {
		byStepID = false;
	}

	// $: console.log(overlaySteps.map(d => `${d.stepID}, ${d.id}`).join('\n'));

</script>

<Row>
	<Col sm="2">
		<Input id="r1" type="radio"
			bind:group={pilotOrMain} value="pilot" label="Pilot"
		/>
	</Col>
	<Col sm="2">
		<Input id="r2" type="radio"
			bind:group={pilotOrMain} value="main" label="Main"
		/>
	</Col>
	<Col sm={{size: 3, offset: 2}}>
		<Input id="stepIDcb" bind:checked={byStepID} disabled={pilotOrMain==='pilot' || part==='A'} type="checkbox" label="By StepID" />
	</Col>
</Row>
<Row>
	<Col sm={3}>
		<Input type="select" name="part" bind:value={part}>
			<option value="A">Part A</option>
			<option value="B">Part B</option>
		</Input>
	</Col>
	{#if byStepID}
		<Col sm={5}>
			<Input type="select" name="stepID" bind:value={currentStepID}>
				{#each stepIDs as id}
					<option value={id}>{id}</option>
				{/each}
			</Input>
		</Col>
		<Col>
			<Button disabled={step === 0} outline on:click={() => step = 0}>Reset</Button>
		</Col>
		<Col>
			<Button disabled={step === stepIDs.length-1} on:click={() => step += 1}>Next</Button>
		</Col>
	{:else}
		<Col sm={5}>
			<Input type="select" name="participantID" bind:value={currentID}>
				{#each IDs as id}
					<option value={id}>{id}</option>
				{/each}
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
	{/if}
</Row>
{#if steps.length > 0}
	<Row>
		<Col>
			{#if byStepID}
				Step ID here
			{:else}
				{steps[step].id}, {steps[step].part}, {steps[step].step || step+1}, {steps[step].metaphor}, {steps[step].style} &mdash; {(steps[step].time/1000).toFixed(1)}s
			{/if}
		</Col>
	</Row>
	<Row>
		<Col>
			<StudyCanvas step={{style: 'line', metaphor: 'cross'}} stepNum={-1} drawAfter={false}
				userdata={byStepID ? overlaySteps.map(d => d.userdata) : (part==='A' ? null : [steps[step].userdata])}
				refdata={byStepID ? overlaySteps[0].refdata : steps[step].refdata}
				focusdata={byStepID ? overlaySteps[0].focusdata : steps[step].focusdata} />
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
<Row>
	<Col>
		<br><br><br>
		<Button outline on:click={() => dispatch('back')}>Back to Study</Button>
	</Col>
</Row>

