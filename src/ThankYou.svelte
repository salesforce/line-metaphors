<script>
	import { Row, Col, Button } from 'sveltestrap';
	import { createEventDispatcher } from 'svelte';

	const dispatch = createEventDispatcher();

	export let prolificID;

	let comments = '';

	function submit() {
		dispatch('post', {id: 'comments', prolificID: prolificID, comments: comments});
	}

</script>

<Row>
	<Col>
		<h1>Thank You!</h1>

		<p>Thank you for participating in our study!</p>

		<p>If you have any comments for us, please enter them below and click the Submit button. This part is entirely optional.</p>

		<textarea bind:value={comments} rows="4" cols="60"></textarea>
	</Col>
</Row>
<Row>
	<Col sm={{size: 5, offset: 3}}>
		<Button color="secondary" on:click={submit} disabled={comments.length === 0}>Submit Comments</Button>
	</Col>
</Row>
<Row>
	<Col>
		<p><br></p>
		<p>To finish the study, click the link below to return to the Prolific website and record your work.</p>
	</Col>
</Row>
<Row>
	<Col sm={{size: 5, offset: 3}}>
		<Button color="success" href={`https://app.prolific.co/submissions/complete?cc=4FA51EDE`}>Finish Study</Button>
	</Col>
</Row>

<style>
	p {
		text-align: left;
	}
</style>