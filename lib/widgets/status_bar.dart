import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/witch_colors.dart';
import '../providers/socket_provider.dart';
import '../providers/presence_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/stream_provider.dart';

class StatusBar extends ConsumerWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socketState = ref.watch(socketProvider);
    final presenceState = ref.watch(presenceProvider);
    final moodNotifier = ref.watch(moodProvider.notifier);
    final streamState = ref.watch(messageStreamProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Room selector with Circle Timer
          _CircleTimerBadge(
            roomName: socketState.currentRoom ?? 'lobby',
            isCircleFading: streamState.isCircleFading,
            hoursSinceActivity: streamState.hoursSinceActivity,
          ),
          const SizedBox(width: 8),
          // Separator
          Text(
            '·',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: WitchColors.parchmentMuted,
            ),
          ),
          const SizedBox(width: 8),
          // Connection status
          _buildConnectionStatus(socketState.connectionState),
          const SizedBox(width: 8),
          // Separator
          Text(
            '·',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: WitchColors.parchmentMuted,
            ),
          ),
          const SizedBox(width: 8),
          // Stream count
          Text(
            '${streamState.messages.length.clamp(0, 6)} in stream',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              color: WitchColors.parchmentMuted,
            ),
          ),
          const Spacer(),
          // Mood indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: WitchColors.soot800.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              moodNotifier.moodName,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                color: WitchColors.sage400,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Presence count
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: presenceState.count > 1
                      ? WitchColors.forest500
                      : WitchColors.sage500,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${presenceState.count}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: WitchColors.parchmentMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(SocketConnectionState state) {
    Color dotColor;
    String label;

    switch (state) {
      case SocketConnectionState.connected:
        dotColor = WitchColors.forest500;
        label = 'Connected';
      case SocketConnectionState.connecting:
        dotColor = WitchColors.amber500;
        label = 'Connecting';
      case SocketConnectionState.disconnected:
        dotColor = WitchColors.error;
        label = 'Disconnected';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            color: WitchColors.parchmentMuted,
          ),
        ),
      ],
    );
  }
}

/// Circle Timer Badge - flickers when circle is fading (20+ hours old)
class _CircleTimerBadge extends StatefulWidget {
  final String roomName;
  final bool isCircleFading;
  final int hoursSinceActivity;

  const _CircleTimerBadge({
    required this.roomName,
    required this.isCircleFading,
    required this.hoursSinceActivity,
  });

  @override
  State<_CircleTimerBadge> createState() => _CircleTimerBadgeState();
}

class _CircleTimerBadgeState extends State<_CircleTimerBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _flickerController;
  late Animation<double> _flickerAnimation;

  @override
  void initState() {
    super.initState();
    _flickerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _flickerAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _flickerController, curve: Curves.easeInOut),
    );

    if (widget.isCircleFading) {
      _flickerController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_CircleTimerBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCircleFading && !_flickerController.isAnimating) {
      _flickerController.repeat(reverse: true);
    } else if (!widget.isCircleFading && _flickerController.isAnimating) {
      _flickerController.stop();
      _flickerController.reset();
    }
  }

  @override
  void dispose() {
    _flickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flickerAnimation,
      builder: (context, child) {
        final Color borderColor;
        final Color? iconColor;

        if (widget.isCircleFading) {
          // Fading: amber flickering border
          borderColor = WitchColors.amber500.withValues(alpha: _flickerAnimation.value * 0.6);
          iconColor = WitchColors.amber400;
        } else {
          borderColor = WitchColors.plum900.withValues(alpha: 0.3);
          iconColor = null;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: WitchColors.soot800.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circle Timer icon (shows when fading)
              if (widget.isCircleFading) ...[
                Opacity(
                  opacity: _flickerAnimation.value,
                  child: Icon(
                    Icons.hourglass_bottom,
                    size: 12,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                widget.roomName,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: widget.isCircleFading
                      ? WitchColors.amber400
                      : WitchColors.parchment,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.expand_more,
                size: 14,
                color: WitchColors.parchmentMuted,
              ),
            ],
          ),
        );
      },
    );
  }
}
