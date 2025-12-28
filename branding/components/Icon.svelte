<script lang="ts">
  import { FontAwesomeIcon } from '@fortawesome/svelte-fontawesome';
  import { faGithub } from '@fortawesome/free-brands-svg-icons';
  
  // Import commonly used iconsax icons
  import ArrowRight from 'iconsax-svelte/ArrowRight.svelte';
  import ArrowLeft from 'iconsax-svelte/ArrowLeft.svelte';
  import PlayCircle from 'iconsax-svelte/PlayCircle.svelte';
  import Flash from 'iconsax-svelte/Flash.svelte';
  import TickCircle from 'iconsax-svelte/TickCircle.svelte';
  import TickSquare from 'iconsax-svelte/TickSquare.svelte';
  import Message from 'iconsax-svelte/Message.svelte';
  import Messages2 from 'iconsax-svelte/Messages2.svelte';
  import Sms from 'iconsax-svelte/Sms.svelte';
  import DirectboxDefault from 'iconsax-svelte/DirectboxDefault.svelte';
  import Menu from 'iconsax-svelte/Menu.svelte';
  import CloseCircle from 'iconsax-svelte/CloseCircle.svelte';
  import Sun1 from 'iconsax-svelte/Sun1.svelte';
  import Moon from 'iconsax-svelte/Moon.svelte';
  import Add from 'iconsax-svelte/Add.svelte';
  import SearchNormal from 'iconsax-svelte/SearchNormal.svelte';
  import Filter from 'iconsax-svelte/Filter.svelte';
  import Clock from 'iconsax-svelte/Clock.svelte';
  import Calendar from 'iconsax-svelte/Calendar.svelte';
  import Cpu from 'iconsax-svelte/Cpu.svelte';
  import Monitor from 'iconsax-svelte/Monitor.svelte';
  import Mobile from 'iconsax-svelte/Mobile.svelte';
  import Code from 'iconsax-svelte/Code.svelte';
  import Setting from 'iconsax-svelte/Setting.svelte';
  import Folder from 'iconsax-svelte/Folder.svelte';
  import DocumentText from 'iconsax-svelte/DocumentText.svelte';
  import Wifi from 'iconsax-svelte/Wifi.svelte';
  import User from 'iconsax-svelte/User.svelte';
  import People from 'iconsax-svelte/People.svelte';
  import Crown from 'iconsax-svelte/Crown.svelte';
  import MessageQuestion from 'iconsax-svelte/MessageQuestion.svelte';
  import Security from 'iconsax-svelte/Security.svelte';
  import Lock from 'iconsax-svelte/Lock.svelte';
  import Key from 'iconsax-svelte/Key.svelte';
  import CloudCross from 'iconsax-svelte/CloudCross.svelte';
  import Global from 'iconsax-svelte/Global.svelte';
  import Book from 'iconsax-svelte/Book.svelte';
  import Video from 'iconsax-svelte/Video.svelte';
  import ArrowDown1 from 'iconsax-svelte/ArrowDown1.svelte';
  import ArrowUp1 from 'iconsax-svelte/ArrowUp1.svelte';
  import ArrowRight1 from 'iconsax-svelte/ArrowRight1.svelte';
  import ArrowLeft1 from 'iconsax-svelte/ArrowLeft1.svelte';
  import ArrowSwapHorizontal from 'iconsax-svelte/ArrowSwapHorizontal.svelte';
  import DocumentDownload from 'iconsax-svelte/DocumentDownload.svelte';
  import MagicStar from 'iconsax-svelte/MagicStar.svelte';
  import Document from 'iconsax-svelte/Document.svelte';
  
  export let name: string;
  export let size: number = 24;
  export let color: string = 'currentColor';
  export let variant: 'Linear' | 'Outline' | 'Bold' | 'Bulk' | 'Broken' | 'TwoTone' = 'Linear';
  export let className: string = '';
  
  // Icon mapping
  const iconMap: Record<string, any> = {
    'ArrowRight': ArrowRight,
    'ArrowLeft': ArrowLeft,
    'ArrowRightLeft': ArrowSwapHorizontal,
    'ChevronRight': ArrowRight1,
    'ChevronLeft': ArrowLeft1,
    'ChevronDown': ArrowDown1,
    'ChevronUp': ArrowUp1,
    'PlayCircle': PlayCircle,
    'Download': DocumentDownload,
    'Menu': Menu,
    'X': CloseCircle,
    'Sun': Sun1,
    'Moon': Moon,
    'Plus': Add,
    'Search': SearchNormal,
    'Filter': Filter,
    'CheckCircle2': TickCircle,
    'CheckSquare': TickSquare,
    'Clock': Clock,
    'Calendar': Calendar,
    'MessageSquare': DirectboxDefault,
    'MessagesSquare': Messages2,
    'Mail': DirectboxDefault,
    'Cpu': Cpu,
    'Monitor': Monitor,
    'Smartphone': Mobile,
    'Code': Code,
    'Settings': Setting,
    'Folder': Folder,
    'FileText': Document,
    'Wifi': Wifi,
    'User': User,
    'Users': People,
    'Crown': Crown,
    'HelpCircle': MessageQuestion,
    'Shield': Security,
    'Lock': Lock,
    'Key': Key,
    'CloudOff': CloudCross,
    'Globe': Global,
    'Book': Book,
    'Video': Video,
    'Zap': Flash,
    'Sparkles': MagicStar,
  };
  
  // FontAwesome icon mapping (for icons not available in iconsax)
  const faIconMap: Record<string, any> = {
    'Github': faGithub,
    'GitHub': faGithub,
  };
  
  $: IconComponent = iconMap[name] || null;
  $: FaIcon = faIconMap[name] || null;
</script>

{#if IconComponent}
  <svelte:component this={IconComponent} {size} {color} {variant} class={className} />
{:else if FaIcon}
  <!-- FontAwesome fallback -->
  <FontAwesomeIcon icon={FaIcon} style="width: {size}px; height: {size}px; color: {color};" class={className} />
{:else}
  <!-- Fallback placeholder -->
  <div class="inline-block {className}" style="width: {size}px; height: {size}px;">
    <span class="text-yellow-500 text-xs" title="Icon '{name}' not found">?</span>
  </div>
{/if}

