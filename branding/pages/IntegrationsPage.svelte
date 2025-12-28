<script lang="ts">
  import Icon from '../components/Icon.svelte';
  import iconGmail from '../assets/providers/icon_gmail_transition.webp';
  import iconOutlook from '../assets/providers/icon_outlook_transition.webp';
  import iconSlack from '../assets/providers/icon_slack_transition.webp';
  import iconGcal from '../assets/providers/icon_gcal_transition.webp';
  import visirForeground from '../assets/visir/visir_foreground.webp';
</script>

<div class="pt-32 pb-24 min-h-screen">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="text-center mb-16">
      <h1 class="text-4xl sm:text-6xl font-medium font-display tracking-tight text-visir-text mb-6">
        Integrations
      </h1>
      <p class="text-xl text-visir-text-muted max-w-2xl mx-auto font-light">
        Connect your favorite tools and bring everything together in one place. No more switching between apps.
      </p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
      <!-- Mail Group -->
      <div class="p-6 rounded-3xl bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 shadow-lg hover:bg-white/20 dark:hover:bg-white/10 hover:border-white/30 transition-all duration-300 flex flex-col items-start gap-4 group">
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
      <div class="p-6 rounded-3xl bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 shadow-lg hover:bg-white/20 dark:hover:bg-white/10 hover:border-white/30 transition-all duration-300 flex flex-col items-start gap-4 group">
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
      <div class="p-6 rounded-3xl bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 shadow-lg hover:bg-white/20 dark:hover:bg-white/10 hover:border-white/30 transition-all duration-300 flex flex-col items-start gap-4 group">
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
      <div class="p-6 rounded-3xl bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 shadow-lg hover:bg-white/20 dark:hover:bg-white/10 hover:border-white/30 transition-all duration-300 flex flex-col items-start gap-4 group">
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
</div>
