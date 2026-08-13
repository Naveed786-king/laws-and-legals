import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

/// Renderer for the block-based HTML the Admin Panel's content editor
/// produces: headings, paragraphs (with inline bold/italic/underline/link
/// formatting), lists, images, quotes, dividers, YouTube video cards, and
/// CTA buttons. Avoids pulling in a full HTML/webview engine for what is
/// still a known, controlled set of tags. Shared by Post detail and Page
/// detail screens.
class HtmlLite extends StatelessWidget {
  const HtmlLite({super.key, required this.html});
  final String html;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final blocks = <Widget>[];
    final blockPattern =
        RegExp(r'<(h2|p|ul|img|blockquote|hr)([^>]*)(?:/>|>(.*?)</\1>|\s*/?>)', dotAll: true);

    for (final match in blockPattern.allMatches(html)) {
      final tag = match.group(1);
      final attrs = match.group(2) ?? '';
      final inner = match.group(3) ?? '';
      switch (tag) {
        case 'h2':
          blocks.add(Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text.rich(TextSpan(children: _inlineSpans(inner, theme.textTheme.titleLarge))),
          ));
          break;
        case 'p':
          final ytMatch = RegExp(r'data-yt="([^"]*)"').firstMatch(attrs);
          final ctaMatch = RegExp(r'data-cta="([^"]*)"').firstMatch(attrs);
          if (ytMatch != null && ytMatch.group(1)!.isNotEmpty) {
            blocks.add(Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: YoutubeCard(videoId: ytMatch.group(1)!),
            ));
          } else if (ctaMatch != null && ctaMatch.group(1)!.isNotEmpty) {
            blocks.add(Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FilledButton(
                onPressed: () => launchUrl(Uri.parse(ctaMatch.group(1)!), mode: LaunchMode.externalApplication),
                child: Text(_stripTags(inner).trim()),
              ),
            ));
          } else {
            final text = _stripTags(inner).trim();
            if (text.isNotEmpty) {
              blocks.add(Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text.rich(TextSpan(
                  children: _inlineSpans(inner, theme.textTheme.bodyLarge?.copyWith(height: 1.6)),
                )),
              ));
            }
          }
          break;
        case 'blockquote':
          blocks.add(Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: theme.colorScheme.primary, width: 4)),
              ),
              child: Text.rich(TextSpan(
                children: _inlineSpans(
                  inner,
                  theme.textTheme.bodyLarge?.copyWith(height: 1.6, fontStyle: FontStyle.italic),
                ),
              )),
            ),
          ));
          break;
        case 'hr':
          blocks.add(const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()));
          break;
        case 'ul':
          final items = RegExp(r'<li>(.*?)</li>', dotAll: true).allMatches(inner);
          blocks.add(Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((li) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  '),
                      Expanded(
                        child: Text(_stripTags(li.group(1) ?? ''),
                            style: theme.textTheme.bodyLarge?.copyWith(height: 1.6)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ));
          break;
        case 'img':
          final srcMatch = RegExp(r'src="([^"]*)"').firstMatch(match.group(0) ?? '');
          final src = srcMatch?.group(1);
          if (src != null && src.isNotEmpty) {
            blocks.add(Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(imageUrl: src, fit: BoxFit.cover),
              ),
            ));
          }
          break;
      }
    }

    if (blocks.isEmpty) {
      // Fallback: legacy plain-text content with no block tags at all.
      final text = html.replaceAll(RegExp(r'<[^>]+>'), '').trim();
      return Text(text, style: theme.textTheme.bodyLarge?.copyWith(height: 1.6));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: blocks);
  }

  String _stripTags(String s) => s.replaceAll(RegExp(r'<[^>]+>'), '').trim();

  /// Parses a small, known set of inline tags (b/strong, i/em, u, a) into
  /// styled spans - everything else is treated as plain text.
  List<InlineSpan> _inlineSpans(String innerHtml, TextStyle? baseStyle) {
    final spans = <InlineSpan>[];
    final tagPattern = RegExp(
      r'<(b|strong)>(.*?)</\1>|<(i|em)>(.*?)</\3>|<u>(.*?)</u>|<a\s+href="([^"]*)">(.*?)</a>',
      dotAll: true,
    );
    int last = 0;
    for (final m in tagPattern.allMatches(innerHtml)) {
      if (m.start > last) {
        spans.add(TextSpan(text: _unescape(innerHtml.substring(last, m.start)), style: baseStyle));
      }
      if (m.group(1) != null) {
        spans.add(TextSpan(text: _unescape(m.group(2) ?? ''), style: baseStyle?.copyWith(fontWeight: FontWeight.bold)));
      } else if (m.group(3) != null) {
        spans.add(TextSpan(text: _unescape(m.group(4) ?? ''), style: baseStyle?.copyWith(fontStyle: FontStyle.italic)));
      } else if (m.group(5) != null) {
        spans.add(TextSpan(text: _unescape(m.group(5) ?? ''), style: baseStyle?.copyWith(decoration: TextDecoration.underline)));
      } else if (m.group(6) != null) {
        final url = m.group(6)!;
        spans.add(TextSpan(
          text: _unescape(m.group(7) ?? ''),
          style: baseStyle?.copyWith(color: Colors.blue, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()
            ..onTap = () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        ));
      }
      last = m.end;
    }
    if (last < innerHtml.length) {
      spans.add(TextSpan(text: _unescape(innerHtml.substring(last)), style: baseStyle));
    }
    if (spans.isEmpty) spans.add(TextSpan(text: _unescape(innerHtml), style: baseStyle));
    return spans;
  }

  String _unescape(String s) => s
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'");
}

class YoutubeCard extends StatelessWidget {
  const YoutubeCard({super.key, required this.videoId});
  final String videoId;

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse('https://www.youtube.com/watch?v=$videoId'), mode: LaunchMode.externalApplication),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(imageUrl: thumbnailUrl, fit: BoxFit.cover),
            ),
            Container(
              decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
              padding: const EdgeInsets.all(14),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
            ),
          ],
        ),
      ),
    );
  }
}
