import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/alerts/show_dialogs.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/haptics/app_haptics.dart';
import '../../core/locale/locale_controller.dart';
import '../../core/navigation/snappy_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../favorites/controller.dart';
import '../poetry/controller.dart';
import '../poetry/models.dart';
import 'controller.dart';
import 'rtl_editing_controller.dart';

void openReader(
  BuildContext context, {
  required List<PoetryCatalogRow> poems,
  int initialIndex = 0,
}) {
  if (poems.isEmpty) return;
  AppHaptics.heavy();
  Navigator.of(context).push(
    snappyRoute(ReaderScreen(poems: poems, initialIndex: initialIndex)),
  );
}

void openComposer(
  BuildContext context, {
  required PoetryCatalogRow draft,
  required String categoryId,
}) {
  AppHaptics.heavy();
  Navigator.of(context).push(
    snappyRoute(
      ReaderScreen(
        poems: [draft],
        composeCategoryId: categoryId,
      ),
    ),
  );
}

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({
    super.key,
    required this.poems,
    this.initialIndex = 0,
    this.composeCategoryId,
  });

  final List<PoetryCatalogRow> poems;
  final int initialIndex;
  final String? composeCategoryId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReaderController(
        poems: poems,
        initialIndex: initialIndex,
        composeCategoryId: composeCategoryId,
      ),
      child: const _ReaderBody(),
    );
  }
}

class _ReaderBody extends StatefulWidget {
  const _ReaderBody();

  @override
  State<_ReaderBody> createState() => _ReaderBodyState();
}

class _ReaderBodyState extends State<_ReaderBody> {
  final _title = RtlTextEditingController();
  final _body = RtlTextEditingController();
  final _titleFocus = FocusNode();
  final _bodyFocus = FocusNode();
  final _dirty = ValueNotifier(false);
  final _saving = ValueNotifier(false);
  final _saved = ValueNotifier(false);
  ReaderController? _reader;
  String? _boundId;

  @override
  void initState() {
    super.initState();
    _title.addListener(_onEdited);
    _body.addListener(_onEdited);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reader = context.read<ReaderController>();
    if (_reader != reader) {
      _reader?.removeListener(_onReader);
      _reader = reader;
      _reader!.addListener(_onReader);
      final poem = reader.current;
      if (poem != null) _bind(poem);
    }
  }

  @override
  void dispose() {
    _reader?.removeListener(_onReader);
    _title.removeListener(_onEdited);
    _body.removeListener(_onEdited);
    _title.dispose();
    _body.dispose();
    _titleFocus.dispose();
    _bodyFocus.dispose();
    _dirty.dispose();
    _saving.dispose();
    _saved.dispose();
    super.dispose();
  }

  void _onReader() {
    final poem = _reader?.current;
    if (poem == null || _boundId == poem.id) return;
    _bind(poem);
    if (mounted) setState(() {});
  }

  bool _canEdit(PoetryCatalogRow? poem, AuthController auth, ReaderController reader) {
    if (poem == null) return false;
    if (reader.isComposing || poem.isDraft) return auth.hasEditPermission;
    return auth.canEditPoet(poem.poetId);
  }

  void _bind(PoetryCatalogRow poem) {
    _boundId = poem.id;
    _title.removeListener(_onEdited);
    _body.removeListener(_onEdited);
    _title.value = TextEditingValue(
      text: poem.titleUrdu,
      selection: TextSelection.collapsed(
        offset: poem.titleUrdu.length,
        affinity: TextAffinity.upstream,
      ),
    );
    _body.value = TextEditingValue(
      text: poem.body,
      selection: TextSelection.collapsed(
        offset: poem.body.length,
        affinity: TextAffinity.upstream,
      ),
    );
    _title.addListener(_onEdited);
    _body.addListener(_onEdited);
    _dirty.value = false;
    _saved.value = false;
  }

  void _onEdited() {
    if (!mounted) return;
    final poem = context.read<ReaderController>().current;
    if (poem == null) return;
    final nextDirty = _title.text != poem.titleUrdu || _body.text != poem.body;
    if (_dirty.value != nextDirty) _dirty.value = nextDirty;
    if (nextDirty) _saved.value = false;
  }

