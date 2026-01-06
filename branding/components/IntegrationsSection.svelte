<script lang="ts">
  import { onMount } from 'svelte';
  import Icon from './Icon.svelte';
  import iconGmail from '../assets/providers/icon_gmail_transition.webp';
  import iconOutlook from '../assets/providers/icon_outlook_transition.webp';
  import iconSlack from '../assets/providers/icon_slack_transition.webp';
  import iconGcal from '../assets/providers/icon_gcal_transition.webp';
  import visirForeground from '../assets/visir/visir_foreground.webp';
  import { createScrollAnimation, createStaggerAnimation } from '../lib/animations';

  let sectionElement: HTMLElement;
  let headerElement: HTMLElement;
  let mailCard: HTMLElement;
  let chatCard: HTMLElement;
  let taskCard: HTMLElement;
  let calendarCard: HTMLElement;

  onMount(() => {
    if (sectionElement) {
      createScrollAnimation(sectionElement, {
        threshold: 0.1,
        rootMargin: '0px 0px -100px 0px',
        once: true,
      });
    }

    if (headerElement) {
      createScrollAnimation(headerElement, {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px',
        once: true,
      });
    }

    const cards = [mailCard, chatCard, taskCard, calendarCard].filter(Boolean);
    if (cards.length > 0) {
      createStaggerAnimation(cards, 100);
    }
  });
</script>

<section class="py-24 relative animate-ready" bind:this={sectionElement}>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="text-center mb-16 animate-ready" bind:this={headerElement}>
      <h2 class="text-3xl md:text-5xl font-semibold font-display text-visir-text mb-6">
        Connect your tools.<br />
        <span class="text-visir-text-muted">Work seamlessly.</span>
      </h2>
      <h3 class="sr-only">Connect your tools: Slack, Gmail, Calendar Integrations</h3>
      <p class="text-lg text-visir-text-muted font-light max-w-2xl mx-auto">
        Integrate with your favorite services and bring everything together in one place. No more switching between apps.
      </p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
      <!-- Mail Group -->
      <div class="p-6 rounded-3xl bg-visir-surface/5 backdrop-blur-sm border border-white/10 shadow-lg card-hover flex flex-col items-start gap-4 group animate-ready" bind:this={mailCard} style="contain: layout style paint;">
        <div class="rounded-xl bg-blue-500/10 text-blue-400 mb-2">
          <Icon name="MessageSquare" size={24} />
        </div>
        <h3 class="text-lg font-medium font-display text-visir-text">Email</h3>
        <p class="text-sm text-visir-text-muted font-light mb-4">
          Gmail, Outlook. Turn emails into tasks or calendar events instantly.
        </p>
        <div class="flex -space-x-2 mt-auto">
          <div class="w-8 h-8 rounded-lg bg-white border border-visir-bg overflow-hidden">
            <img src={iconGmail} alt="Gmail" class="w-full h-full object-contain" />
          </div>
          <div class="w-8 h-8 rounded-lg bg-white border border-visir-bg overflow-hidden">
            <img src={iconOutlook} alt="Outlook" class="w-full h-full object-contain" />
          </div>
        </div>
        <div class="mt-2 text-xs text-visir-text-muted/60 italic">
          Coming soon: IMAP/POP3
        </div>
      </div>

      <!-- Chat Group -->
      <div class="p-6 rounded-3xl bg-visir-surface/5 backdrop-blur-sm border border-white/10 shadow-lg card-hover flex flex-col items-start gap-4 group animate-ready" bind:this={chatCard} style="contain: layout style paint;">
        <div class="rounded-xl bg-purple-500/10 text-purple-400 mb-2">
          <Icon name="MessagesSquare" size={24} />
        </div>
        <h3 class="text-lg font-medium font-display text-visir-text">Messaging</h3>
        <p class="text-sm text-visir-text-muted font-light mb-4">
          Slack. Reply directly from Visir without tab switching.
        </p>
        <div class="flex -space-x-2 mt-auto">
          <div class="w-8 h-8 rounded-lg bg-white border border-visir-bg overflow-hidden">
            <img src={iconSlack} alt="Slack" class="w-full h-full object-contain" />
          </div>
        </div>
        <div class="mt-2 text-xs text-visir-text-muted/60 italic">
          Coming soon: Discord, Teams, etc.
        </div>
      </div>

      <!-- Task Group -->
      <div class="p-6 rounded-3xl bg-visir-surface/5 backdrop-blur-sm border border-white/10 shadow-lg card-hover flex flex-col items-start gap-4 group animate-ready" bind:this={taskCard} style="contain: layout style paint;">
        <div class="rounded-xl bg-pink-500/10 text-pink-400 mb-2">
          <Icon name="CheckSquare" size={24} />
        </div>
        <h3 class="text-lg font-medium font-display text-visir-text">Task</h3>
        <p class="text-sm text-visir-text-muted font-light mb-4">
          Currently supports Visir's built-in task management. Organize and track your work seamlessly.
        </p>
        <div class="flex -space-x-2 mt-auto">
          <div class="w-8 h-8 rounded-lg bg-white border border-visir-bg overflow-hidden flex items-center justify-center">
            <img src={visirForeground} alt="Visir" class="w-full h-full object-contain scale-[0.8]" />
          </div>
        </div>
        <div class="mt-2 text-xs text-visir-text-muted/60 italic">
          Coming soon: GitHub, Jira, Linear
        </div>
      </div>

      <!-- Calendar Group -->
      <div class="p-6 rounded-3xl bg-visir-surface/5 backdrop-blur-sm border border-white/10 shadow-lg card-hover flex flex-col items-start gap-4 group animate-ready" bind:this={calendarCard} style="contain: layout style paint;">
        <div class="rounded-xl bg-orange-500/10 text-orange-400 mb-2">
          <Icon name="Calendar" size={24} />
        </div>
        <h3 class="text-lg font-medium font-display text-visir-text">Calendar</h3>
        <p class="text-sm text-visir-text-muted font-light mb-4">
          Google Calendar and Outlook. Protect your focus time with simple drag-and-drop blocking.
        </p>
        <div class="flex -space-x-2 mt-auto">
          <div class="w-8 h-8 rounded-lg bg-white border border-visir-bg overflow-hidden">
            <img src={iconGcal} alt="Google Calendar" class="w-full h-full object-contain" />
          </div>
          <div class="w-8 h-8 rounded-lg bg-white border border-visir-bg overflow-hidden">
            <img src={iconOutlook} alt="Outlook Calendar" class="w-full h-full object-contain" />
          </div>
        </div>
        <div class="mt-2 text-xs text-visir-text-muted/60 italic">
          Coming soon: CalDAV
        </div>
      </div>
    </div>

    <div class="mt-12 text-center">
      <p class="text-sm text-visir-text-muted font-light">
        ...and more coming soon, including GitHub Issues, Notion, and Markdown.
      </p>
    </div>
  </div>
</section>
