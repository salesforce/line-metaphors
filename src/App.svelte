<script>
	import Consent from './Consent.svelte';
	import Study from './Study.svelte';
	import { Container } from 'sveltestrap';
	import { shuffle } from 'd3-array';

	const metaphors = ['cross', 'approach', 'converge']; //  'diverge',
	const styles = ['plain', 'arrow', 'animate', 'points'];

	let prolificID = 'XYZ';

	/**
	 * 0 ... consent
	 * 1 ... study
	 * 2 ... demographics?
	 * 3 ... Thank You!
	 */
	let stage = 1;

	let steps = [];

	for (let m of metaphors) {
		for (let s of styles) {
			steps.push({
				metaphor:	m,
				style:		s,
				id:			prolificID
			});
		}
	}

	shuffle(steps);

	console.log(steps);

</script>

<main>
	<Container>
		{#if stage === 0}
			<Consent {prolificID} />
		{:else if stage === 1}
			<Study {steps} />
		{:else if stage === 3}
			<ThankYou {prolificID} />
		{/if}
	</Container>
</main>

<style>
	main {
		text-align: center;
		padding: 1em;
		max-width: 240px;
		margin: 0 auto;
	}

	@media (min-width: 640px) {
		main {
			max-width: none;
		}
	}
</style>