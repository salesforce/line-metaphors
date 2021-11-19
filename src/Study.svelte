<script>
	import { Row, Col, Button } from 'sveltestrap';
	import { scaleLinear } from 'd3-scale';
	import { tweened } from 'svelte/motion';
	import { linear, quadInOut } from 'svelte/easing';

	export let steps;

	let step = 0;

	const DEBUG = true;

	const SVGWIDTH = 600;
	const SVGHEIGHT = 400;
	const PADDING = 20;

	const PRESENTATIONTIME = 2000;
	const NUMPOINTS = 10;

	const CONVERGEREF = [{"x":0,"y":"51.39"},{"x":10,"y":"59.44"},{"x":20,"y":"74.44"},{"x":30,"y":"69.44"},{"x":40,"y":"91.11"},{"x":50,"y":"78.33"},{"x":60,"y":"74.72"},{"x":70,"y":"96.11"},{"x":80,"y":"93.33"},{"x":90,"y":"99.44"},{"x":100,"y":"95.28"}];

	const lineLength = tweened(0, {
		duration: 1000,
		easing: quadInOut
	});

	const points = tweened(0, {
		duration: 1000,
		easing: linear
	});


	/**
	 * Phases:
	 * 0 ... waiting for "ready"
	 * 1 ... show stimulus
	 * 2 ... describe
	 * 3 ... recreate
	 */
	let phase = 0;

	function nextPhase() {
		phase = phase+1;
		drawMode = phase === 3;
		if (phase === 1) {
			if (steps[step].style === 'animate') {
				lineLength.set(100, {duration: 0});
				lineLength.set(0);
			}
			if (steps[step].style === 'points') {
				points.set(0, {duration: 0});
				points.set(NUMPOINTS+1);				
			}
			setTimeout(() => {
				nextPhase();
			}, PRESENTATIONTIME);
		}
		if (phase > 3) {
			step += 1;
			prepareStep(step);
			console.log(`Step ${step}`);
			phase = 0;
		}
	}

	const xScale = scaleLinear([0, 100], [PADDING, SVGWIDTH-PADDING]);
	const yScale = scaleLinear([0, 100], [SVGHEIGHT-PADDING, PADDING]);

	let focusdata;
	let refdata;
	let userdata;

	function prepareStep(step) {

		let max = (steps[step].metaphor === 'approach' || steps[step].metaphor === 'coverge')  ? 80 : 100;

		focusdata = [...new Array(NUMPOINTS+1)].map((v, i) => {
			return {
				x: i*100/NUMPOINTS,
				y: Math.max(0, Math.min(i*(max/NUMPOINTS)+20-Math.random()*40, max))
			};
		});

		if (steps[step].metaphor === 'cross') {
			refdata = [...new Array(NUMPOINTS+1)].map((v, i) => {
				return {
					x: i*100/NUMPOINTS,
					y: Math.max(0, Math.min((10-i)*10+20-Math.random()*40, 100))
				};
			});
		} else if (steps[step].metaphor === 'approach') {
			refdata = [...new Array(NUMPOINTS+1)].map((v, i) => {
				return {
					x: i*100/NUMPOINTS,
					y: 90
				};
			});
		} else if (steps[step].metaphor === 'converge') {
			refdata = CONVERGEREF;
		}

		userdata = [...new Array(NUMPOINTS+1)].map((v, i) => {
			return {
				x: i*10,
				y: 50
			};
		});
	}

	function makePath(d) {
		const path = 'M '+d.map(v => `${xScale(v.x)},${yScale(v.y)}`).join(' L ');
		return path;
	}

	function setDataPoint(e) {
		let dataX = xScale.invert(e.offsetX);
		let dataY = yScale.invert(e.offsetY);
		dataY = Math.max(0, Math.min(100, dataY));
		userdata[Math.round(dataX/10)].y = dataY;
	}

	let isDown = false;
	let drawMode = false;

	function mouseDown(e) {
		if (drawMode) {
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

	function savePoints() {
		console.log(JSON.stringify(userdata.map(d => {
			return {
				x: d.x,
				y: d.y.toFixed(2)
			}
		})));
	}

	prepareStep(0);

</script>

<Row>
	<Col md="12">
		<svg width={SVGWIDTH} height={SVGHEIGHT}>
			<rect x=0 y=0 width={SVGWIDTH} height={SVGHEIGHT} style={"fill:white;"}
				on:mousedown={mouseDown} on:mouseup={mouseUp} on:mouseleave={mouseUp}
				on:mousemove={mouseMove} />
			<line x1={PADDING} y1={SVGHEIGHT-PADDING} x2={SVGWIDTH-PADDING} y2={SVGHEIGHT-PADDING} />
			<line x1={PADDING} y1={PADDING} x2={PADDING} y2={SVGHEIGHT-PADDING} />

			{#if phase === 1 || phase === 3}
				<path d={makePath(refdata)} class="reference" />
			{/if}
			{#if phase === 1 }
				{#if steps[step].style !== 'points'}
					<path d={makePath(focusdata)} pathLength=100 class="focus" style={`stroke-dasharray:100;stroke-dashoffset:${$lineLength};`} />
				{:else}
					{#each focusdata as p, i}
						{#if i <= $points}
							<circle cx={xScale(p.x)} cy={yScale(p.y)} r=5 />
						{/if}
					{/each}
				{/if}
			{:else if phase === 3}
				<path d={makePath(userdata)} class="focus" />
			{/if}
		</svg>
	</Col>
</Row>
{#if phase === 0 }
	<Row>
		<Col md={{size: 1, offset: 5}}>
			<Button color="primary" on:click={nextPhase}>Ready!</Button>
		</Col>
	</Row>
{/if}
{#if phase === 2 }
	<Row>
		<Col md="12">
			Describe what you are seeing in the chart above:
		</Col>
	</Row>
	<Row>
		<Col md="12">
			<textarea id="answer" rows="5" cols="40" placeholder="Enter response here…"></textarea> 
		</Col>
	</Row>
{:else if phase === 3}
	<Row>
		<Col md="12">
			Recreate the chart you saw earlier to the best of your ability by dragging your mouse in the chart above.
		</Col>
	</Row>
{/if}
{#if phase === 2 || phase === 3 }
	<Row>
		<Col md={{size: 1, offset: 5}}>
			<Button color="secondary" on:click={nextPhase}>Done</Button>
		</Col>
		{#if DEBUG && phase === 3}
			<Col md={{size: 1, offset: 5}}>
				<Button color="secondary" outline on:click={savePoints}>Save Points</Button>
			</Col>
		{/if}
	</Row>
{/if}

<style>
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
	}

	.focus {
		stroke: steelblue;
	}

	.reference {
		stroke: darkgray;
	}
</style>