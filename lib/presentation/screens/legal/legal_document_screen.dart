import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'legal_texts.dart';

enum LegalDoc { privacy, terms }

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({super.key, required this.doc});

  final LegalDoc doc;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final title = doc == LegalDoc.privacy
        ? LegalTexts.privacyTitle
        : LegalTexts.termsTitle;
    final body = doc == LegalDoc.privacy
        ? LegalTexts.privacyBody
        : LegalTexts.termsBody;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        title: Text(title),
      ),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            Text(
              body.trim(),
              style: TextStyle(
                color: t.text,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
