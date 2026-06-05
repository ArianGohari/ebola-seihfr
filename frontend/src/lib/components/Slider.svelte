<script lang="ts">
  interface Props {
    name: string;
    label: string;
    min: number;
    max: number;
    step: number;
    value: number;
    unit?: string;
    dec?: number;
  }

  let { name, label, min, max, step, value = $bindable(), unit = "", dec = 2 }: Props = $props();
</script>

<div class="mt-4">
  <div class="flex justify-between text-[10px] font-black uppercase tracking-tighter mb-1">
    <span>{@html label}</span>
    <span class="bg-black text-white px-1">{Number(value).toFixed(dec)}{unit}</span>
  </div>
  <input
    type="range"
    {name}
    {min}
    {max}
    {step}
    bind:value
  />
</div>
