import 'package:flutter/material.dart';
import '../data/language_controller.dart';
import '../data/role_context.dart';
import '../services/notifications_service.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/common_widgets.dart';

class FacultyNotifyScreen extends StatefulWidget {
  const FacultyNotifyScreen({super.key});

  @override
  State<FacultyNotifyScreen> createState() => _FacultyNotifyScreenState();
}

class _FacultyNotifyScreenState extends State<FacultyNotifyScreen> {
  String _targetType = 'Group';
  late String _destination;
  List<String> _studentEmails = [];
  bool _loadingStudents = false;
  String _fetchError = '';
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _destination = _destinations.first;
    LanguageController.isArabic.addListener(_onLangChange);
  }

  void _onLangChange() {
    if (mounted) setState(() => _destination = _destinations.first);
  }

  Future<void> _fetchStudents() async {
    if (_studentEmails.isNotEmpty) return;
    setState(() { _loadingStudents = true; _fetchError = ''; });
    try {
      final profiles = await ProfileService.instance.listProfilesForAdmin();
      final emails = profiles
          .where((p) => (p['role']?.toString() ?? '').toLowerCase().contains('student'))
          .map((p) => p['email']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
      if (mounted) setState(() { _studentEmails = emails; _loadingStudents = false; });
    } catch (e) {
      if (mounted) setState(() { _loadingStudents = false; _fetchError = e.toString(); });
    }
  }

  final TextEditingController _subjectController = TextEditingController(text: 'Lecture reminder');
  final TextEditingController _messageController = TextEditingController(text: 'Please review the uploaded material before the next session.');
  bool _sending = false;

  List<_CourseSection> get _courseSections => [
    _CourseSection(
      course: LanguageController.text('Software Engineering', 'هندسة البرمجيات'),
      section: LanguageController.text('Section 201', 'الشعبة 201'),
      time: '08:00 - 09:20',
      days: LanguageController.text('Sun • Tue • Thu', 'أحد • ثلاثاء • خميس'),
      accent: const Color(0xFF0F5B57),
    ),
    _CourseSection(
      course: LanguageController.text('Human Computer Interaction', 'التفاعل بين الإنسان والحاسوب'),
      section: LanguageController.text('Section 104', 'الشعبة 104'),
      time: '11:00 - 12:20',
      days: LanguageController.text('Sun • Tue', 'أحد • ثلاثاء'),
      accent: const Color(0xFF26476D),
    ),
  ];

  List<String> get _destinations =>
      _courseSections.map((c) => '${c.course} — ${c.section}').toList();

  @override
  void dispose() {
    LanguageController.isArabic.removeListener(_onLangChange);
    _subjectController.dispose();
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = currentUserRole(context, fallback: UserRole.faculty);
    // Sync stale group destination only (Individual uses free-text email)
    if (_targetType == 'Group') {
      final dests = _destinations;
      if (!dests.contains(_destination)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _destination = dests.first);
        });
      }
    }
    return AppScaffold(
      bottomNavigationBar: const RoleBottomNav(currentIndex: 1, items: NavItems.faculty, role: UserRole.faculty),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 110),
        children: [
          BrandHeader(
            subtitle: LanguageController.text('Section and group communication', 'التواصل مع الشعب والمجموعات'),
            trailing: IconButton(onPressed: () => smartBack(context, role), icon: const Icon(Icons.arrow_back_rounded)),
          ),
          const SizedBox(height: 24),
          SurfaceCard(
            gradient: const LinearGradient(colors: [Color(0xFF152B44), Color(0xFF26476D)]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AccentPill(label: LanguageController.text('FACULTY NOTIFY', 'إشعارات عضو هيئة التدريس'), icon: Icons.send_rounded, filled: true),
              const SizedBox(height: 16),
              Text(LanguageController.text('Send a targeted notification.', 'أرسل إشعارًا موجّهًا.'), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
              const SizedBox(height: 10),
              Text(LanguageController.text('Messages are saved and shown to students in their notifications screen.', 'تُحفظ الرسائل وتظهر للطلاب في شاشة الإشعارات.'), style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withOpacity(.82))),
            ]),
          ),
          const SizedBox(height: 20),
          SurfaceCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(LanguageController.text('Message Target', 'الجهة المستهدفة'), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _targetType,
                decoration: InputDecoration(labelText: LanguageController.text('Send to', 'إرسال إلى')),
                items: const ['Group', 'Individual'].map((item) => DropdownMenuItem(value: item, child: Text(LanguageController.translateRaw(item)))).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _targetType = value;
                    _destination = value == 'Group' ? _destinations.first : '';
                    _emailController.clear();
                  });
                  if (value == 'Individual') _fetchStudents();
                },
              ),
              const SizedBox(height: 14),
              if (_targetType == 'Group')
                DropdownButtonFormField<String>(
                  value: _destinations.contains(_destination) ? _destination : _destinations.first,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: LanguageController.text('Group / Section', 'المجموعة / الشعبة')),
                  items: _destinations.map((item) => DropdownMenuItem(value: item, child: Text(LanguageController.translateRaw(item), overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (value) => setState(() => _destination = value ?? _destinations.first),
                )
              else ...[
                if (_loadingStudents)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(children: [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 10),
                      Text('جاري تحميل قائمة الطلاب...', style: TextStyle(fontSize: 13)),
                    ]),
                  ),
                Autocomplete<String>(
                  optionsBuilder: (textValue) {
                    if (_studentEmails.isEmpty) return const [];
                    if (textValue.text.isEmpty) return _studentEmails;
                    return _studentEmails.where((e) => e.toLowerCase().contains(textValue.text.toLowerCase()));
                  },
                  fieldViewBuilder: (ctx, ctrl, focusNode, onSubmitted) {
                    _emailController.value = ctrl.value;
                    return TextField(
                      controller: ctrl,
                      focusNode: focusNode,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: LanguageController.text('Student Email', 'بريد الطالب'),
                        prefixIcon: const Icon(Icons.email_outlined),
                        suffixText: _studentEmails.isNotEmpty ? '${_studentEmails.length} طالب' : null,
                        suffixStyle: const TextStyle(fontSize: 11, color: Color(0xFF7B8794)),
                        helperText: _fetchError.isNotEmpty
                            ? LanguageController.text('Could not load students — type email manually', 'تعذر تحميل الطلاب — اكتب البريد يدويًا')
                            : null,
                        helperStyle: const TextStyle(fontSize: 11),
                      ),
                      onChanged: (v) => setState(() => _destination = v.trim()),
                    );
                  },
                  onSelected: (email) => setState(() => _destination = email),
                ),
              ],
              const SizedBox(height: 14),
              TextField(controller: _subjectController, decoration: InputDecoration(labelText: LanguageController.text('Subject', 'الموضوع'), prefixIcon: const Icon(Icons.subject_rounded))),
              const SizedBox(height: 14),
              SizedBox(height: 150, child: TextField(controller: _messageController, maxLines: null, expands: true, decoration: InputDecoration(labelText: LanguageController.text('Message', 'الرسالة'), alignLabelWithHint: true))),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  label: _sending ? LanguageController.text('Sending...', 'جاري الإرسال...') : LanguageController.text('Send Notification', 'إرسال إشعار'),
                  icon: Icons.send_rounded,
                  onPressed: _sending ? null : _sendNotification,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(onPressed: _previewNotification, child: Text(LanguageController.text('Preview', 'معاينة'))),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          SurfaceCard(
            gradient: const LinearGradient(colors: [Color(0xFFF8F6F1), Colors.white]),
            child: Row(children: [
              Container(width: 54, height: 54, decoration: BoxDecoration(color: AppColors.sand, borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.groups_outlined, color: AppColors.secondary)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_targetType == 'Group' ? LanguageController.text('Group delivery', 'إرسال جماعي') : LanguageController.text('Individual delivery', 'إرسال فردي'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  _targetType == 'Group'
                    ? LanguageController.text('Will be sent to all students enrolled in: $_destination', 'سيتم الإرسال لجميع طلاب: $_destination')
                    : LanguageController.text('Target: $_destination', 'الهدف: $_destination'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.ink),
                ),
              ])),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _sendNotification() async {
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();
    if (subject.isEmpty || message.isEmpty) {
      _showMessage(LanguageController.text('Subject and message are required.', 'الموضوع والرسالة مطلوبان.'));
      return;
    }
    if (_destination.trim().isEmpty) {
      _showMessage(LanguageController.text('Please select or enter a target.', 'الرجاء تحديد الجهة المستهدفة.'));
      return;
    }
    setState(() => _sending = true);
    try {
      await NotificationsService.instance.sendNotification(
        senderRole: UserRole.faculty,
        targetType: _targetType,
        targetValue: _destination,
        title: subject,
        body: message,
        category: 'Academic',
        isAdminMessage: false,
      );
      if (!mounted) return;
      setState(() => _sending = false);
      _showMessage(LanguageController.text('Notification sent to $_destination', 'تم إرسال الإشعار إلى $_destination'));
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      _showMessage(LanguageController.text('Unable to send notification now.', 'تعذر إرسال الإشعار الآن.'));
    }
  }

  void _previewNotification() {
    final subject = _subjectController.text.trim().isEmpty ? LanguageController.text('Notification preview', 'معاينة الإشعار') : _subjectController.text.trim();
    final message = _messageController.text.trim().isEmpty ? LanguageController.text('No message body entered yet.', 'لم يتم إدخال نص الرسالة بعد.') : _messageController.text.trim();
    final facultyName = activeSessionProfile?.name ?? LanguageController.text('Faculty Member', 'عضو هيئة تدريس');
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(LanguageController.text('Notification Preview', 'معاينة الإشعار'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(subject, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 14),
          Row(children: [
            const Icon(Icons.person_outline, size: 14, color: Color(0xFF9AA6B2)),
            const SizedBox(width: 4),
            Text(facultyName, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(width: 12),
            const Icon(Icons.menu_book_outlined, size: 14, color: Color(0xFF9AA6B2)),
            const SizedBox(width: 4),
            Expanded(child: Text(_destination, style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis)),
          ]),
        ]),
      ),
    );
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class _CourseSection {
  final String course;
  final String section;
  final String time;
  final String days;
  final Color accent;
  const _CourseSection({
    required this.course,
    required this.section,
    required this.time,
    required this.days,
    required this.accent,
  });
}
