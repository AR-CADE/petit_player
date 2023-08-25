import 'package:flutter/material.dart';

class FvpTexturePlayer extends StatelessWidget {
  const FvpTexturePlayer({
    required this.textureId,
    super.key,
  });

  final ValueNotifier<int?> textureId;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: textureId,
      builder: (context, id, _) {
        if (id == null || id < 0) {
          return const SizedBox.expand();
        }
        return Texture(textureId: id);
      },
    );
  }
}
