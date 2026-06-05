<script lang="ts">
  import Slider from './Slider.svelte';
  import type { SimulationParams } from '../types';

  interface Props {
    params: SimulationParams;
    onReset: () => void;
    onSources: () => void;
  }

  let { params = $bindable(), onReset, onSources }: Props = $props();
  let mode = $state<'simple' | 'advanced'>('simple');
</script>

<aside class="w-full lg:w-64 shrink-0 bg-white border-2 border-black p-4 flex flex-col overflow-hidden h-auto lg:h-full max-h-[500px] lg:max-h-none">
  <div class="flex justify-between items-center border-b-2 border-black pb-1 mb-4 shrink-0">
    <div class="flex gap-2">
      <button 
        onclick={() => mode = 'simple'} 
        class="text-[9px] font-black uppercase px-2 py-0.5 transition-colors cursor-pointer"
        class:bg-black={mode === 'simple'}
        class:text-white={mode === 'simple'}
        class:opacity-30={mode !== 'simple'}
      >
        Simple
      </button>
      <button 
        onclick={() => mode = 'advanced'} 
        class="text-[9px] font-black uppercase px-2 py-0.5 transition-colors cursor-pointer"
        class:bg-black={mode === 'advanced'}
        class:text-white={mode === 'advanced'}
        class:opacity-30={mode !== 'advanced'}
      >
        Advanced
      </button>
    </div>
    <button 
      type="button" 
      onclick={onReset}
      class="text-[9px] font-black uppercase bg-black text-white px-2 py-0.5 hover:bg-red-600 transition-colors cursor-pointer"
    >
      Reset
    </button>
  </div>

  <div class="overflow-y-auto pr-2 custom-scrollbar flex-1">
    <div class="mb-6">
      <h3 class="text-[9px] font-black uppercase opacity-40 mb-3 tracking-widest border-b border-black/10 pb-1">Timeline</h3>
      <Slider label="Duration" name="days" min={30} max={720} step={10} bind:value={params.days} unit="d" dec={0} />
    </div>

    <div class="mb-6">
      <h3 class="text-[9px] font-black uppercase opacity-40 mb-3 tracking-widest border-b border-black/10 pb-1">Outbreak Control</h3>
      <Slider label="Community Contact (β<sub>I</sub>)" name="beta_i" min={0.01} max={1.0} step={0.01} bind:value={params.beta_i} />
      <Slider label="Time to Isolation" name="hosp_days" min={1} max={14} step={0.1} bind:value={params.hosp_days} unit="d" dec={1} />
      
      {#if mode === 'advanced'}
        <Slider label="Hospital Safety (β<sub>H</sub>)" name="beta_h" min={0.01} max={0.6} step={0.01} bind:value={params.beta_h} />
        <Slider label="Funeral Safety (β<sub>F</sub>)" name="beta_f" min={0.01} max={0.8} step={0.01} bind:value={params.beta_f} />
      {/if}
    </div>

    <div class="mb-6">
      <h3 class="text-[9px] font-black uppercase opacity-40 mb-3 tracking-widest border-b border-black/10 pb-1">Initial Cases</h3>
      <Slider label="Exposed (E<sub>0</sub>)" name="e0" min={1} max={1000} step={1} bind:value={params.e0} dec={0} />
      
      {#if mode === 'advanced'}
        <Slider label="Infectious (I<sub>0</sub>)" name="i0" min={1} max={500} step={1} bind:value={params.i0} dec={0} />
        <Slider label="Hospitalized (H<sub>0</sub>)" name="h0" min={1} max={500} step={1} bind:value={params.h0} dec={0} />
        <Slider label="Recovered (R<sub>0</sub>)" name="r0" min={1} max={500} step={1} bind:value={params.r0} dec={0} />
        <Slider label="Deaths (D<sub>0</sub>)" name="d0" min={1} max={500} step={1} bind:value={params.d0} dec={0} />
      {/if}
    </div>

    {#if mode === 'advanced'}
      <div class="mb-6">
        <h3 class="text-[9px] font-black uppercase opacity-40 mb-3 tracking-widest border-b border-black/10 pb-1">Virus Characteristics</h3>
        <Slider label="Incubation" name="incubation_days" min={2} max={21} step={0.1} bind:value={params.incubation_days} unit="d" dec={1} />
        <Slider label="Mortality (No Hosp)" name="gamma_f" min={0.01} max={0.15} step={0.001} bind:value={params.gamma_f} dec={3} />
        <Slider label="Mortality (In Hosp)" name="gamma_hd" min={0.01} max={0.15} step={0.001} bind:value={params.gamma_hd} dec={3} />
      </div>
    {/if}
  </div>

  <div class="mt-8 shrink-0">
    <button
      type="button"
      onclick={onSources}
      class="text-[9px] font-black uppercase tracking-widest text-black opacity-40 hover:opacity-100 transition-colors cursor-pointer border-none bg-transparent p-0"
    >
      Parameter Guide →
    </button>
  </div>
</aside>
