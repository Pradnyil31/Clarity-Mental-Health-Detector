import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int _selectedCategoryIndex = 0;

  final List<HelpCategory> _categories = [
    HelpCategory(
      title: 'Getting Started',
      icon: Icons.rocket_launch_rounded,
      color: const Color(0xFF4CAF50),
      items: [
        HelpItem(
          title: 'Welcome to Clarity',
          content: '''
Welcome to Clarity, your personal mental health companion! 

Clarity is designed to help you track your mood, manage stress, and build better mental health habits through evidence-based tools and techniques.

**Key Features:**
• Mood tracking with detailed insights
• Daily journaling for reflection
• CBT (Cognitive Behavioral Therapy) exercises
• Mindfulness and meditation guidance
• Progress tracking and analytics
• Secure data storage and privacy

**Getting Started:**
1. Complete your profile setup
2. Take your first mood assessment
3. Explore the different tools available
4. Set up daily reminders (optional)
5. Start your mental wellness journey!

Remember, Clarity is a tool to support your mental health journey, but it's not a replacement for professional medical advice or treatment.
          ''',
        ),
        HelpItem(
          title: 'Setting Up Your Profile',
          content: '''
**Complete Your Profile:**

1. **Personal Information:**
   • Add your display name
   • Choose a fun avatar
   • Add a bio (optional)

2. **Preferences:**
   • Set your preferred theme (light/dark)
   • Configure notification settings
   • Choose your privacy preferences

3. **Initial Assessment:**
   • Complete the PHQ-9 (depression screening)
   • Take the GAD-7 (anxiety assessment)
   • Set your baseline mood

**Why Profile Setup Matters:**
• Personalized experience
• Better insights and recommendations
• Secure data backup
• Progress tracking over time

**Privacy Note:**
All your data is encrypted and stored securely. You have full control over your information and can export or delete it at any time.
          ''',
        ),
        HelpItem(
          title: 'Understanding Your Dashboard',
          content: '''
**Home Dashboard Overview:**

**Quick Actions:**
• Mood Check-in: Log your current mood quickly
• Journal Entry: Write about your day
• Breathing Exercise: Quick stress relief
• Assessment: Take detailed mental health assessments

**Progress Cards:**
• Current mood streak
• Weekly mood average
• Journal entries count
• Assessment scores trends

**Insights Section:**
• Mood patterns over time
• Trigger identification
• Progress celebrations
• Personalized recommendations

**Navigation:**
• Home: Dashboard and quick actions
• Insights: Detailed analytics and trends
• Chat: AI-powered mental health support
• Journal: Daily reflection and writing
• Profile: Settings and account management

**Tips for Best Results:**
• Check in daily for better insights
• Be honest in your mood tracking
• Use the journal regularly
• Review your insights weekly
          ''',
        ),
      ],
    ),
    HelpCategory(
      title: 'Features & Tools',
      icon: Icons.psychology_rounded,
      color: const Color(0xFF2196F3),
      items: [
        HelpItem(
          title: 'Mood Tracking',
          content: '''
**Understanding Mood Tracking:**

**How It Works:**
• Rate your mood on a scale of 1-10
• Add context with emotions and activities
• Include notes about what influenced your mood
• Track patterns over time

**Mood Scale Guide:**
• 1-2: Very Low (Severe distress)
• 3-4: Low (Significant challenges)
• 5-6: Neutral (Balanced state)
• 7-8: Good (Positive feelings)
• 9-10: Excellent (Very happy/energetic)

**Best Practices:**
• Track at the same time daily
• Be honest about your feelings
• Include context and triggers
• Review patterns weekly

**Understanding Your Data:**
• Trends show overall progress
• Patterns help identify triggers
• Streaks encourage consistency
• Insights provide personalized tips

**When to Seek Help:**
If you notice consistently low moods (1-3) for more than two weeks, consider speaking with a mental health professional.
          ''',
        ),
        HelpItem(
          title: 'Journal & Reflection',
          content: '''
**The Power of Journaling:**

**Benefits:**
• Process emotions and thoughts
• Identify patterns and triggers
• Track personal growth
• Reduce stress and anxiety
• Improve self-awareness

**Journal Prompts:**
• How am I feeling right now?
• What went well today?
• What challenged me?
• What am I grateful for?
• What would make tomorrow better?

**Writing Tips:**
• Write freely without judgment
• Focus on feelings, not just events
• Be specific about emotions
• Include positive moments
• Set aside 5-10 minutes daily

**Privacy & Security:**
• All entries are encrypted
• Only you can access your journal
• Export your entries anytime
• Delete entries if needed

**Advanced Features:**
• Mood tagging for entries
• Search through past entries
• Export to PDF or text
• Backup to cloud storage
          ''',
        ),
        HelpItem(
          title: 'CBT Exercises',
          content: '''
**Cognitive Behavioral Therapy (CBT) Tools:**

**What is CBT?**
CBT is an evidence-based therapy that helps identify and change negative thought patterns and behaviors.

**Available Exercises:**

**1. Thought Records:**
• Identify negative thoughts
• Examine evidence for/against
• Develop balanced perspectives
• Practice new thinking patterns

**2. Behavioral Activation:**
• Schedule pleasant activities
• Break down overwhelming tasks
• Build positive routines
• Increase engagement in life

**3. Mindfulness Exercises:**
• Present moment awareness
• Breathing techniques
• Body scan meditation
• Mindful observation

**4. Problem-Solving:**
• Define problems clearly
• Brainstorm solutions
• Evaluate options
• Create action plans

**How to Use CBT Tools:**
• Start with one exercise
• Practice regularly (daily if possible)
• Be patient with progress
• Apply techniques to real situations

**Professional Support:**
CBT exercises in Clarity are educational tools. For comprehensive CBT therapy, consider working with a licensed therapist.
          ''',
        ),
        HelpItem(
          title: 'Assessments & Screening',
          content: '''
**Mental Health Assessments:**

**PHQ-9 (Depression Screening):**
• 9-question assessment
• Measures depression symptoms
• Scores: 0-4 (minimal), 5-9 (mild), 10-14 (moderate), 15-19 (moderately severe), 20-27 (severe)
• Recommended frequency: Monthly or when concerned

**GAD-7 (Anxiety Screening):**
• 7-question assessment
• Measures anxiety symptoms
• Scores: 0-4 (minimal), 5-9 (mild), 10-14 (moderate), 15-21 (severe)
• Recommended frequency: Monthly or when concerned

**Happiness Scale:**
• Measures life satisfaction
• Tracks positive emotions
• Identifies areas for improvement
• Complements mood tracking

**Self-Esteem Assessment:**
• Evaluates self-worth
• Identifies confidence patterns
• Tracks personal growth
• Guides self-improvement

**Important Notes:**
• Assessments are screening tools, not diagnoses
• High scores indicate need for professional help
• Use results to track progress over time
• Share results with healthcare providers if needed

**When to Seek Professional Help:**
• Consistently high depression/anxiety scores
• Thoughts of self-harm
• Significant life impairment
• Substance use concerns
          ''',
        ),
      ],
    ),
    HelpCategory(
      title: 'Privacy & Security',
      icon: Icons.security_rounded,
      color: const Color(0xFF9C27B0),
      items: [
        HelpItem(
          title: 'Data Privacy',
          content: '''
**Your Privacy Matters:**

**Data Collection:**
• Only essential information is collected
• No personal data sold to third parties
• Anonymous usage analytics (optional)
• Location data not collected

**Data Storage:**
• All data encrypted at rest and in transit
• Secure cloud storage with industry standards
• Regular security audits and updates
• Compliance with privacy regulations

**Data Control:**
• View all your data anytime
• Export your complete data
• Delete specific entries or all data
• Account deletion removes all data

**Sharing & Access:**
• You control who sees your data
• No automatic sharing with anyone
• Optional sharing with healthcare providers
• Emergency contacts (if configured)

**Third-Party Services:**
• Minimal third-party integrations
• All partners vetted for privacy compliance
• No data sharing without explicit consent
• Opt-out options available

**Your Rights:**
• Right to access your data
• Right to correct inaccurate data
• Right to delete your data
• Right to data portability
• Right to withdraw consent

**Questions?**
Contact our privacy team at privacy@clarityapp.com for any privacy-related questions or concerns.
          ''',
        ),
        HelpItem(
          title: 'Account Security',
          content: '''
**Keeping Your Account Safe:**

**Strong Authentication:**
• Use a strong, unique password
• Enable two-factor authentication (2FA)
• Regular password updates recommended
• Secure password manager integration

**Account Protection:**
• Automatic logout after inactivity
• Device-specific security tokens
• Suspicious activity monitoring
• Login attempt notifications

**Data Backup:**
• Automatic cloud backup (encrypted)
• Manual export options
• Multiple backup locations
• Recovery options available

**Device Security:**
• App lock with PIN/biometric
• Secure local storage
• Remote wipe capability
• Device registration tracking

**Best Practices:**
• Don't share login credentials
• Log out on shared devices
• Keep app updated
• Report suspicious activity immediately

**Security Incidents:**
• Immediate notification system
• Transparent incident reporting
• Rapid response and resolution
• User guidance and support

**Recovery Options:**
• Password reset via email
• Account recovery questions
• Support team assistance
• Identity verification process

**Contact Security Team:**
Report security concerns to security@clarityapp.com
          ''',
        ),
      ],
    ),
    HelpCategory(
      title: 'Troubleshooting',
      icon: Icons.build_rounded,
      color: const Color(0xFFFF5722),
      items: [
        HelpItem(
          title: 'Common Issues',
          content: '''
**Frequently Encountered Problems:**

**App Performance Issues:**

**Problem:** App is slow or freezing
**Solutions:**
• Close and restart the app
• Restart your device
• Clear app cache (Android)
• Update to latest version
• Free up device storage space

**Problem:** App crashes frequently
**Solutions:**
• Update the app
• Restart your device
• Check available storage
• Report crash logs to support

**Data Sync Issues:**

**Problem:** Data not syncing across devices
**Solutions:**
• Check internet connection
• Sign out and sign back in
• Force sync in settings
• Contact support if persistent

**Problem:** Missing entries or data
**Solutions:**
• Check sync status
• Look in archived/deleted items
• Restore from backup
• Contact support for recovery

**Login & Account Issues:**

**Problem:** Can't log in
**Solutions:**
• Check email and password
• Reset password if needed
• Clear app cache
• Check internet connection

**Problem:** Forgot password
**Solutions:**
• Use "Forgot Password" link
• Check spam folder for reset email
• Contact support if no email received

**Notification Issues:**

**Problem:** Not receiving reminders
**Solutions:**
• Check notification permissions
• Verify notification settings in app
• Check device notification settings
• Restart the app

**Still Having Issues?**
Contact our support team with specific details about your problem.
          ''',
        ),
        HelpItem(
          title: 'Technical Support',
          content: '''
**Getting Technical Help:**

**Before Contacting Support:**
• Try basic troubleshooting steps
• Check if issue persists after app restart
• Note specific error messages
• Check your internet connection

**Information to Include:**
• Device type and operating system
• App version number
• Specific steps that led to the issue
• Screenshots or screen recordings (if helpful)
• Error messages (exact text)

**Support Channels:**

**Email Support:**
• support@clarityapp.com
• Response within 24 hours
• Include detailed problem description
• Attach screenshots if relevant

**In-App Support:**
• Use "Contact Support" in settings
• Automatic device info inclusion
• Direct message to support team
• Faster response for urgent issues

**Community Forum:**
• community.clarityapp.com
• User-to-user help
• Feature discussions
• Tips and tricks sharing

**Live Chat:**
• Available during business hours
• Immediate assistance
• Screen sharing for complex issues
• Escalation to specialists

**Emergency Support:**
• For urgent technical issues
• 24/7 availability for critical problems
• Priority response guarantee

**Response Times:**
• General inquiries: 24-48 hours
• Technical issues: 12-24 hours
• Account problems: 6-12 hours
• Emergency issues: 1-4 hours

**Follow-Up:**
We'll follow up to ensure your issue is fully resolved and you're satisfied with the solution.
          ''',
        ),
      ],
    ),
    HelpCategory(
      title: 'Contact & Resources',
      icon: Icons.support_agent_rounded,
      color: const Color(0xFFFF9800),
      items: [
        HelpItem(
          title: 'Contact Information',
          content: '''
**Get in Touch:**

**General Support:**
📧 Email: support@clarityapp.com
📞 Phone: +1 (555) 123-HELP
🕒 Hours: Monday-Friday, 9 AM - 6 PM EST

**Specialized Support:**

**Technical Issues:**
📧 tech@clarityapp.com
🔧 For app bugs, performance issues, and technical problems

**Privacy & Security:**
📧 privacy@clarityapp.com
🔒 For data privacy questions and security concerns

**Billing & Subscriptions:**
📧 billing@clarityapp.com
💳 For payment issues and subscription management

**Partnerships & Business:**
📧 partnerships@clarityapp.com
🤝 For healthcare providers and business inquiries

**Media & Press:**
📧 press@clarityapp.com
📰 For media inquiries and press releases

**Social Media:**
🐦 Twitter: @ClarityMentalHealth
📘 Facebook: /ClarityMentalHealthApp
📸 Instagram: @clarity_mental_health
💼 LinkedIn: /company/clarity-mental-health

**Mailing Address:**
Clarity Mental Health
123 Wellness Street
Suite 456
Mental Health City, MH 12345
United States

**Response Expectations:**
• Email: 24-48 hours
• Phone: Immediate during business hours
• Social media: 4-8 hours
• Emergency issues: 1-4 hours

**Languages Supported:**
• English (primary)
• Spanish
• French
• German
• Portuguese

**Accessibility:**
We're committed to making our support accessible to everyone. Contact us for assistance with accessibility needs.
          ''',
        ),
        HelpItem(
          title: 'Mental Health Resources',
          content: '''
**Crisis & Emergency Resources:**

**Immediate Help:**
🚨 **If you're in immediate danger, call 911**

**Crisis Hotlines:**
• National Suicide Prevention Lifeline: 988
• Crisis Text Line: Text HOME to 741741
• SAMHSA National Helpline: 1-800-662-4357
• National Domestic Violence Hotline: 1-800-799-7233

**International Crisis Support:**
• International Association for Suicide Prevention: iasp.info
• Befrienders Worldwide: befrienders.org
• Crisis Text Line (UK): Text SHOUT to 85258

**Mental Health Organizations:**

**National Alliance on Mental Illness (NAMI):**
• Website: nami.org
• Helpline: 1-800-950-6264
• Local support groups and resources

**Mental Health America:**
• Website: mhanational.org
• Screening tools and resources
• Advocacy and education

**Anxiety and Depression Association of America:**
• Website: adaa.org
• Treatment finder
• Support groups

**Professional Help:**

**Finding a Therapist:**
• Psychology Today: psychologytoday.com
• BetterHelp: betterhelp.com
• Talkspace: talkspace.com
• Your insurance provider's directory

**Types of Mental Health Professionals:**
• Psychiatrists: Medical doctors who can prescribe medication
• Psychologists: Doctoral-level therapists
• Licensed Clinical Social Workers (LCSW)
• Licensed Professional Counselors (LPC)
• Marriage and Family Therapists (MFT)

**Educational Resources:**

**Websites:**
• National Institute of Mental Health: nimh.nih.gov
• Mayo Clinic Mental Health: mayoclinic.org
• WebMD Mental Health: webmd.com
• Headspace: headspace.com

**Books:**
• "Feeling Good" by David D. Burns
• "The Anxiety and Worry Workbook" by David A. Clark
• "Mindfulness for Beginners" by Jon Kabat-Zinn
• "The Depression Cure" by Stephen Ilardi

**Apps & Tools:**
• Headspace (meditation)
• Calm (sleep and relaxation)
• Insight Timer (meditation)
• Sanvello (mood tracking)

**Remember:**
Clarity is a supportive tool, but professional help is important for serious mental health concerns. Don't hesitate to reach out for help when you need it.
          ''',
        ),
        HelpItem(
          title: 'Community & Feedback',
          content: '''
**Join Our Community:**

**User Community:**
🌐 **Community Forum:** community.clarityapp.com
• Share experiences and tips
• Connect with other users
• Get peer support
• Participate in challenges

**Community Guidelines:**
• Be respectful and supportive
• Protect privacy (yours and others')
• No medical advice (share experiences only)
• Report inappropriate content
• Follow platform rules

**Ways to Contribute:**

**Beta Testing:**
• Test new features early
• Provide feedback on improvements
• Help shape the app's future
• Join our beta community

**Feature Requests:**
• Suggest new features
• Vote on community requests
• Participate in feature discussions
• Help prioritize development

**Content Creation:**
• Share your mental health journey
• Write guest blog posts
• Create educational content
• Participate in awareness campaigns

**Feedback Channels:**

**In-App Feedback:**
• Rate features after use
• Quick feedback surveys
• Bug reporting tool
• Feature request form

**User Research:**
• Participate in interviews
• Join focus groups
• Complete research surveys
• Help improve user experience

**Social Media Engagement:**
• Share your progress (if comfortable)
• Use #ClarityJourney hashtag
• Engage with our content
• Spread mental health awareness

**Recognition Programs:**

**Community Champions:**
• Recognize helpful community members
• Special badges and recognition
• Early access to new features
• Exclusive community events

**Feedback Rewards:**
• Points for providing feedback
• Unlock premium features
• Special recognition
• Thank you gifts

**Annual User Conference:**
• Virtual and in-person options
• Meet the team and other users
• Learn about new features
• Participate in workshops

**Making a Difference:**
Your feedback and participation help us create a better mental health tool for everyone. Every suggestion, bug report, and community interaction makes Clarity better.

**Stay Connected:**
• Newsletter: Subscribe for updates
• Blog: Read mental health tips and stories
• Podcast: Listen to expert interviews
• YouTube: Watch tutorials and testimonials
          ''',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0F0F)
          : const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with gradient
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.only(left: 16, top: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF1A1A2E),
                            const Color(0xFF16213E),
                            const Color(0xFF0F3460),
                          ]
                        : [
                            const Color(0xFFFF9800),
                            const Color(0xFFFF5722),
                            const Color(0xFFE91E63),
                          ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Help Icon with glow effect
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            child: const Icon(
                              Icons.help_rounded,
                              size: 45,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Title
                        const Text(
                          'Help & Support',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'We\'re here to help you succeed',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          scheme.primaryContainer.withValues(alpha: 0.3),
                          scheme.secondaryContainer.withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: scheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: scheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.flash_on_rounded,
                                color: scheme.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Quick Actions',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? scheme.onSurface.withValues(
                                            alpha: 0.95,
                                          )
                                        : null,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _QuickActionButton(
                                icon: Icons.email_rounded,
                                label: 'Email Support',
                                color: Colors.blue,
                                onTap: () => _launchEmail(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _QuickActionButton(
                                icon: Icons.chat_rounded,
                                label: 'Live Chat',
                                color: Colors.green,
                                onTap: () => _showLiveChatDialog(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _QuickActionButton(
                                icon: Icons.phone_rounded,
                                label: 'Call Support',
                                color: Colors.orange,
                                onTap: () => _launchPhone(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _QuickActionButton(
                                icon: Icons.crisis_alert_rounded,
                                label: 'Crisis Help',
                                color: Colors.red,
                                onTap: () => _showCrisisDialog(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Categories Section
                  Row(
                    children: [
                      Icon(
                        Icons.category_rounded,
                        color: scheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Help Categories',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? scheme.onSurface.withValues(alpha: 0.95)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Category Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final category = entry.value;
                        final isSelected = _selectedCategoryIndex == index;

                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategoryIndex = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? category.color.withValues(alpha: 0.15)
                                    : scheme.surfaceContainerHighest.withValues(
                                        alpha: 0.5,
                                      ),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: isSelected
                                      ? category.color
                                      : scheme.outline.withValues(alpha: 0.3),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: category.color.withValues(
                                            alpha: 0.2,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    category.icon,
                                    color: isSelected
                                        ? category.color
                                        : scheme.onSurfaceVariant,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    category.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? category.color
                                              : (isDark
                                                    ? scheme.onSurface
                                                          .withValues(
                                                            alpha: 0.9,
                                                          )
                                                    : scheme.onSurface),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Help Items
                  for (final item in _categories[_selectedCategoryIndex].items)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: scheme.outline.withValues(alpha: 0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.shadow.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.all(20),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            20,
                            0,
                            20,
                            20,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _categories[_selectedCategoryIndex].color
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.help_outline_rounded,
                              color: _categories[_selectedCategoryIndex].color,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? scheme.onSurface.withValues(alpha: 0.95)
                                      : null,
                                ),
                          ),
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHighest
                                    .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _FormattedHelpText(content: item.content),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Contact Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _categories[_selectedCategoryIndex].color.withValues(
                            alpha: 0.1,
                          ),
                          _categories[_selectedCategoryIndex].color.withValues(
                            alpha: 0.05,
                          ),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _categories[_selectedCategoryIndex].color
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _categories[_selectedCategoryIndex].color
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.support_agent_rounded,
                                color:
                                    _categories[_selectedCategoryIndex].color,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Still Need Help?',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? scheme.onSurface.withValues(
                                            alpha: 0.95,
                                          )
                                        : null,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Our support team is here to help you 24/7. Don\'t hesitate to reach out if you need assistance or have questions.',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: isDark
                                    ? scheme.onSurface.withValues(alpha: 0.9)
                                    : scheme.onSurface,
                                height: 1.5,
                              ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _launchEmail(),
                                icon: const Icon(Icons.email_rounded, size: 18),
                                label: const Text('Email Support'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showLiveChatDialog(context),
                                icon: const Icon(Icons.chat_rounded, size: 18),
                                label: const Text('Live Chat'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@clarityapp.com',
      query: 'subject=Help Request - Clarity App',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (mounted) {
          // Copy email to clipboard as fallback
          await Clipboard.setData(
            const ClipboardData(text: 'support@clarityapp.com'),
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email address copied to clipboard'),
                backgroundColor: Colors.blue,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open email app'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+15551234357');

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          // Copy phone number to clipboard as fallback
          await Clipboard.setData(
            const ClipboardData(text: '+1 (555) 123-HELP'),
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Phone number copied to clipboard'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open phone app'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLiveChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.chat_rounded, color: Colors.green),
            SizedBox(width: 8),
            Text('Live Chat Support'),
          ],
        ),
        content: const Text(
          'Live chat is available Monday-Friday, 9 AM - 6 PM EST.\n\n'
          'For immediate assistance outside these hours, please use email support or call our emergency line for urgent matters.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // In a real app, this would open the live chat widget
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Live chat feature coming soon!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }

  void _showCrisisDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.crisis_alert_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Crisis Resources'),
          ],
        ),
        content: const Text(
          'If you\'re in immediate danger, please call 911.\n\n'
          'For mental health crisis support:\n'
          '• National Suicide Prevention Lifeline: 988\n'
          '• Crisis Text Line: Text HOME to 741741\n'
          '• SAMHSA Helpline: 1-800-662-4357\n\n'
          'You are not alone. Help is available 24/7.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final Uri phoneUri = Uri(scheme: 'tel', path: '988');
              if (await canLaunchUrl(phoneUri)) {
                await launchUrl(phoneUri);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Call 988'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? scheme.onSurface.withValues(alpha: 0.9)
                      : scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HelpCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<HelpItem> items;

  HelpCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });
}

class HelpItem {
  final String title;
  final String content;

  HelpItem({required this.title, required this.content});
}

class _FormattedHelpText extends StatelessWidget {
  final String content;

  const _FormattedHelpText({required this.content});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lines = content.split('\n');
    final List<Widget> children = [];

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) {
        children.add(const SizedBox(height: 12));
        continue;
      }

      // Headers (bold text wrapping)
      if (line.startsWith('**') && line.endsWith('**')) {
        final text = line.substring(2, line.length - 2);
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? scheme.primary : scheme.primary,
                    height: 1.4,
                  ),
            ),
          ),
        );
      }
      // Headers (bold text with colon)
      else if (line.startsWith('**') && line.contains('**')) {
        // Handle cases like "**Title:** content" or just "**Title:**"
        final parts = line.split('**');
        if (parts.length >= 3) {
          final boldPart = parts[1];
          final rest = parts.sublist(2).join('**');
          children.add(
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        color: isDark
                            ? scheme.onSurface.withValues(alpha: 0.9)
                            : scheme.onSurface,
                      ),
                  children: [
                    TextSpan(
                      text: boldPart,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: rest),
                  ],
                ),
              ),
            ),
          );
        } else {
            // Fallback for simple text
             children.add(
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    line,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: isDark
                              ? scheme.onSurface.withValues(alpha: 0.9)
                              : scheme.onSurface,
                        ),
                  ),
                ),
              );
        }
      }
      // Bullet points
      else if (line.startsWith('•') || line.startsWith('- ')) {
        final text = line.startsWith('•') ? line.substring(1) : line.substring(2);
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '•',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text.trim(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          color: isDark
                              ? scheme.onSurface.withValues(alpha: 0.9)
                              : scheme.onSurface,
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // Numbered lists (simple detection 1. 2. etc)
      else if (RegExp(r'^\d+\.').hasMatch(line)) {
        final match = RegExp(r'^(\d+\.)\s*(.*)').firstMatch(line);
        if (match != null) {
            final number = match.group(1) ?? '';
            final text = match.group(2) ?? '';
             children.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      number,
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        text.trim(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                              color: isDark
                                  ? scheme.onSurface.withValues(alpha: 0.9)
                                  : scheme.onSurface,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            );
        } else {
             children.add(Text(line)); // Should not happen if regex matched
        }
      }
      // Regular text
      else {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              line,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    color: isDark
                        ? scheme.onSurface.withValues(alpha: 0.9)
                        : scheme.onSurface,
                  ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

