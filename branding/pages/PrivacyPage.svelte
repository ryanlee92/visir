<script lang="ts">
  import Icon from '../components/Icon.svelte';
  import Security from 'iconsax-svelte/Security.svelte';
  import Lock from 'iconsax-svelte/Lock.svelte';
  import Key from 'iconsax-svelte/Key.svelte';
  import Global from 'iconsax-svelte/Global.svelte';
</script>

<div class="pt-32 pb-24 min-h-screen">
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
    <!-- Header -->
    <div class="text-center mb-16">
      <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-medium uppercase tracking-wide mb-8 backdrop-blur-md">
        <Security size={14} color="#34d399" />
        <span class="font-display tracking-wide">Privacy Policy</span>
      </div>
      <h1 class="text-4xl sm:text-6xl font-medium font-display tracking-tight text-visir-text mb-6">
        Privacy Policy
      </h1>
      <p class="text-lg text-visir-text-muted font-light">
        Last Updated: December 17, 2025
      </p>
    </div>

    <!-- Content -->
    <div class="prose prose-invert max-w-none space-y-12">
      <!-- Introduction -->
      <section class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-3xl p-8 shadow-lg">
        <p class="text-visir-text-muted font-light leading-relaxed mb-4">
          We are Wave Corporation ("we", "us", or "our"), and we provide you services under our Terms of Service. 
          Visir Application ("App" or "Visir") helps you handle your email accounts, chats, conversations, calendar, 
          and tasks all at once.
        </p>
        <p class="text-visir-text-muted font-light leading-relaxed">
          We are committed to protecting your privacy and your right to privacy. This Privacy Policy explains how we 
          collect, use, disclose, and protect your personal information when you use Visir.
        </p>
        <p class="text-visir-text-muted font-light leading-relaxed mt-4">
          By using Visir, you agree to the collection and use of information in accordance with this Privacy Policy. 
          If you do not agree with our policies and practices, do not use our App.
        </p>
      </section>

      <!-- 1. Applicability -->
      <section>
        <h2 class="text-2xl font-display font-medium text-visir-text mb-4 flex items-center gap-3">
          <span class="text-3xl text-visir-primary">1.</span>
          Applicability
        </h2>
        <div class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-2xl p-6">
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            This Privacy Policy applies to the personal information we collect when you use the Visir Application 
            ("App" or "Visir"), and your personal information used by any additional services available within the 
            App and any other services that integrate or operate in conjunction with the App.
          </p>
          <p class="text-visir-text-muted font-light leading-relaxed">
            You have the right to object to this Privacy Policy or to us collecting or processing your information, 
            but there will be restrictions on your use of the App. Your continued use of the App constitutes your 
            acceptance of our Privacy Policy.
          </p>
        </div>
      </section>

      <!-- 2. Information We Collect -->
      <section>
        <h2 class="text-2xl font-display font-medium text-visir-text mb-4 flex items-center gap-3">
          <span class="text-3xl text-visir-primary">2.</span>
          Information That We Collect
        </h2>
        <div class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-2xl p-6">
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            <strong class="text-visir-text font-medium">We do not store any emails, chats, conversations, or calendar events</strong> from the integrated services. 
            We only collect information that is strictly necessary to provide the App and related services.
          </p>
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            To provide our services, we may collect:
          </p>
          <ul class="space-y-3 text-visir-text-muted font-light leading-relaxed ml-4">
            <li class="flex items-start gap-2">
              <span class="text-visir-primary mt-1">•</span>
              <span>
                <strong class="text-visir-text font-medium">Identifiers:</strong> Name, email address, and IP address. 
                You can use your Google ID, Apple ID, email address, and password to create a Visir user ID. After you 
                create your account, we collect your Google ID, Apple ID, or email address and password.
              </span>
            </li>
            <li class="flex items-start gap-2">
              <span class="text-visir-primary mt-1">•</span>
              <span>
                <strong class="text-visir-text font-medium">Device information and access logs:</strong> When you use 
                our Services, we generate and store device information, including your device type, OS type, IP address, 
                browser information (including language settings), and terminal ID, and log data, including certain 
                electronic identifiers automatically provided by your device, such as cookie data and mobile application IDs.
              </span>
            </li>
            <li class="flex items-start gap-2">
              <span class="text-visir-primary mt-1">•</span>
              <span>
                <strong class="text-visir-text font-medium">Billing address and payment information:</strong> When you 
                sign up for paid services offered within Visir, your billing address and payment information such as payment 
                history, subscription expiration date, and price of the subscription you are using is stored. This information 
                will also be stored by our payment processor.
              </span>
            </li>
            <li class="flex items-start gap-2">
              <span class="text-visir-primary mt-1">•</span>
              <span>
                <strong class="text-visir-text font-medium">AI Suggestions (Optional):</strong> By default, Visir may 
                transmit the subject line, sender, timestamps, and textual content of each incoming email or Slack message 
                to AI service providers (such as OpenAI) for real-time importance scoring. The "store" parameter is set to 
                false, so AI providers do not retain or further process this data once the response is returned. You may 
                disable AI Suggestions at any time in Settings, or use your own API key to ensure data flows directly to 
                your personal API console.
              </span>
            </li>
            <li class="flex items-start gap-2">
              <span class="text-visir-primary mt-1">•</span>
              <span>
                <strong class="text-visir-text font-medium">OAuth tokens and credentials:</strong> When you connect 
                third-party services (such as Gmail, Outlook, Slack, Google Calendar), Visir stores OAuth access tokens and 
                refresh tokens locally on your device to maintain these connections. These tokens are stored securely on 
                your device and are not transmitted to Visir servers except as necessary to refresh expired tokens directly 
                with the service provider.
              </span>
            </li>
            <li class="flex items-start gap-2">
              <span class="text-visir-primary mt-1">•</span>
              <span>
                <strong class="text-visir-text font-medium">Local database cache:</strong> Visir uses a local SQLite 
                database on your device to cache email headers, calendar event metadata, and task information for offline 
                access and faster performance. This data remains on your device and is not synchronized to our servers in 
                readable form.
              </span>
            </li>
          </ul>
        </div>
      </section>

      <!-- 3. How We Use Your Information -->
      <section>
        <h2 class="text-2xl font-display font-medium text-visir-text mb-4 flex items-center gap-3">
          <span class="text-3xl text-visir-primary">3.</span>
          How We Use Your Information
        </h2>
        <div class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-2xl p-6">
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            We use your information for the following business purposes:
          </p>
          <ul class="space-y-3 text-visir-text-muted font-light leading-relaxed ml-4">
            <li class="flex items-start gap-2">
              <span class="text-visir-primary mt-1">•</span>
              <span>
                <strong class="text-visir-text font-medium">Providing the App:</strong> We use your information to 
                operate the App; identify users; use one account on multiple devices and to transfer accounts to other devices; 
                monitor, deter, or prevent unauthorized use of the App or fraudulent use; contact you about changes to our 
                Terms of Use and Privacy Policy, and updates to our App; provide customer support; troubleshoot bugs or errors; 
                improve the App; test new features; and better understand your activity while using the App.
              </span>
            </li>
            <li class="flex items-start gap-2">
              <span class="text-visir-primary mt-1">•</span>
              <span>
                <strong class="text-visir-text font-medium">Enforcing our Terms:</strong> We may use your information 
                to assist with enforcement of our Terms, this Privacy Policy, and other agreements.
              </span>
            </li>
            <li class="flex items-start gap-2">
              <span class="text-visir-primary mt-1">•</span>
              <span>
                <strong class="text-visir-text font-medium">To comply with applicable law:</strong> We use your information 
                to determine whether there has been wrongful use contrary to laws and regulations or the Terms and to sanction. 
                We may also use your information to verify the consent of legal representatives when collecting personal information 
                from minors, and to verify the identity of legal representatives when exercising their rights.
              </span>
            </li>
            <li class="flex items-start gap-2">
              <span class="text-visir-primary mt-1">•</span>
              <span>
                <strong class="text-visir-text font-medium">Providing AI-generated prioritization:</strong> By default, 
                the App labels inbox items with importance badges using on-device or real-time cloud inferences powered by 
                AI service providers. No personal data is stored on Visir servers or by AI providers for this purpose when 
                using default settings, and you can turn the feature off in Settings or use your own API key.
              </span>
            </li>
          </ul>
        </div>
      </section>

      <!-- 4. Data Storage and Protection -->
      <section>
        <h2 class="text-2xl font-display font-medium text-visir-text mb-4 flex items-center gap-3">
          <span class="text-3xl text-visir-primary">4.</span>
          Storage and Protection of Information
        </h2>
        <div class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-2xl p-6 space-y-4">
          <div>
            <h3 class="text-lg font-display font-medium text-visir-text mb-2 flex items-center gap-2">
              <Lock size={20} color="#34d399" />
              Storage of Information
            </h3>
            <p class="text-visir-text-muted font-light leading-relaxed">
              We use cloud services such as Amazon Web Services (AWS) to store your information, and information is kept 
              anonymized where possible. To protect your personal information, we use databases and security protocols 
              provided by cloud service providers such as AWS or Google Inc.
            </p>
          </div>
          <div>
            <h3 class="text-lg font-display font-medium text-visir-text mb-2 flex items-center gap-2">
              <Security size={20} color="#34d399" />
              Protection of Information
            </h3>
            <ul class="space-y-2 text-visir-text-muted font-light leading-relaxed ml-4">
              <li class="flex items-start gap-2">
                <span class="text-visir-primary mt-1">•</span>
                <span>
                  <strong class="text-visir-text font-medium">Administrative protection measures:</strong> Establish 
                  and implement an internal management plan, operate a dedicated team, and train employees regularly.
                </span>
              </li>
              <li class="flex items-start gap-2">
                <span class="text-visir-primary mt-1">•</span>
                <span>
                  <strong class="text-visir-text font-medium">Technical protection measures:</strong> Managing access 
                  rights to personal information processing systems, installing access control systems, encrypting personal 
                  information, and installing and updating security programs.
                </span>
              </li>
            </ul>
          </div>
          <div class="bg-emerald-500/10 border border-emerald-500/20 rounded-xl p-4 mt-4">
            <p class="text-emerald-400 font-medium mb-2 flex items-center gap-2">
              <Key size={18} color="#34d399" />
              End-to-End Encryption
            </p>
            <p class="text-visir-text-muted font-light leading-relaxed text-sm mb-2">
              Any task created in Visir is fully encrypted using AES-CBC encryption before it hits our database. Task titles 
              and descriptions are encrypted with a secure encryption key, and each encryption operation uses a unique random 
              salt to ensure that even identical content produces different ciphertext. This ensures that we cannot read your 
              tasks even if we had access to our database.
            </p>
            <p class="text-visir-text-muted font-light leading-relaxed text-sm">
              <strong class="text-emerald-400 font-medium">Local Search:</strong> We don't do server-side text search. 
              We lazy-load your encrypted data by date and search securely on your local machine. All decryption happens 
              client-side, ensuring your task content never leaves your device in unencrypted form.
            </p>
          </div>
          <div class="bg-blue-500/10 border border-blue-500/20 rounded-xl p-4 mt-4">
            <p class="text-blue-400 font-medium mb-2 flex items-center gap-2">
              <Global size={18} color="#60a5fa" />
              Local Data Storage
            </p>
            <p class="text-visir-text-muted font-light leading-relaxed text-sm">
              Visir uses a local SQLite database on your device to cache email headers, calendar event metadata, and other 
              data for offline access. This local database is stored securely on your device and is never synchronized to 
              our servers in readable form. OAuth tokens for integrated services are also stored locally on your device and 
              are only used to refresh connections directly with the service providers.
            </p>
          </div>
        </div>
      </section>

      <!-- 5. Information Sharing with Third Parties -->
      <section>
        <h2 class="text-2xl font-display font-medium text-visir-text mb-4 flex items-center gap-3">
          <span class="text-3xl text-visir-primary">5.</span>
          Information Sharing with Third Parties
        </h2>
        <div class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-2xl p-6">
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            We may share personal information with third parties to the extent necessary to develop and/or support Visir. 
            We do not share your information for advertising purposes, nor do we profit from sharing your information.
          </p>
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            We share your personal information with third parties listed below to the extent necessary to provide services, 
            technical and customer support:
          </p>
          <ul class="space-y-3 text-visir-text-muted font-light leading-relaxed ml-4">
            <li class="flex items-start gap-2">
              <span class="text-visir-primary mt-1">•</span>
              <span>
                <strong class="text-visir-text font-medium">Subcontractors:</strong> We rely on carefully selected 
                subcontractors that perform services on our behalf: payment processors handle payments and store billing details, 
                Amazon Web Services (AWS) provides encrypted cloud hosting and storage, Supabase provides authentication and 
                encrypted database services, and analytics providers supply product-usage analytics. For AI Suggestions, the 
                subject line, sender, timestamps, and textual content of each email or Slack message are sent to AI service 
                providers over TLS with the "store" parameter explicitly set to false. AI providers discard the data immediately 
                after generating the importance score and do not use it to train their models. AI suggestion results may be 
                cached in Supabase for performance, but the original email or message content is not stored.
              </span>
            </li>
            <li class="flex items-start gap-2">
              <span class="text-visir-primary mt-1">•</span>
              <span>
                <strong class="text-visir-text font-medium">Integrated Service Providers:</strong> We may share your 
                information with service providers that are integrated with Visir such as Google, Gmail, Outlook, Slack, etc. 
                In this case, Visir's use of information received from Integrated Service Provider's APIs will adhere to their 
                User Data Policy. <strong class="text-visir-text">Importantly, when you connect these services, Visir 
                communicates directly from your device to their servers. Your sensitive integration data never passes through 
                Visir's servers.</strong>
              </span>
            </li>
          </ul>
        </div>
      </section>

      <!-- 6. Term of Storage -->
      <section>
        <h2 class="text-2xl font-display font-medium text-visir-text mb-4 flex items-center gap-3">
          <span class="text-3xl text-visir-primary">6.</span>
          Term of Storage
        </h2>
        <div class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-2xl p-6">
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            In principle, we will destroy your personal information when you delete your account. If you are inactive for 
            36 months, Visir will send you an email notifying you that your account will be suspended, and if you do not 
            re-login within the notified renewal period, your account will be deleted and your personal information will be destroyed.
          </p>
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            However, we may retain your personal information after you delete your account for as long as we reasonably and 
            legally need to keep it, for example:
          </p>
          <ul class="space-y-2 text-visir-text-muted font-light leading-relaxed ml-4">
            <li class="flex items-start gap-2">
              <span class="text-visir-primary mt-1">•</span>
              <span>To comply with any applicable legal, regulatory or statutory obligation.</span>
            </li>
            <li class="flex items-start gap-2">
              <span class="text-visir-primary mt-1">•</span>
              <span>To complete the customer support services we were providing.</span>
            </li>
            <li class="flex items-start gap-2">
              <span class="text-visir-primary mt-1">•</span>
              <span>To resolve disputes between you and us.</span>
            </li>
          </ul>
        </div>
      </section>

      <!-- 7. Use of Cookies -->
      <section>
        <h2 class="text-2xl font-display font-medium text-visir-text mb-4 flex items-center gap-3">
          <span class="text-3xl text-visir-primary">7.</span>
          Use of Cookies
        </h2>
        <div class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-2xl p-6">
          <p class="text-visir-text-muted font-light leading-relaxed">
            We utilize cookies to enhance the quality of our service and monitor your usage of the App and address specific 
            security concerns. We do not employ cookies for profiling or advertising purposes. Upon accessing our application, 
            we send the cookies to your device. The cookies assist us in tracking your visits and activity within the App, 
            and in understanding your interaction with us.
          </p>
        </div>
      </section>

      <!-- 8. International Transfers -->
      <section>
        <h2 class="text-2xl font-display font-medium text-visir-text mb-4 flex items-center gap-3">
          <span class="text-3xl text-visir-primary">8.</span>
          International Transfers of Information
        </h2>
        <div class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-2xl p-6">
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            We will process and store your information in the country where the cloud service provider Amazon Web Services (AWS)'s 
            server is located. We may transfer your information to other countries if it is necessary to provide our services, 
            including third party sharing described in Section 5.
          </p>
          <p class="text-visir-text-muted font-light leading-relaxed">
            Because AI Suggestions may be on by default, the information listed in Section 2 may be processed on servers located 
            in the United States or other countries where AI service providers operate. We ensure that such transfers occur under 
            contractual safeguards that provide privacy protection, and you can stop these transfers at any time by disabling AI 
            Suggestions in Settings or using your own API key.
          </p>
        </div>
      </section>

      <!-- 9. Your Privacy Rights -->
      <section>
        <h2 class="text-2xl font-display font-medium text-visir-text mb-4 flex items-center gap-3">
          <span class="text-3xl text-visir-primary">9.</span>
          Your Privacy Rights
        </h2>
        <div class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-2xl p-6">
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            You, as the subject of personal data, have the following rights:
          </p>
          <ul class="space-y-2 text-visir-text-muted font-light leading-relaxed ml-4">
            <li class="flex items-start gap-2">
              <span class="text-visir-primary mt-1">•</span>
              <span>Right to access your personal information.</span>
            </li>
            <li class="flex items-start gap-2">
              <span class="text-visir-primary mt-1">•</span>
              <span>Right to request correction or deletion of personal information.</span>
            </li>
            <li class="flex items-start gap-2">
              <span class="text-visir-primary mt-1">•</span>
              <span>Right to object.</span>
            </li>
            <li class="flex items-start gap-2">
              <span class="text-visir-primary mt-1">•</span>
              <span>Right to request the suspension of processing of your personal information.</span>
            </li>
            <li class="flex items-start gap-2">
              <span class="text-visir-primary mt-1">•</span>
              <span>Right to withdraw consent.</span>
            </li>
          </ul>
        </div>
      </section>

      <!-- 10. Contact Information -->
      <section>
        <h2 class="text-2xl font-display font-medium text-visir-text mb-4 flex items-center gap-3">
          <span class="text-3xl text-visir-primary">10.</span>
          Contact Information
        </h2>
        <div class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-2xl p-6">
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            If you have any questions about this Privacy Policy or wish to exercise your privacy rights, please contact us:
          </p>
          <div class="space-y-2 text-visir-text-muted font-light">
            <p>
              <strong class="text-visir-text font-medium">Wave Corporation</strong>
            </p>
            <p>
              <strong class="text-visir-text font-medium">Email:</strong> support@wavetogether.com
            </p>
          </div>
        </div>
      </section>

      <!-- 11. Amendments -->
      <section>
        <h2 class="text-2xl font-display font-medium text-visir-text mb-4 flex items-center gap-3">
          <span class="text-3xl text-visir-primary">11.</span>
          Amendments to Privacy Policy
        </h2>
        <div class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-2xl p-6">
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            We may change our Privacy Policy from time to time for a variety of reasons, including to improve our procedures 
            for handling your personal information, to reflect changes to our Services, or to comply with applicable law. 
            If we make material changes to our Privacy Policy, we will notify you of the changes on the App or by other 
            reasonable means.
          </p>
          <p class="text-visir-text-muted font-light leading-relaxed">
            You should carefully review the changes, and if you agree to the changes, you may continue to use our App. However, 
            if you disagree with the changes or no longer wish to use our App, you may choose to delete your account and leave 
            the App. Your continued use of our App after we post a notice of changes on the App will constitute your acceptance 
            of the changes to our Privacy Policy.
          </p>
          <p class="text-visir-text-muted font-light leading-relaxed mt-4">
            This Privacy Policy was first disclosed on December 17, 2025.
          </p>
        </div>
      </section>
    </div>
  </div>
</div>
