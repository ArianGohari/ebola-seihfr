<script lang="ts">
  import { onMount } from 'svelte';
  import Header from './Header.svelte';
  import Sidebar from './Sidebar.svelte';
  import Stats from './Stats.svelte';
  import Chart from './Chart.svelte';
  import Legend from './Legend.svelte';
  import Imprint from './Imprint.svelte';
  import Sources from './Sources.svelte';
  import type { SimulationData, SimulationParams } from '../types';

  let params = $state<SimulationParams>({
    days: 360,
    e0: 280,
    i0: 140,
    h0: 60,
    r0: 110,
    d0: 65,
    beta_i: 0.35,
    beta_h: 0.12,
    beta_f: 0.35,
    incubation_days: 8.4,
    hosp_days: 4.2,
    gamma_f: 0.045,
    gamma_r: 0.105,
    gamma_hr: 0.32,
    gamma_hd: 0.08,
  });

  let simulationData = $state<SimulationData | null>(null);
  let logScale = $state(false);
  let chartRef: any = $state();
  let hiddenDatasets = $state([false, false, false, false, false, false]);
  let currentPage = $state<'dashboard' | 'sources' | 'imprint'>('dashboard');

  const DEFAULT_PARAMS: SimulationParams = {
    days: 360,
    e0: 280,
    i0: 140,
    h0: 60,
    r0: 110,
    d0: 65,
    beta_i: 0.35,
    beta_h: 0.12,
    beta_f: 0.35,
    incubation_days: 8.4,
    hosp_days: 4.2,
    gamma_f: 0.045,
    gamma_r: 0.105,
    gamma_hr: 0.32,
    gamma_hd: 0.08,
  };

  function resetParams() {
    Object.assign(params, DEFAULT_PARAMS);
  }

  async function runSimulation() {
    console.log('Running simulation with params:', params);
    const formData = new URLSearchParams();
    for (const [key, value] of Object.entries(params)) {
      formData.append(key, String(value));
    }
    formData.append('solver', 'rk4');

    try {
      const res = await fetch('/simulate', {
        method: 'POST',
        body: formData,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      });

      if (res.ok) {
        simulationData = await res.json();
      }
    } catch (err) {
      console.error('Fetch error:', err);
    }
  }

  $effect(() => {
    const { ...p } = params;
    runSimulation();
  });

  const compartments = [
    { name: 'S', color: '#2563eb' },
    { name: 'E', color: '#ca8a04' },
    { name: 'I', color: '#dc2626' },
    { name: 'H', color: '#ea580c' },
    { name: 'F', color: '#9333ea' },
    { name: 'R', color: '#16a34a' },
  ];

  function toggleDataset(idx: number) {
    if (chartRef) {
      hiddenDatasets[idx] = chartRef.toggleDataset(idx);
    }
  }

  function handleLogScale() {
    if (chartRef) {
      chartRef.setLogScale(logScale);
    }
  }
  function navigateToParameterGuide() {
    currentPage = 'sources';
    setTimeout(() => {
      const el = document.getElementById('parameter-guide');
      if (el) el.scrollIntoView({ behavior: 'smooth' });
    }, 0);
  }
</script>

<div class="bg-white text-black min-h-screen lg:h-screen flex flex-col font-sans selection:bg-black selection:text-white lg:overflow-hidden">
  <Header {currentPage} onNavigate={(p) => currentPage = p} />

  {#if currentPage === 'dashboard'}
    <main class="p-4 md:p-6 flex-1 flex flex-col gap-4 md:gap-6 lg:overflow-hidden">
      <Stats stats={simulationData?.stats} />

      <div class="flex-1 flex flex-col lg:flex-row gap-4 md:gap-6 lg:overflow-hidden">
        <Sidebar bind:params onReset={resetParams} onSources={navigateToParameterGuide} />

        <div class="flex-1 flex flex-col gap-4">
          <div class="flex flex-wrap gap-0 items-center border-2 border-black shrink-0">
            <div class="px-3 py-1 bg-black text-white text-[10px] font-black uppercase tracking-widest mr-2">Toggle</div>
            <div class="flex flex-wrap flex-1">
              {#each compartments as comp, i}
                <button
                  type="button"
                  class="flex-1 min-w-[40px] px-2 md:px-4 py-1 text-[10px] font-black uppercase tracking-tighter cursor-pointer border-r-2 border-black last:border-r-0 transition-colors"
                  class:bg-black={!hiddenDatasets[i]}
                  class:text-white={!hiddenDatasets[i]}
                  style={!hiddenDatasets[i] ? `background-color: ${comp.color}` : ''}
                  onclick={() => toggleDataset(i)}
                >
                  {comp.name}
                </button>
              {/each}
            </div>
            <label class="ml-auto px-3 flex items-center gap-2 text-[10px] font-black uppercase cursor-pointer border-l-2 border-black h-full py-1">
              <input type="checkbox" bind:checked={logScale} onchange={handleLogScale} class="w-3 h-3 rounded-none border-2 border-black accent-black" /> LOG
            </label>
          </div>

          <div class="border-2 border-black p-4 flex-1 min-h-[350px] md:min-h-[450px] lg:min-h-0 bg-white relative lg:overflow-hidden">
            <Chart data={simulationData} bind:this={chartRef} />
          </div>

          <div class="shrink-0">
            <Legend />
          </div>
        </div>
      </div>
    </main>
  {:else if currentPage === 'sources'}
    <div class="flex-1 overflow-y-auto">
      <Sources />
    </div>
  {:else if currentPage === 'imprint'}
    <div class="flex-1 overflow-y-auto">
      <Imprint />
    </div>
  {/if}
</div>
