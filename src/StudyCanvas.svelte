<script>
	import { scaleLinear } from 'd3-scale';
	import { tweened } from 'svelte/motion';
	import { linear, quadInOut } from 'svelte/easing';

	import { createEventDispatcher } from 'svelte';

	const dispatch = createEventDispatcher();

	export let step;
	export let stepNum;
	export let clear = false;
	export let drawAfter;
	export let userdata;
	export let focusdata;
	export let refdata;
	export let DEBUG = false;

	const SVGWIDTH = 600;
	const SVGHEIGHT = 400;
	const PADDING = 24;

	const PRESENTATIONTIME = 5000;
	const ANIM_TIME = 1000;
	const ANIM_GAP = 500;
	const NUMPOINTS = 10;

	const CONVERGEREF = [{"x":0,"y":"51.39"},{"x":10,"y":"59.44"},{"x":20,"y":"74.44"},{"x":30,"y":"69.44"},{"x":40,"y":"91.11"},{"x":50,"y":"78.33"},{"x":60,"y":"74.72"},{"x":70,"y":"96.11"},{"x":80,"y":"93.33"},{"x":90,"y":"99.44"},{"x":100,"y":"95.28"}];

	const lineLength = tweened(0, {
		duration: ANIM_TIME,
		easing: quadInOut
	});

	const points = tweened(0, {
		duration: ANIM_TIME,
		easing: linear
	});

	let hover = false;

	/**
	 * Phases:
	 * 0 ... waiting for "ready"
	 * 1 ... show stimulus
	 * 2 ... noise or wait
	 * 3 ... recreate or wait
	 */
	let phase = 0;

	function nextPhase() {
		phase = phase+1;
		switch(phase) {
			case 0:
				break;
			case 1:
				if (step.style === 'animate') {
					lineLength.set(100, {duration: 0});
					lineLength.set(0);
					setTimeout(() => {
						lineLength.set(100, {duration: 0});
						lineLength.set(0);
					}, ANIM_TIME+ANIM_GAP);
					setTimeout(() => {
						lineLength.set(100, {duration: 0});
						lineLength.set(0);
					}, 2*ANIM_TIME+2*ANIM_GAP);
				}
				if (step.style === 'points') {
					points.set(0, {duration: 0});
					points.set(NUMPOINTS+1);				
					setTimeout(() => {
						points.set(0, {duration: 0});
						points.set(NUMPOINTS+1);				
					}, ANIM_TIME+ANIM_GAP);
					setTimeout(() => {
						points.set(0, {duration: 0});
						points.set(NUMPOINTS+1);				
					}, 2*ANIM_TIME+2*ANIM_GAP);
				}
				setTimeout(() => {
					nextPhase();
				}, PRESENTATIONTIME);
			break;
			case 2:
				if (drawAfter) {
					setTimeout(() => {
						nextPhase();
					}, 500);
				} else {
					nextPhase();
				}
				break;
			case 3:
				drawMode = drawAfter;
				step.time = new Date();
				dispatch('renderDone');
			break;
		}
	}

	const xScale = scaleLinear([0, 100], [PADDING, SVGWIDTH-3*PADDING]);
	let yScale = scaleLinear([0, 105], [SVGHEIGHT-1.5*PADDING, 3*PADDING]);

	let yZeros = 100;
	let stepDone = false;

	function prepareStep() {

		phase = 0;
		stepDone = false;
		hover = false;
		isDown = false;

		console.log(step);

		let reject = true;
		while(reject) {
			let refMax = 50;
			let focusMin = -50;
			let refSlope = (refMax-5)/NUMPOINTS;
			let focusSlope = -(focusMin+5)/NUMPOINTS;
			
			focusdata = [...new Array(NUMPOINTS+1)].map((v, i) => {
					return { x: i*100/NUMPOINTS, y: 0 } });
			refdata = [...new Array(NUMPOINTS+1)].map((v, i) => {
					return { x: i*100/NUMPOINTS, y: 0 } });

			for (let i = 0; i < NUMPOINTS+1; i += 1) {
				refdata[i].y = Math.random()*refMax;
				focusdata[i].y = Math.random()*focusMin;

				refMax -= refSlope;
				focusMin += focusSlope;
			}
			
			if (step.metaphor === 'diverge') {
				refdata = refdata.map((v, i) => {
					return {
						x: v.x,
						y: refdata[NUMPOINTS-i].y
				} });
				focusdata = focusdata.map((v, i) => {
					return {
						x: v.x,
						y: focusdata[NUMPOINTS-i].y
				} });
			}

			refSlope = (step.metaphor === 'cross') ? 20 : 40;
			for (let i = 0; i < NUMPOINTS+1; i += 1) {
				refdata[i].y += 51+i*(refSlope/(NUMPOINTS+1));
				focusdata[i].y += 49+i*(40/(NUMPOINTS+1));
			}

			const refdelta = refdata[NUMPOINTS].y-refdata[NUMPOINTS-1].y;
			const focusdelta = focusdata[NUMPOINTS].y-focusdata[NUMPOINTS-1].y;
			// console.log(`refdelta: ${refdelta}, focusdelta: ${focusdelta}`);
			if (step.metaphor === 'converge') {
				reject = Math.sign(refdelta) > 0 || Math.sign(focusdelta) < 0;
			} else if (step.metaphor === 'diverge') {
				reject = Math.sign(refdelta) <= 0 || Math.sign(focusdelta) >= 0;
			} else { // cross
				let crossings = 0;
				for (let i = 1; i < NUMPOINTS+1; i += 1) {
					if (Math.sign(refdata[i-1].y-focusdata[i-1].y) !== Math.sign(refdata[i].y-focusdata[i].y)) {
						crossings += 1;
					}
				}
				// console.log(crossings);
				reject = crossings !== 1;
			}
		}

		const max = Math.max(...refdata.map(v => v.y), ...focusdata.map(v => v.y));
		yScale = scaleLinear([0, max], [SVGHEIGHT-1.5*PADDING, PADDING]);

		step.refdata = refdata.slice();
		step.focusdata = focusdata.slice();

		userdata = [...new Array(NUMPOINTS+1)].map((v, i) => {
			return {
				x: i*10,
				y: 0
			};
		});
	}

	function makePath(d) {
		const path = 'M '+d.map(v => `${xScale(v.x)},${yScale(v.y)}`).join(' L ');
		return path;
	}

	function setDataPoint(e) {
		let dataX = Math.min(xScale.invert(e.offsetX), 100);
		let dataY = yScale.invert(e.offsetY);
		dataY = Math.max(0, Math.min(100, dataY));
		userdata[Math.round(dataX/10)].y = dataY;
		yZeros = userdata.reduce((sum, v) => sum + (v.y === 0 ? 1 : 0), 0);
		if (yZeros < 2 && !stepDone) {
			dispatch('redrawDone');
			stepDone = true;
		}
	}

	let isDown = false;
	let drawMode = false;

	function mouseDown(e) {
		if (drawMode && phase === 3) {
			isDown = true;
			setDataPoint(e);
		}
	}

	function mouseUp(e) {
		isDown = false;
	}

	function mouseMove(e) {
		if (isDown) {
			setDataPoint(e);
			// console.log(data);
		}
	}

	$: {
		if (stepNum >= 0) {
			prepareStep(stepNum);
		} else { // explorer
			phase = 1;
			const max = Math.max(...refdata.map(v => v.y), ...focusdata.map(v => v.y));
			yScale = scaleLinear([0, max], [SVGHEIGHT-1.5*PADDING, PADDING]);
			
		}
	}

