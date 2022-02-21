<script>
	import { Row, Col, Button } from 'sveltestrap';

	import { createEventDispatcher } from 'svelte';

	const dispatch = createEventDispatcher();

	// export let prolificID;
	export let DEBUG = false;

	function done(next) {
		dispatch('done', next);
	}

</script>

{#if DEBUG}
<Row>
	<Col><Button on:click={() => done(2)}>Part A</Button></Col><Col><Button on:click={() => done(4)}>Part B</Button></Col>
	<Col><Button color="warning" on:click={() => done(1000)}>Explorer</Button></Col>
</Row>
{/if}
<Row>
	<Col md="12">
		<h1>Informed Consent</h1>
		<h3>Perception of Effect Sizes in Visualizations</h3>
		<p>You are invited by Robert Kosara and Michael Correll of the Tableau Research team to participate in a research study about how users perceive information in line charts.</p>
		<p>This study will include participants over 18 years of age who feel comfortable using an online interface to read graphs and answer questions about data.</p>
		<h4><b>What Will My Participation Involve?</b></h4>
		<p>If you decide to participate in this research, you will be asked to answer questions about fictional data, using a number of charts or graphs. You will be presented with a total of 36 charts, and asked to give brief descriptions or redraw the charts from memory. After the main task, we will ask you some questions about how you read charts and collect basic demographic information.</p>
		<p>We expect this study to take about 30 minutes.</p>
		<h4><b>Are There Any Risks To Me?</b></h4>
		<p>We don't anticipate any risks from participation in this study greater than normal activity.</p>
		<h4><b>Are There Any Benefits To Me?</b></h4>
		<p>There are no direct benefits to you other than compensation.</p>
		<h4><b>Will I Be Compensated For My Participation?</b></h4>
		<p>You will receive $7.50 (or equivalent) for participating in this study. If you withdraw prior to the end of the study, you will receive no compensation.</p>
		<h4><b>Whom Should I Contact If I Have Questions?</b></h4>
		<p>You may ask any questions about the research at any time. If you have questions about the research after your participation, you should contact the lead researcher, <a href="mailto:rkosara@tableau.com">Dr. Robert Kosara</a>. Your participation is completely voluntary. If you begin participation and change your mind you may end your participation at any time without penalty.</p>
		<h4><b>Privacy Statement</b></h4>
			<p>Your responses to this experiment will be used only by the two named researchers to help us answer questions about chart design. Once collected, your information will be anonymized and stored on a secure server.</p>
			<p>While there will probably be publications as a result of this study, your name or participant ID will not be used. Only group characteristics will be published.</p>

		<!-- <p>
			Your current Prolific ID is being recorded as <span id="prolificid" style="font-weight: bold;">{prolificID}</span>.
		</p>
		<p>
			Please double-check that this is correct. Your Prolific ID should be visible on your profile page.
		</p> -->
		<p>
			By clicking "I Agree", you acknowledge that you have read and understood this consent form.
		</p>
	</Col>
</Row>
<Row>
	<Col sm={{size: 4, offset: 4}}>
		<Button color='success' on:click={done}>I Agree</Button>
	</Col>
</Row>

<style>
	h1, h2, h3, h4, p {
		text-align: left;
	}

	h4 {
		margin-bottom: 0px;
	}

	p {
		margin-top: 0px;
	}

</style>