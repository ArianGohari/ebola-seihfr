<script lang="ts">
  interface Props {
    currentPage: 'dashboard' | 'sources' | 'imprint';
    onNavigate: (page: 'dashboard' | 'sources' | 'imprint') => void;
  }
  let { currentPage, onNavigate }: Props = $props();
</script>

<header class="px-4 md:px-6 py-4 border-b-2 border-black flex flex-wrap items-center justify-between gap-4 md:gap-8 shrink-0">
  <button 
    onclick={() => onNavigate('dashboard')}
    class="flex flex-col items-start text-left cursor-pointer border-none bg-transparent p-0"
  >
    <h1 class="text-2xl font-black uppercase tracking-tighter m-0">Ebola SEIHFR Modelling</h1>
    <p class="hidden md:block text-black text-[11px] font-bold uppercase mt-1 opacity-50 tracking-tight">
      Compartmental Transmission Dynamics • Ituri Province, DRC
    </p>
  </button>

  <nav class="flex gap-4 md:gap-8">
    <button
      onclick={() => onNavigate('sources')}
      class="text-xs md:text-sm font-black uppercase tracking-widest cursor-pointer hover:underline underline-offset-4 decoration-2"
      class:underline={currentPage === 'sources'}
    >
      Sources
    </button>
    <button
      onclick={() => onNavigate('imprint')}
      class="text-xs md:text-sm font-black uppercase tracking-widest cursor-pointer hover:underline underline-offset-4 decoration-2"
      class:underline={currentPage === 'imprint'}
    >
      Imprint
    </button>
  </nav>
</header>