</script>

<svg width={SVGWIDTH} height={SVGHEIGHT}>
	<defs>
		<marker id="arrowhead" markerWidth="10" markerHeight="7" 
				refX="8" refY="3.5" orient="auto">
			<polygon points="0 0, 10 3.5, 0 7" fill="steelblue" />
		</marker>
	</defs>
	<rect x=0 y=0 width={SVGWIDTH} height={SVGHEIGHT} style={"fill:white;"}
		on:mousedown={mouseDown} on:mouseup={mouseUp} on:mouseleave={mouseUp}
		on:mousemove={mouseMove} />
	<line x1={14} y1={SVGHEIGHT-PADDING/2-14} x2={SVGWIDTH-14} y2={SVGHEIGHT-PADDING/2-14} />
	<line x1={14} y1={14} x2={14} y2={SVGHEIGHT-PADDING/2-14} />

	<line x1={SVGWIDTH-12} y1={SVGHEIGHT-PADDING/2-14} x2={SVGWIDTH-22} y2={SVGHEIGHT-PADDING/2-20} />
	<line x1={SVGWIDTH-12} y1={SVGHEIGHT-PADDING/2-14} x2={SVGWIDTH-22} y2={SVGHEIGHT-PADDING/2-8} />
	<text x={SVGWIDTH-63} y={SVGHEIGHT-8} class="axis">Time</text>

	<line x1={SVGWIDTH/4-PADDING/2} y1={SVGHEIGHT-PADDING/4} x2={SVGWIDTH/4+PADDING/2} y2={SVGHEIGHT-PADDING/4} class="focus"  />
	<text x={SVGWIDTH/4+PADDING/2+2} y={SVGHEIGHT-1} class="axis">Product A</text>

	<line x1={SVGWIDTH/2-PADDING/2} y1={SVGHEIGHT-PADDING/4} x2={SVGWIDTH/2+PADDING/2} y2={SVGHEIGHT-PADDING/4} class="reference"  />
	<text x={SVGWIDTH/2+PADDING/2+2} y={SVGHEIGHT-1} class="axis">Product B</text>

	<line x1={14} y1={14} x2={20} y2={24} />
	<line x1={14} y1={14} x2={8} y2={24} />
	<text transform="rotate(-90)" x={-68} y={12} class="axis">Sales</text>

	{#if phase === 0}
		<rect x={2*SVGWIDTH/5} y={2*SVGHEIGHT/5} width={SVGWIDTH/5} height={SVGHEIGHT/5} rx="10"
			class="button" class:hover
			on:mouseenter={() => hover = true} on:mouseleave={() => hover = false} on:click={nextPhase} />
		<text x={SVGWIDTH/2} y={SVGHEIGHT/2+8} class="button">Ready</text>
	{/if}

	{#if phase === 2}
		<image href="white-noise.png" x="0" y="0" width={SVGWIDTH} height={SVGHEIGHT} preserveAspectRatio="none" />
	{/if}

	{#if phase === 1 || (phase === 3 && !clear)}
		<path d={makePath(refdata)} class="reference" />
		{#if step.style !== 'points' || phase === 2}
			<path d={makePath((phase === 1 || !drawAfter) ? focusdata : userdata)} pathLength=100 class="focus"
				style={`stroke-dasharray:100;stroke-dashoffset:${$lineLength};`}
				marker-end={(step.style === 'arrow' && (phase === 1 || (phase === 3 && !drawAfter))) ? 'url(#arrowhead)' : ''}/>
		{/if}
		{#if step.style === 'points' || (phase === 3 && drawAfter)}
			{#each ((phase === 3 && drawAfter) ? userdata : focusdata) as p, i}
				{#if i <= $points || phase === 3}
					<circle cx={xScale(p.x)} cy={yScale(p.y)} r={phase === 1 ? 5 : 3} />
				{/if}
			{/each}
		{/if}
	{/if}

	{#if (stepNum === -1 && userdata) || DEBUG}
		<path d={makePath(DEBUG?focusdata:userdata)} class="useroverlay" />
	{/if}
</svg>

<style>
	rect.button {
		fill: #408458;
	}

	rect.button.hover {
		fill: #36704B;
	}

	text {
		user-select: none;
	}

	text.button {
		fill: white;
		font-size: 20pt;
		font-weight: bold;
		text-anchor: middle;
		pointer-events: none;
	}

	text.axis {
		font-size: 12pt;
	}

	line {
		stroke: black;
		stroke-width: 2px;
		pointer-events: none;
	}

	path {
		stroke-width: 2px;
		fill: none;
		pointer-events: none;
	}

	circle {
		fill: steelblue;
		stroke: none;
		pointer-events: none;
	}

	.focus {
		stroke: steelblue;
	}

	.reference {
		stroke: darkgray;
	}

	.useroverlay {
		stroke: purple;
	}

	svg {
		margin-bottom: 1em;
	}

</style>