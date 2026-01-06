<script lang="ts">
  import Hero from '../components/Hero.svelte';
  import FeatureSection from '../components/FeatureSection.svelte';
  import IntegrationsSection from '../components/IntegrationsSection.svelte';
  import PrivacySection from '../components/PrivacySection.svelte';
  import FAQ from '../components/FAQ.svelte';
  import CTA from '../components/CTA.svelte';
  import type { Feature } from '../types';

  const features: Feature[] = [
    {
      title: "Never Alt-Tab Again.",
      description: "Email, Slack, and Tasks lived apart. We married them. Drag any message to your calendar to time-block it, or instantly convert it to a task. Reply to emails or chats directly within Visir—no need to switch apps. Empty your inbox in minutes, not hours.",
      icon: "Sms",
      imagePosition: 'right',
      visualType: 'desktop',
      benefits: [
        "Protect your focus time: Drag tasks directly onto your calendar to secure focus time.",
        "Don't lose that thought: Use global shortcuts to capture thoughts without breaking flow.",
        "Universal Inbox: Manage Email, Team chat, and Calendars in a single list."
      ]
    },
    {
      title: "Your Brain, Just Organized by AI.",
      description: "It plans your day before you even wake up. Catch up on 100 Slack messages in 10 seconds. Your Home tab is an intelligent briefing that automatically analyzes your inbox to categorize items by project and urgency. Get a 'Who, What, Why' summary before every call, so you arrive ready.",
      icon: "Cpu",
      imagePosition: 'left',
      visualType: 'desktop',
      benefits: [
        "Catch up on 100 Slack messages in 10 seconds: AI separates urgent signals from low-priority noise automatically.",
        "Arrive ready: Get a 'Who, What, Why' summary before every call.",
        "Draft responses instantly: AI that understands the thread and drafts context-aware replies."
      ]
    },
    {
      title: "Full-Power Vertical Apps",
      description: "Don't settle for shallow integrations. Visir provides full-featured dedicated tabs for Mail, Chat, Calendar, and Tasks. Switch between a high-level AI overview and deep-focus work in specific tools with a single click.",
      icon: "Monitor",
      imagePosition: 'right',
      visualType: 'desktop',
      benefits: [
        "No Compromise: Access the full feature set of your native tools within Visir.",
        "Keyboard First: Navigate your entire workflow without touching the mouse.",
        "Offline Capability: Search, read, and organize your work even without an internet connection."
      ]
    },
    {
      title: "Command Center in Your Pocket.",
      description: "Desktop power, mobile size. Most mobile apps are just read-only companions. Visir Mobile is a full command center in your pocket. Triage email, manage projects, and block time on your calendar with the same power as the desktop app.",
      icon: "Devices",
      imagePosition: 'left',
      visualType: 'mobile',
      benefits: [
        "Desktop power, mobile size: If you can do it on desktop, you can do it on mobile.",
        "Swipe to organize: Swipe to snooze, archive, or schedule tasks in seconds.",
        "See your 'Up Next' instantly: Home Screen Widget shows your context without opening the app."
      ]
    }
  ];
</script>

<Hero />

<div id="features" class="relative">
  <div class="relative z-10">
    {#each features as feature, index}
      <FeatureSection {feature} {index} />
    {/each}
  </div>
</div>

<IntegrationsSection />

<PrivacySection />

<FAQ />

<CTA />
