<script lang="ts">
  import type { SimulationStats } from '../types';

  interface Props {
    stats?: SimulationStats | null;
  }

  let { stats }: Props = $props();

  const fmt = (n: number) =>
    n >= 1e6 ? (n / 1e6).toFixed(2) + 'M' : n >= 1e3 ? (n / 1e3).toFixed(1) + 'k' : Math.round(n).toLocaleString();
</script>

<div class="grid grid-cols-2 lg:grid-cols-4 gap-0 border-l-2 border-t-2 border-black">
  <div class="bg-white p-4 border-r-2 border-b-2 border-black">
    <div class="text-[10px] font-black uppercase tracking-widest mb-1 text-black opacity-50">Total Infected</div>
    <div class="text-3xl font-black tabular-nums text-red-600 leading-none">
      {stats ? fmt(stats.total_infected) : '–'}
    </div>
  </div>
  <div class="bg-white p-4 border-r-2 border-b-2 border-black">
    <div class="text-[10px] font-black uppercase tracking-widest mb-1 text-black opacity-50">Total Deaths</div>
    <div class="text-3xl font-black tabular-nums text-purple-700 leading-none">
      {stats ? fmt(stats.total_deaths) : '–'}
    </div>
  </div>
  <div class="bg-white p-4 border-r-2 border-b-2 border-black">
    <div class="text-[10px] font-black uppercase tracking-widest mb-1 text-black opacity-50">Peak Infectious</div>
    <div class="text-3xl font-black tabular-nums text-red-600 leading-none">
      {stats ? fmt(stats.peak_I) : '–'}
    </div>
  </div>
  <div class="bg-white p-4 border-r-2 border-b-2 border-black">
    <div class="text-[10px] font-black uppercase tracking-widest mb-1 text-black opacity-50">Fatality Rate</div>
    <div class="text-3xl font-black tabular-nums text-purple-700 leading-none">
      {stats ? stats.cfr.toFixed(1) + '%' : '–'}
    </div>
  </div>
</div>
