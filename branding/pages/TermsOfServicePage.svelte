<script lang="ts">
  import Icon from '../components/Icon.svelte';
  import User from 'iconsax-svelte/User.svelte';
  import Security from 'iconsax-svelte/Security.svelte';
</script>

<div class="pt-32 pb-24 min-h-screen">
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
    <!-- Header -->
    <div class="text-center mb-16">
      <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-blue-500/10 border border-blue-500/20 text-blue-400 text-xs font-medium uppercase tracking-wide mb-8 backdrop-blur-md">
        <Icon name="FileText" size={14} />
        <span class="font-display tracking-wide">Terms of Service</span>
      </div>
      <h1 class="text-4xl sm:text-6xl font-medium font-display tracking-tight text-visir-text mb-6">
        Terms of Service
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
          Wave Corporation ("Wave", "Company", "us", "we", or "our") provides the Visir Application 
          ("App" or "Visir") and related services (collectively, the "Service") subject to your compliance 
          with all the terms, conditions, and notices contained or referenced herein (the "Terms of Service" 
          or the "Agreement").
        </p>
        <p class="text-visir-text-muted font-light leading-relaxed">
          By using the Service or accessing the App, you agree to the Terms of Service and the Privacy Policy, 
          available at visir.pro/privacy, which is incorporated herein by reference. If you do not agree, 
          do not use the Service.
        </p>
        <p class="text-visir-text-muted font-light leading-relaxed mt-4">
          Your continued use of the Service after the posting of any modifications shall constitute your agreement 
          to be bound by such modified Terms of Service.
        </p>
      </section>

      <!-- 1. Eligibility -->
      <section>
        <h2 class="text-2xl font-display font-medium text-visir-text mb-4 flex items-center gap-3">
          <span class="text-3xl text-visir-primary">1.</span>
          Eligibility
        </h2>
        <div class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-2xl p-6">
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            You ("you" or "User") represent and warrant that you are at least 18 years of age. If you are under 
            age 18, then you may not, under any circumstances or for any reason, use the Service.
          </p>
          <p class="text-visir-text-muted font-light leading-relaxed">
            We may, in our sole discretion, refuse to offer the Service to any person or entity and change the 
            eligibility criteria for using the Service at any time. The right to access the Service is revoked 
            where these Terms of Service or use of the Service is prohibited or to the extent offering, sale, or 
            provision of the Service conflicts with any applicable law, rule, or regulation.
          </p>
        </div>
      </section>

      <!-- 2. Account Information -->
      <section>
        <h2 class="text-2xl font-display font-medium text-visir-text mb-4 flex items-center gap-3">
          <span class="text-3xl text-visir-primary">2.</span>
          Account Information
        </h2>
        <div class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-2xl p-6 space-y-4">
          <div>
            <h3 class="text-lg font-display font-medium text-visir-text mb-2 flex items-center gap-2">
              <User size={20} color="#60a5fa" />
              Registering for an Account
            </h3>
            <p class="text-visir-text-muted font-light leading-relaxed mb-4">
              Certain features or services offered on or through the Service may require you to open an account 
              (including a username, password, and payment information). Visir accounts will give you access to 
              the Service and functionality that we may establish and maintain from time to time and at our 
              sole discretion.
            </p>
            <p class="text-visir-text-muted font-light leading-relaxed">
              When you connect Visir with a third-party service and grant us permission to access your account, 
              we never request or receive your log-in credentials for that service. We use the OAuth authorization 
              protocol to request a token from the service; the token then gives us access to your account to the 
              extent authorized by you and permitted by that service.
            </p>
          </div>
          <div>
            <h3 class="text-lg font-display font-medium text-visir-text mb-2 flex items-center gap-2">
              <Security size={20} color="#60a5fa" />
              Your Responsibility for Your Account
            </h3>
            <p class="text-visir-text-muted font-light leading-relaxed mb-4">
              You are responsible for taking all steps to ensure that no unauthorized person shall have access to 
              your account or password. When creating your account, you must provide accurate and complete information. 
              We encourage you to use "strong" passwords (passwords that use a combination of upper and lower case 
              letters, numbers, and symbols) with your account.
            </p>
            <p class="text-visir-text-muted font-light leading-relaxed">
              It is your sole responsibility to (i) control the dissemination and use of your account and password; 
              and (ii) promptly inform us of any need to deactivate an account or password. We are not liable for 
              any harm related to the theft of passwords, or your disclosure of passwords. You shall immediately 
              notify us of any unauthorized use of your account or password or any breach of confidentiality.
            </p>
          </div>
        </div>
      </section>

      <!-- 3. Visir Content -->
      <section>
        <h2 class="text-2xl font-display font-medium text-visir-text mb-4 flex items-center gap-3">
          <span class="text-3xl text-visir-primary">3.</span>
          Visir Content
        </h2>
        <div class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-2xl p-6">
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            All materials on the Service, including the Service itself and all Intellectual Property Rights contained 
            therein or related thereto, including text, graphics, user and visual interfaces, photographs, trademarks, 
            logos, sounds, music, artwork, applications, computer code and associated documentation (collectively, the 
            "Content"), including but not limited to the design, structure, arrangement, and "look and feel" of such 
            Content, is owned by or licensed to us and our licensors and is protected by copyright, trademark, and 
            other intellectual property rights and laws.
          </p>
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            Subject to the terms and conditions of this Agreement, Visir provides you with a non-exclusive, revocable 
            license to use the Service as expressly permitted by the features and functionality of the Service and the 
            Terms of Service. Visir may terminate this license at any time for any reason or no reason.
          </p>
          <p class="text-visir-text-muted font-light leading-relaxed">
            For the avoidance of doubt, you acknowledge and agree that no part of the Service or the Content may be 
            copied, reverse engineered, or used in any way to create an offering similar to, or competitive with, the Service.
          </p>
        </div>
      </section>

      <!-- 4. User Content -->
      <section>
        <h2 class="text-2xl font-display font-medium text-visir-text mb-4 flex items-center gap-3">
          <span class="text-3xl text-visir-primary">4.</span>
          User Content
        </h2>
        <div class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-2xl p-6">
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            You retain ownership of any content you create, upload, post, send, receive, or store on or through the 
            Service ("User Content"). By submitting User Content through the Service, you grant us a worldwide, 
            non-exclusive, royalty-free license to use, reproduce, modify, adapt, publish, translate, distribute, 
            and display such User Content solely for the purpose of providing and improving the Service.
          </p>
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            You are solely responsible for your User Content and the consequences of posting or publishing it. You 
            represent and warrant that you own or have the necessary licenses, rights, consents, and permissions to 
            use and authorize us to use all patent, trademark, trade secret, copyright, or other proprietary rights 
            in and to any and all User Content.
          </p>
          <p class="text-visir-text-muted font-light leading-relaxed">
            We do not store any emails, chats, conversations, or calendar events from integrated services. We only 
            process and cache such data locally on your device for the purpose of providing the Service functionality. 
            Your data remains under your control and is subject to the privacy policies of the integrated service providers.
          </p>
        </div>
      </section>

      <!-- 5. Prohibited Uses -->
      <section>
        <h2 class="text-2xl font-display font-medium text-visir-text mb-4 flex items-center gap-3">
          <span class="text-3xl text-visir-primary">5.</span>
          Prohibited Uses
        </h2>
        <div class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-2xl p-6">
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            You agree not to use the Service:
          </p>
          <ul class="space-y-3 text-visir-text-muted font-light leading-relaxed ml-4">
            <li class="flex items-start gap-2">
              <span class="text-visir-primary mt-1">•</span>
              <span>In any way that violates any applicable federal, state, local, or international law or regulation.</span>
            </li>
            <li class="flex items-start gap-2">
              <span class="text-visir-primary mt-1">•</span>
              <span>To transmit, or procure the sending of, any advertising or promotional material without our prior written consent.</span>
            </li>
            <li class="flex items-start gap-2">
              <span class="text-visir-primary mt-1">•</span>
              <span>To impersonate or attempt to impersonate the Company, a Company employee, another user, or any other person or entity.</span>
            </li>
            <li class="flex items-start gap-2">
              <span class="text-visir-primary mt-1">•</span>
              <span>In any way that infringes upon the rights of others, or in any way is illegal, threatening, fraudulent, or harmful.</span>
            </li>
            <li class="flex items-start gap-2">
              <span class="text-visir-primary mt-1">•</span>
              <span>To engage in any other conduct that restricts or inhibits anyone's use or enjoyment of the Service.</span>
            </li>
          </ul>
        </div>
      </section>

      <!-- 6. Payment Terms -->
      <section>
        <h2 class="text-2xl font-display font-medium text-visir-text mb-4 flex items-center gap-3">
          <span class="text-3xl text-visir-primary">6.</span>
          Payment Terms
        </h2>
        <div class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-2xl p-6">
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            Prices of the Service, including but not limited to monthly subscription plan fees to the Service, are 
            subject to change upon 30 days notice from us. Such notice may be provided at any time by posting the 
            changes to the Visir website (visir.pro) or the Service itself.
          </p>
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            If you purchase a subscription, you will be charged the subscription fee, plus any applicable taxes, 
            at the beginning of your subscription and each billing period thereafter. Your subscription will 
            automatically renew unless you cancel it before the end of the current billing period.
          </p>
          <p class="text-visir-text-muted font-light leading-relaxed">
            Visir shall not be liable to you or to any third party for any modification, price change, suspension, 
            or discontinuance of the Service.
          </p>
        </div>
      </section>

      <!-- 7. Termination -->
      <section>
        <h2 class="text-2xl font-display font-medium text-visir-text mb-4 flex items-center gap-3">
          <span class="text-3xl text-visir-primary">7.</span>
          Termination
        </h2>
        <div class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-2xl p-6">
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            We may terminate or suspend your account and access to the Service immediately, without prior notice or 
            liability, for any reason whatsoever, including without limitation if you breach the Terms of Service.
          </p>
          <p class="text-visir-text-muted font-light leading-relaxed">
            Upon termination, your right to use the Service will cease immediately. If you wish to terminate your 
            account, you may simply discontinue using the Service or contact us at support@wavetogether.com.
          </p>
        </div>
      </section>

      <!-- 8. Disclaimer of Warranties -->
      <section>
        <h2 class="text-2xl font-display font-medium text-visir-text mb-4 flex items-center gap-3">
          <span class="text-3xl text-visir-primary">8.</span>
          Disclaimer of Warranties
        </h2>
        <div class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-2xl p-6">
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            THE SERVICE IS PROVIDED ON AN "AS IS" AND "AS AVAILABLE" BASIS. WE EXPRESSLY DISCLAIM ALL WARRANTIES 
            OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF 
            MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.
          </p>
          <p class="text-visir-text-muted font-light leading-relaxed">
            We make no warranty that the Service will meet your requirements, be available on an uninterrupted, timely, 
            secure, or error-free basis, or be accurate, reliable, free of viruses or other harmful code, complete, 
            legal, or safe.
          </p>
        </div>
      </section>

      <!-- 9. Limitation of Liability -->
      <section>
        <h2 class="text-2xl font-display font-medium text-visir-text mb-4 flex items-center gap-3">
          <span class="text-3xl text-visir-primary">9.</span>
          Limitation of Liability
        </h2>
        <div class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-2xl p-6">
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL WAVE CORPORATION, ITS AFFILIATES, 
            AGENTS, DIRECTORS, EMPLOYEES, SUPPLIERS, OR LICENSORS BE LIABLE FOR ANY INDIRECT, PUNITIVE, INCIDENTAL, 
            SPECIAL, CONSEQUENTIAL, OR EXEMPLARY DAMAGES, INCLUDING WITHOUT LIMITATION DAMAGES FOR LOSS OF PROFITS, 
            GOODWILL, USE, DATA, OR OTHER INTANGIBLE LOSSES, ARISING OUT OF OR RELATING TO THE USE OF, OR INABILITY 
            TO USE, THE SERVICE.
          </p>
          <p class="text-visir-text-muted font-light leading-relaxed">
            UNDER NO CIRCUMSTANCES WILL WAVE CORPORATION BE RESPONSIBLE FOR ANY DAMAGE, LOSS, OR INJURY RESULTING 
            FROM HACKING, TAMPERING, OR OTHER UNAUTHORIZED ACCESS OR USE OF THE SERVICE OR YOUR ACCOUNT OR THE 
            INFORMATION CONTAINED THEREIN.
          </p>
        </div>
      </section>

      <!-- 10. Indemnification -->
      <section>
        <h2 class="text-2xl font-display font-medium text-visir-text mb-4 flex items-center gap-3">
          <span class="text-3xl text-visir-primary">10.</span>
          Indemnification
        </h2>
        <div class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-2xl p-6">
          <p class="text-visir-text-muted font-light leading-relaxed">
            You agree to defend, indemnify, and hold harmless Wave Corporation, its affiliates, licensors, and service 
            providers, and its and their respective officers, directors, employees, contractors, agents, licensors, 
            suppliers, successors, and assigns from and against any claims, liabilities, damages, judgments, awards, losses, 
            costs, expenses, or fees (including reasonable attorneys' fees) arising out of or relating to your violation 
            of these Terms of Service or your use of the Service.
          </p>
        </div>
      </section>

      <!-- 11. Governing Law -->
      <section>
        <h2 class="text-2xl font-display font-medium text-visir-text mb-4 flex items-center gap-3">
          <span class="text-3xl text-visir-primary">11.</span>
          Governing Law and Dispute Resolution
        </h2>
        <div class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-2xl p-6">
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            The Terms of Service will be governed by and construed in accordance with the laws of the Republic of Korea, 
            without regard to its conflicts of law provisions.
          </p>
          <p class="text-visir-text-muted font-light leading-relaxed">
            Any dispute arising from or relating to the subject matter of these Terms shall be finally settled through 
            binding arbitration in accordance with the rules of the Korean Commercial Arbitration Board, or in the courts 
            of competent jurisdiction in Seoul, Republic of Korea.
          </p>
        </div>
      </section>

      <!-- 12. Changes to Terms -->
      <section>
        <h2 class="text-2xl font-display font-medium text-visir-text mb-4 flex items-center gap-3">
          <span class="text-3xl text-visir-primary">12.</span>
          Changes to Terms of Service
        </h2>
        <div class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-2xl p-6">
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            Visir may modify or update these Terms of Service from time to time. However, we will provide you with at 
            least 30 days' notice before any new terms take effect, by sending a notice to the email address associated 
            with your account or by posting the changes on our website.
          </p>
          <p class="text-visir-text-muted font-light leading-relaxed">
            Your continued use of the Service after the 30-day notice period will constitute your acceptance of the modified 
            Terms of Service. If you do not agree to the new terms, you must stop using the Service before the new terms 
            become effective.
          </p>
        </div>
      </section>

      <!-- 13. Contact Information -->
      <section>
        <h2 class="text-2xl font-display font-medium text-visir-text mb-4 flex items-center gap-3">
          <span class="text-3xl text-visir-primary">13.</span>
          Contact Information
        </h2>
        <div class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-2xl p-6">
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            If you have questions regarding the Terms of Service or about Visir, please contact us:
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

      <!-- 14. Entire Agreement -->
      <section>
        <h2 class="text-2xl font-display font-medium text-visir-text mb-4 flex items-center gap-3">
          <span class="text-3xl text-visir-primary">14.</span>
          Entire Agreement
        </h2>
        <div class="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-2xl p-6">
          <p class="text-visir-text-muted font-light leading-relaxed mb-4">
            The Terms of Service represent the entire agreement between you and us with respect to the subject matter 
            addressed herein and supersedes all prior or contemporaneous agreements or understandings, written or oral.
          </p>
          <p class="text-visir-text-muted font-light leading-relaxed">
            If any provision of these Terms of Service is found to be unenforceable or invalid, that provision will be 
            limited or eliminated, to the minimum extent necessary, so that these Terms of Service shall otherwise remain 
            in full force and effect and enforceable.
          </p>
        </div>
      </section>
    </div>
  </div>
</div>
