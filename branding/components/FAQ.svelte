<script lang="ts">
  import Icon from './Icon.svelte';

  interface FAQItem {
    question: string;
    answer: string;
  }

  const faqs: FAQItem[] = [
    {
      question: "How does Visir integrate with Gmail, Slack, and Calendar?",
      answer: "Visir connects directly to your Gmail, Outlook, Slack, and Google Calendar accounts through secure OAuth authentication. Once connected, Visir syncs your data locally and provides a unified interface to manage everything in one place. All integrations support real-time bidirectional sync, so changes made in Visir instantly reflect in your original apps."
    },
    {
      question: "Can I use Visir offline?",
      answer: "Yes! Visir syncs your emails, messages, and calendar events to a local database on your device. You can read your content without an internet connection. However, modifications like sending emails, creating tasks, or updating calendar events require an internet connection."
    },
    {
      question: "How does the AI assistant work?",
      answer: "Visir's AI analyzes your inbox to categorize items by project and urgency, summarizes meeting contexts, and helps draft responses. By default, AI processing happens via direct API calls that don't retain data for training. For maximum privacy, you can use your own API key to ensure your data only flows between your device and your personal API console."
    },
    {
      question: "Is my data secure and private?",
      answer: "Absolutely. Visir processes most data locally on your device. Your email and message content is never stored on our servers—only task metadata is encrypted and stored for sync purposes. Text search is performed locally, and you have full control over what data is shared with AI services through the BYOK option."
    },
    {
      question: "Can I replace my existing productivity tools?",
      answer: "Yes! Visir provides full-featured tabs for Mail, Chat, Calendar, and Tasks with complete feature parity. You can manage Gmail, Slack, Google Calendar, and Outlook entirely within Visir without switching apps. All changes sync bidirectionally, so you can still use your original apps when needed."
    },
    {
      question: "What platforms does Visir support?",
      answer: "Visir is available on macOS, Windows, iOS, and Android. The mobile apps offer 100% feature parity with the desktop version, so you can manage your entire workflow from any device. All your data syncs seamlessly across platforms."
    }
  ];

  let openIndex: number | null = 0;

  function toggle(index: number) {
    openIndex = openIndex === index ? null : index;
  }
</script>

<section class="py-24 relative">
  <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
    <h2 class="text-3xl md:text-4xl font-semibold font-display text-visir-text mb-12 text-center">
      Frequently Asked Questions
    </h2>
    
    <div class="space-y-4">
      {#each faqs as faq, index}
        <div 
          class="rounded-3xl border backdrop-blur-sm shadow-lg transition-transform duration-200 overflow-hidden group {openIndex === index ? 'bg-white/10 dark:bg-white/5 border-white/20 dark:border-white/10 shadow-xl' : 'bg-white/10 dark:bg-white/5 border-white/20 dark:border-white/10 hover:bg-white/20 dark:hover:bg-white/10 hover:border-white/30 dark:hover:border-white/20 hover:shadow-xl'}"
          style="contain: layout style paint;"
        >
          <button
            class="w-full px-6 py-5 text-left flex items-center justify-between focus:outline-none"
            on:click={() => toggle(index)}
          >
            <span class="font-medium font-display text-lg pr-4 {openIndex === index ? 'text-visir-primary' : 'text-visir-text'}">
              {faq.question}
            </span>
            {#if openIndex === index}
                <Icon name="ChevronUp" className="text-visir-primary flex-shrink-0" size={20} />
            {:else}
              <Icon name="ChevronDown" className="text-visir-text-muted flex-shrink-0 group-hover:text-visir-text transition-colors" size={20} />
            {/if}
          </button>
          
          <div 
            class="transition-all duration-200 ease-in-out px-6 overflow-hidden {openIndex === index ? 'max-h-96 pb-6 opacity-100' : 'max-h-0 opacity-0'}"
          >
            <p class="text-visir-text-muted font-light leading-relaxed text-base">
              {faq.answer}
            </p>
          </div>
        </div>
      {/each}
    </div>
  </div>
</section>
