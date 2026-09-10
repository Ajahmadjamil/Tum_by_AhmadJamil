import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/alerts/show_dialogs.dart';
import '../../core/locale/locale_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'controller.dart';

class PoetryTrashView extends StatefulWidget {
  const PoetryTrashView({super.key});

  @override
  State<PoetryTrashView> createState() => _PoetryTrashViewState();
}

class _PoetryTrashViewState extends State<PoetryTrashView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogController>().loadTrash();
    });
  }

  Future<void> _restore(String poetryId) async {
    final strings = context.read<LocaleController>().strings;
    try {
      await context.read<CatalogController>().restoreFromTrash(poetryId);
      if (!mounted) return;
      ShowDialogs.snackBar(context, strings.poetryRestored);
    } catch (error) {
      if (!mounted) return;
      ShowDialogs.snackBar(context, '$error');
    }
  }

  Future<void> _purge(String poetryId) async {
    final strings = context.read<LocaleController>().strings;
    final colors = context.colors;
    final confirmed = await ShowDialogs.confirm(
      context,
      title: strings.deleteForeverTitle,
      body: strings.deleteForeverBody,
      confirmLabel: strings.deleteForever,
      confirmColor: colors.error,
    );
    if (!confirmed || !mounted) return;
    try {
      await context.read<CatalogController>().purgeFromTrash(poetryId);
      if (!mounted) return;
      ShowDialogs.snackBar(context, strings.poetryPurged);
    } catch (error) {
      if (!mounted) return;
      ShowDialogs.snackBar(context, '$error');
    }
  }

  Future<void> _empty() async {
    final strings = context.read<LocaleController>().strings;
    final colors = context.colors;
    final confirmed = await ShowDialogs.confirm(
      context,
      title: strings.emptyTrashTitle,
      body: strings.emptyTrashBody,
      confirmLabel: strings.emptyTrash,
      confirmColor: colors.error,
    );
    if (!confirmed || !mounted) return;
    try {
      await context.read<CatalogController>().emptyTrash();
      if (!mounted) return;
      ShowDialogs.snackBar(context, strings.poetryPurged);
    } catch (error) {
      if (!mounted) return;
      ShowDialogs.snackBar(context, '$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final catalog = context.watch<CatalogController>();
    final colors = context.colors;
    final strings = locale.strings;
    final poems = catalog.trash;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: Text(
          strings.trash,
          style: locale.isUrdu
              ? AppTextStyles.nastaliq(
                  fontSize: 20,
                  height: 1.7,
                  color: colors.text,
                )
              : AppTextStyles.ui(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.text,
                ),
        ),
        actions: [
          if (poems.isNotEmpty)
            TextButton(
              onPressed: _empty,
              child: Text(
                strings.emptyTrash,
                style: AppTextStyles.ui(fontSize: 13, color: colors.error),
              ),
            ),
        ],
      ),
      body: catalog.trashLoading
          ? const Center(child: CircularProgressIndicator())
          : poems.isEmpty
              ? Center(
                  child: Text(
                    strings.emptyTrashList,
                    style: AppTextStyles.label(
                      locale.isUrdu,
                      color: colors.textMuted,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  itemCount: poems.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: colors.border, height: 1),
                  itemBuilder: (context, index) {
                    final poem = poems[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        poem.titleUrdu,
                        textDirection: TextDirection.rtl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.nastaliq(
                          fontSize: 18,
                          height: 2,
                          color: colors.text,
                        ),
                      ),
                      subtitle: poem.firstBodyLine == null
                          ? null
                          : Text(
                              poem.firstBodyLine!,
                              textDirection: TextDirection.rtl,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.nastaliq(
                                fontSize: 15,
                                height: 2,
                                color: colors.textMuted,
                              ),
                            ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: strings.restorePoetry,
                            onPressed: () => _restore(poem.id),
                            icon: Icon(Icons.restore, color: colors.primary),
                          ),
                          IconButton(
                            tooltip: strings.deleteForever,
                            onPressed: () => _purge(poem.id),
                            icon: Icon(Icons.delete_forever, color: colors.error),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
