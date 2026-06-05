<script lang="ts">
	const legend = [
		{ sym: 'S', color: '#2563eb', name: 'Susceptible', desc: 'HEALTHY, NOT IMMUNIZED' },
		{ sym: 'E', color: '#ca8a04', name: 'Exposed', desc: 'INCUBATING, ASYMPTOMATIC' },
		{ sym: 'I', color: '#dc2626', name: 'Infectious', desc: 'SYMPTOMATIC, INFECTIOUS' },
		{ sym: 'H', color: '#ea580c', name: 'Hospitalized', desc: 'ISOLATED, STILL INFECTIOUS' },
		{ sym: 'F', color: '#9333ea', name: 'Funeral', desc: 'DECEASED, STILL INFECTIOUS' },
		{ sym: 'R', color: '#16a34a', name: 'Removed', desc: 'BURIED OR RECOVERED' }
	];
</script>

<div class="grid grid-cols-3 gap-0 border-t-2 border-l-2 border-black lg:grid-cols-6">
	{#each legend as item}
		<div class="border-r-2 border-b-2 border-black bg-white p-2">
			<div class="text-[10px] font-black uppercase" style="color: {item.color}">
				{item.sym} - {item.name}
			</div>
			<div class="text-[9px] font-bold tracking-tighter text-black uppercase opacity-40">
				{item.desc}
			</div>
		</div>
	{/each}
</div>
