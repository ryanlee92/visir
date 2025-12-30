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
      title: "Unified Context, Zero Switching",
      description: "Visir unifies Email, Team chat, and Calendars into one intelligent timeline. Drag any message to your calendar to time-block it, or instantly convert it to a task. Reply to emails or chats directly within Visir—no need to switch apps.",
      icon: "Sms",
      imagePosition: 'right',
      visualType: 'desktop',
      benefits: [
        "Universal Inbox: Manage Email, Team chat, and Calendars in a single list.",
        "Time Blocking: Drag tasks directly onto your calendar to secure focus time.",
        "Instant Capture: Use global shortcuts to capture thoughts without breaking flow."
      ]
    },
    {
      title: "The AI Executive Assistant",
      description: "Your Home tab is an intelligent briefing, not just a list. Visir AI automatically analyzes your inbox to categorize items by project and urgency. It prepares you for meetings by summarizing key context, so you arrive ready.",
      icon: "Cpu",
      imagePosition: 'left',
      visualType: 'desktop',
      benefits: [
        "Smart Triage: AI separates urgent signals from low-priority noise automatically.",
        "Meeting Prep: Get a 'Who, What, Why' summary before every call.",
        "Context-Aware Replies: Draft responses instantly with AI that understands the thread."
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
      title: "Uncompromised Mobile Experience",
      description: "Most mobile apps are just read-only companions. Visir Mobile is a full command center in your pocket. Triage email, manage projects, and block time on your calendar with the same power as the desktop app.",
      icon: "Devices",
      imagePosition: 'left',
      visualType: 'mobile',
      benefits: [
        "100% Feature Parity: If you can do it on desktop, you can do it on mobile.",
        "Native Gestures: Swipe to snooze, archive, or schedule tasks in seconds.",
        "Home Screen Widget: See your 'Up Next' context instantly without opening the app."
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