  Future<void> _save() async {
    if (!mounted || _saving.value) return;
    final reader = context.read<ReaderController>();
    final catalog = context.read<CatalogController>();
    final strings = context.read<LocaleController>().strings;
    final poem = reader.current;
    if (poem == null) return;

    final title = _title.text.trim();
    final body = _body.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ShowDialogs.snackBar(context, strings.poetryPublishFailed);
      return;
    }
    if (title == poem.titleUrdu && body == poem.body && !poem.isDraft) {
      _dirty.value = false;
      return;
    }

    _saving.value = true;
    _saved.value = false;
    try {
      if (poem.isDraft || reader.isComposing) {
        final bookId = poem.bookId;
        final categoryId = reader.composeCategoryId;
        if (bookId == null || categoryId == null) {
          throw StateError(strings.poetryPublishFailed);
        }
        final id = await catalog.publishPoem(
          categoryId: categoryId,
          bookId: bookId,
          titleUrdu: title,
          body: body,
        );
        if (!mounted) return;
        final created = catalog.poemById(id) ?? poem.copyWith(id: id, titleUrdu: title, body: body);
        reader.replaceCurrent(created);
        _boundId = created.id;
      } else {
        await catalog.updatePoem(
          poetryId: poem.id,
          titleUrdu: title,
          body: body,
        );
        if (!mounted) return;
        reader.replaceCurrent(poem.copyWith(titleUrdu: title, body: body));
      }
      _dirty.value = false;
      _saved.value = true;
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${strings.poetryPublishFailed}: $error')),
      );
    } finally {
      if (mounted) _saving.value = false;
    }
  }

  Future<void> _flushAndPop() async {
    if (_saving.value) return;
    final reader = context.read<ReaderController>();
    final auth = context.read<AuthController>();
    final poem = reader.current;
    final notes = _canEdit(poem, auth, reader);
    if (!notes || !_dirty.value) {
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }
    final decision = await ShowDialogs.unsaved(context);
    if (!mounted) return;
    if (decision == UnsavedDecision.stay) return;
    if (decision == UnsavedDecision.save) {
      await _save();
      if (!mounted || _dirty.value) return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _moveToTrash() async {
    final reader = context.read<ReaderController>();
    final poem = reader.current;
    if (poem == null || poem.isDraft) return;
    final strings = context.read<LocaleController>().strings;
    final confirmed = await ShowDialogs.confirm(
      context,
      title: strings.deletePoetryTitle,
      body: strings.deletePoetryBody,
      confirmLabel: strings.deletePoetry,
      confirmColor: context.colors.error,
    );
    if (!confirmed || !mounted) return;
    try {
      await context.read<CatalogController>().moveToTrash(poem.id);
      if (!mounted) return;
      ShowDialogs.snackBar(context, strings.poetryMovedToTrash);
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ShowDialogs.snackBar(context, '$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final reader = context.watch<ReaderController>();
    final auth = context.watch<AuthController>();
    final colors = context.colors;
    final strings = locale.strings;
    final poem = reader.current;

    if (poem == null) {
      return const Scaffold(body: Center(child: Text('—')));
    }

    final notes = _canEdit(poem, auth, reader);
    final title = locale.pick(urdu: poem.titleUrdu, english: poem.titleEnglish ?? '');
    final book = locale.pick(
      urdu: poem.bookTitleUrdu ?? '',
      english: poem.bookTitleEnglish ?? '',
    );
    final poet = locale.pick(
      urdu: poem.poetNameUrdu,
      english: poem.poetNameEnglish ?? '',
    );
    final category = locale.pick(
      urdu: poem.categoryNameUrdu,
      english: poem.categoryNameEnglish,
    );
    final favorited = context.select<FavoritesController, bool>(
      (favorites) => poem.isDraft ? false : favorites.isFavorite(poem.id),
    );
    final body = reader.body;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _flushAndPop();
      },
      child: Scaffold(
        backgroundColor: colors.canvas,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    children: [
                      IconButton(
                        enableFeedback: false,
                        onPressed: _flushAndPop,
                        icon: const Icon(Icons.chevron_left, size: 28),
                      ),
                      Expanded(
                        child: notes
                            ? Directionality(
                                textDirection: TextDirection.rtl,
                                child: _UrduNoteField(
                                  key: const ValueKey('urdu-title'),
                                  controller: _title,
                                  focusNode: _titleFocus,
                                  style: AppTextStyles.urduEditor(
                                    fontSize: 18,
                                    height: 1.7,
                                    color: colors.text,
                                  ),
                                  hint: strings.poetryTitleHint,
                                  hintStyle: AppTextStyles.urduEditor(
                                    fontSize: 18,
                                    height: 1.7,
                                    color: colors.textMuted,
                                  ),
                                  maxLines: 1,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.text,
                                  onSubmitted: (_) => _bodyFocus.requestFocus(),
                                ),
                              )
                            : Text(
                                title,
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.nastaliq(
                                  fontSize: 18,
                                  height: 1.7,
                                  color: colors.text,
                                ),
                              ),
                      ),
                      if (notes && !poem.isDraft)
                        IconButton(
                          enableFeedback: false,
                          onPressed: _moveToTrash,
                          icon: Icon(Icons.delete_outline, color: colors.error),
                        ),
                      if (notes)
                        ValueListenableBuilder<bool>(
                          valueListenable: _saving,
                          builder: (context, saving, _) {
                            if (saving) {
                              return const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            }
                            return ValueListenableBuilder<bool>(
                              valueListenable: _dirty,
                              builder: (context, dirty, _) {
                                return IconButton(
                                  tooltip: strings.savePoetry,
                                  enableFeedback: false,
                                  onPressed: dirty ? _save : null,
                                  icon: Icon(
                                    Icons.upload_rounded,
                                    color: dirty ? colors.accent : colors.textMuted,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      if (!poem.isDraft)
                        IconButton(
                          enableFeedback: false,
                          onPressed: () {
                            AppHaptics.medium();
                            context.read<FavoritesController>().toggle(poem.id);
                          },
                          icon: Icon(
                            favorited ? Icons.favorite : Icons.favorite_border,
                            color: favorited ? Colors.redAccent : colors.text,
                          ),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
              if (!notes)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        '${reader.index + 1}',
                        style: AppTextStyles.ui(fontSize: 14, color: colors.textMuted),
                      ),
                      const Spacer(),
                      Text(
                        book,
                        textDirection: TextDirection.rtl,
                        style: AppTextStyles.nastaliq(
                          fontSize: 14,
                          height: 1.7,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _saving,
                    builder: (context, saving, _) {
                      return ValueListenableBuilder<bool>(
                        valueListenable: _saved,
                        builder: (context, saved, _) {
                          return Text(
                            [
                              book,
                              if (saving) strings.poetrySaving,
                              if (saved && !saving) strings.poetrySaved,
                            ].where((part) => part.isNotEmpty).join(' · '),
                            textDirection: TextDirection.rtl,
                            style: AppTextStyles.nastaliq(
                              fontSize: 13,
                              height: 1.7,
                              color: colors.textMuted,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              Expanded(
                child: notes
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(28, 20, 28, 16),
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: _UrduNoteField(
                            key: const ValueKey('urdu-body'),
                            controller: _body,
                            focusNode: _bodyFocus,
                            style: AppTextStyles.urduEditor(
                              fontSize: reader.fontSize.fontSize,
                              height: 1.85,
                              color: colors.text,
                            ),
                            hint: strings.poetryBodyHint,
                            hintStyle: AppTextStyles.urduEditor(
                              fontSize: reader.fontSize.fontSize,
                              height: 1.85,
                              color: colors.textMuted,
                            ),
                            maxLines: null,
                            expands: true,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                          ),
                        ),
                      )
                    : body.isEmpty
                        ? Center(
                            child: Text(
                              '—',
                              style: AppTextStyles.nastaliq(
                                fontSize: 22,
                                color: colors.textMuted,
                              ),
                            ),
                          )
                        : ScrollHaptics(
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
                              physics: const ClampingScrollPhysics(),
                              cacheExtent: 400,
                              addAutomaticKeepAlives: false,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    body,
                                    textAlign: reader.align.textAlign,
                                    textDirection: TextDirection.rtl,
                                    style: AppTextStyles.nastaliq(
                                      fontSize: reader.fontSize.fontSize,
                                      height: reader.fontSize.lineHeight,
                                      color: colors.text,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Text(
                                  strings.attribution(
                                    poet: poet,
                                    book: book,
                                    category: category,
                                  ),
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                  style: AppTextStyles.nastaliq(
                                    fontSize: 13,
                                    color: colors.textMuted,
                                    height: 1.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
              ),
              if (!notes) _ReaderToolbar(poet: poet, book: book),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReaderToolbar extends StatelessWidget {
  const _ReaderToolbar({required this.poet, required this.book});

  final String poet;
  final String book;

  @override
  Widget build(BuildContext context) {
    final reader = context.watch<ReaderController>();
    final strings = context.watch<LocaleController>().strings;
    final colors = context.colors;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                IconButton(
                  enableFeedback: false,
                  onPressed: reader.hasPrevious
                      ? () {
                          AppHaptics.medium();
                          reader.previous();
                        }
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final align in BodyAlign.values)
                        _AlignButton(
                          align: align,
                          selected: reader.align == align,
                          onTap: () {
                            AppHaptics.selection();
                            reader.setAlign(align);
                          },
                        ),
                    ],
                  ),
                ),
                IconButton(
                  enableFeedback: false,
                  onPressed: reader.hasNext
                      ? () {
                          AppHaptics.medium();
                          reader.next();
                        }
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                for (final size in ReaderFontSize.values)
                  _SizeButton(
                    size: size,
                    selected: reader.fontSize == size,
                    onTap: () {
                      AppHaptics.selection();
                      reader.setFontSize(size);
                    },
                  ),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    await reader.copy(poet: poet, book: book);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(strings.copied)),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_outlined),
                ),
                IconButton(
                  onPressed: () => reader.share(poet: poet, book: book),
                  icon: const Icon(Icons.ios_share),
                ),
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.text, width: 1.2),
                  ),
                  child: Text(
                    '${reader.index + 1}',
                    style: AppTextStyles.ui(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Slider(
          value: reader.progress,
          onChanged: reader.poems.length <= 1
              ? null
              : (value) {
                  final next = (value * (reader.poems.length - 1)).round();
                  if (next != reader.index) AppHaptics.selection();
                  reader.goTo(next);
                },
        ),
      ],
    );
  }
}

class _AlignButton extends StatelessWidget {
  const _AlignButton({
    required this.align,
    required this.selected,
    required this.onTap,
  });

  final BodyAlign align;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
      icon: Icon(
        align.icon,
        size: 22,
        color: selected ? colors.accent : colors.textMuted,
      ),
    );
  }
}

class _SizeButton extends StatelessWidget {
  const _SizeButton({
    required this.size,
    required this.selected,
    required this.onTap,
  });

  final ReaderFontSize size;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? colors.text : colors.canvas,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? colors.text : colors.border,
            ),
          ),
          child: Text(
            size.label,
            style: AppTextStyles.ui(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? colors.canvas : colors.text,
            ),
          ),
        ),
      ),
    );
  }
}

/// Plain RTL editor. Naskh + right align so the caret, space, and backspace
/// follow Urdu letters the way a notepad does. Nastaliq shaping skips glyphs.
class _UrduNoteField extends StatelessWidget {
  const _UrduNoteField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.style,
    required this.hint,
    required this.hintStyle,
    this.maxLines = 1,
    this.expands = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final TextStyle style;
  final String hint;
  final TextStyle hintStyle;
  final int? maxLines;
  final bool expands;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextField(
          controller: controller,
          focusNode: focusNode,
          maxLines: maxLines,
          expands: expands,
          minLines: expands ? null : (maxLines == 1 ? 1 : null),
          textAlign: TextAlign.start,
          textAlignVertical: TextAlignVertical.top,
          textDirection: TextDirection.rtl,
          hintLocales: const [Locale('ur')],
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: TextCapitalization.none,
          autocorrect: false,
          enableSuggestions: true,
          smartDashesType: SmartDashesType.disabled,
          smartQuotesType: SmartQuotesType.disabled,
          spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
          onSubmitted: onSubmitted,
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final selection = controller.selection;
              if (!selection.isValid || !selection.isCollapsed) return;
              controller.selection = TextSelection.collapsed(
                offset: selection.extentOffset,
                affinity: TextAffinity.upstream,
              );
            });
          },
          scrollPadding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom + 48,
          ),
          scrollPhysics: const ClampingScrollPhysics(),
          style: style,
          decoration: InputDecoration(
            hintText: hint,
            hintTextDirection: TextDirection.rtl,
            hintStyle: hintStyle,
            border: InputBorder.none,
            isCollapsed: false,
            contentPadding: const EdgeInsets.symmetric(vertical: 4),
          ),
        ),
      );
  }
}
