<script>
	import { Button } from 'sveltestrap';
	
	export let studyCode;
</script>

<h1>Thank You!</h1>

<p>Thank you for participating in our study!
	Click the link below to return to the Prolific website and record your task.</p>

<Button color="success" href={`https://app.prolific.ac/submissions/complete?cc=${studyCode}`}>Finish Study</Button>

