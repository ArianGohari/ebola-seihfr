<script lang="ts">
  import { onMount } from 'svelte';
  import Chart from 'chart.js/auto';
  import type { SimulationData } from '../types';

  interface Props {
    data: SimulationData | null;
  }

  let { data }: Props = $props();
  let chartCanvas: HTMLCanvasElement;
  let chart: Chart | null = null;

  const COLORS = ['#2563eb', '#ca8a04', '#dc2626', '#ea580c', '#9333ea', '#16a34a'];
  const NAMES = ['S', 'E', 'I', 'H', 'F', 'R'] as const;

  const fmt = (n: number) =>
    n >= 1e6 ? (n / 1e6).toFixed(2) + 'M' : n >= 1e3 ? (n / 1e3).toFixed(1) + 'k' : Math.round(n).toLocaleString();

  function buildDatasets(simData: SimulationData) {
    return NAMES.map((name, i) => ({
      label: name,
      data: simData.times.map((t, idx) => ({ x: t, y: simData[name][idx] })),
      borderColor: COLORS[i],
      backgroundColor: 'transparent',
      borderWidth: 3,
      pointRadius: 0,
      tension: 0,
      fill: false,
    }));
  }

  onMount(() => {
    chart = new Chart(chartCanvas, {
      type: 'line',
      data: {
        datasets: [],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        animation: { duration: 0 },
        interaction: { mode: 'index', intersect: false },
        scales: {
          x: {
            type: 'linear',
            ticks: { color: 'black', font: { weight: 'bold', size: 10 }, maxTicksLimit: 10, callback: (v) => v + 'D' },
            grid: { color: '#e5e5e5', lineWidth: 1 },
            title: { display: false },
            border: { color: 'black', width: 2 }
          },
          y: {
            type: 'linear',
            ticks: { color: 'black', font: { weight: 'bold', size: 10 }, callback: fmt as any },
            grid: { color: '#e5e5e5', lineWidth: 1 },
            title: { display: false },
            border: { color: 'black', width: 2 }
          },
        },
        plugins: {
          legend: { display: false },
          tooltip: {
            backgroundColor: 'black',
            titleColor: 'white',
            bodyColor: 'white',
            cornerRadius: 0,
            padding: 10,
            titleFont: { weight: 'bold' },
            callbacks: {
              title: (items) => 'DAY ' + (items[0].parsed.x as number).toFixed(0),
              label: (ctx) => ` ${ctx.dataset.label}: ${fmt(ctx.parsed.y as number)}`,
            },
          },
        },
      },
    });

    return () => {
      chart?.destroy();
    };
  });

  $effect(() => {
    if (chart && data && data.times.length > 0) {
      const newDatasets = buildDatasets(data);
      if (chart.data.datasets.length === newDatasets.length) {
        chart.data.datasets.forEach((ds, i) => {
          ds.data = newDatasets[i].data;
        });
      } else {
        chart.data.datasets = newDatasets as any;
      }
      chart.update('none');
    }
  });

  export function toggleDataset(idx: number) {
    if (!chart) return false;
    const ds = chart.data.datasets[idx];
    if (ds) {
      ds.hidden = !ds.hidden;
      chart.update('none');
      return ds.hidden;
    }
    return false;
  }

  export function setLogScale(enabled: boolean) {
    if (chart && chart.options.scales?.y) {
      chart.options.scales.y.type = enabled ? 'logarithmic' : 'linear';
      chart.update();
    }
  }
</script>

<div class="relative w-full h-full bg-white">
  <canvas bind:this={chartCanvas}></canvas>
</div>
