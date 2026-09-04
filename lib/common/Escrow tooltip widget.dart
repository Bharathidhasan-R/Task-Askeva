import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ESCROW TOOLTIP SYSTEM
// Three tiers: tiny tooltip, expanded popover, micro-FAQ
// Drop-in replacement for the existing escrow info icon row.
// ─────────────────────────────────────────────────────────────────────────────

// ─── DATA ────────────────────────────────────────────────────────────────────

class _EscrowStep {
  final String number;
  final String title;
  final String body;
  final IconData icon;
  const _EscrowStep(this.number, this.title, this.body, this.icon);
}

const _escrowSteps = [
  _EscrowStep('1', 'You Pay',
      'Your payment is processed securely and held in escrow — never sent directly to the vendor.',
      Icons.lock_outline),
  _EscrowStep('2', 'Vendor Works',
      'Vendor completes the milestone and uploads proof (photos, videos, notes).',
      Icons.construction_outlined),
  _EscrowStep('3', 'You Review',
      'Approve or raise an issue within the approval window.',
      Icons.rate_review_outlined),
  _EscrowStep('4', 'Funds Release',
      'After your approval (or per platform rules), escrow releases money to the vendor.',
      Icons.check_circle_outline),
  _EscrowStep('5', 'Disputes',
      'If you raise an issue, funds stay on hold while the dispute process runs.',
      Icons.gavel_outlined),
];

const _faqItems = [
  (
  q: 'Can the vendor access my money immediately?',
  a: 'No — funds are only released after a milestone is approved or release conditions are met.',
  ),
  (
  q: 'What if I don\'t respond?',
  a: 'The platform may apply inactivity rules (reminders, then auto-action) as configured in the app.',
  ),
  (
  q: 'What if work is incomplete?',
  a: 'Raise an issue on the milestone and upload notes or photos. Funds remain on hold during review.',
  ),
];

// ─── TINY INLINE TOOLTIP (A) ──────────────────────────────────────────────────
// Wraps the existing info icon. Tap = show one-line tooltip balloon.

class EscrowInlineTooltip extends StatelessWidget {
  /// The tooltip key lets the parent call ensureTooltipVisible() as before.
  final GlobalKey<TooltipState> tooltipKey;

  const EscrowInlineTooltip({super.key, required this.tooltipKey});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Tapping the whole row opens the rich popover (tier B)
      onTap: () => EscrowInfoPopover.show(context),
      onLongPress: () {
        // Long-press still shows the raw balloon tooltip (tier A)
        final state = tooltipKey.currentState;
        state?.ensureTooltipVisible();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Escrow Wallet',
            style: TextStyle(
              color: Color(0xFF49545C),
              fontSize: 14,
              fontFamily: 'Lato-Regular',
              fontWeight: FontWeight.w500,
              height: 1.43,
            ),
          ),
          const SizedBox(width: 6),
          Tooltip(
            key: tooltipKey,
            // Tier A — tiny one-liner
            message:
            'Your payment is protected in escrow. Funds release to the vendor only after you approve each milestone.',
            decoration: BoxDecoration(
              color: const Color(0xFF273442),
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'Lato-Regular',
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            preferBelow: true,
            verticalOffset: 10,
            waitDuration: Duration.zero,
            showDuration: const Duration(seconds: 3),
            triggerMode: TooltipTriggerMode.manual,
            child: const Icon(
              Icons.info_outline,
              size: 16,
              color: Color(0xFF49545C),
            ),
          ),
          // // Small "How it works" label to signal the popover is available
          // const SizedBox(width: 4),
          // const Text(
          //   'How it works ›',
          //   style: TextStyle(
          //     color: Color(0xFF1D60FF),
          //     fontSize: 10,
          //     fontFamily: 'Figtree-Regular',
          //     fontWeight: FontWeight.w500,
          //     decoration: TextDecoration.underline,
          //     decorationColor: Color(0xFF1D60FF),
          //   ),
          // ),
        ],
      ),
    );
  }
}

// ─── EXPANDED POPOVER (B) — bottom sheet ──────────────────────────────────────

class EscrowInfoPopover {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _EscrowPopoverContent(),
    );
  }
}

class _EscrowPopoverContent extends StatefulWidget {
  const _EscrowPopoverContent();

  @override
  State<_EscrowPopoverContent> createState() => _EscrowPopoverContentState();
}

class _EscrowPopoverContentState extends State<_EscrowPopoverContent> {
  bool _showFaq = false;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCEDBE8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                children: [
                  // ── Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF6FB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.shield_outlined,
                              color: Color(0xFF1B517E),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'How Escrow Works',
                            style: TextStyle(
                              color: Color(0xFF183954),
                              fontSize: 20,
                              fontFamily: 'Figtree-Bold',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Color(0xFF49545C)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your money is held safely until work is complete and approved.',
                    style: TextStyle(
                      color: Color(0x99183954),
                      fontSize: 13,
                      fontFamily: 'Figtree-Regular',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Benefit banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF6FB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCEDBE8)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.verified_user_outlined,
                            color: Color(0xFF1B517E), size: 18),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Escrow protects customers from paying for unfinished work — and protects vendors by ensuring funds are reserved before work begins.',
                            style: TextStyle(
                              color: Color(0xFF183954),
                              fontSize: 12,
                              fontFamily: 'Figtree-Regular',
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Steps (tier B)
                  ..._escrowSteps.asMap().entries.map((e) {
                    final isLast = e.key == _escrowSteps.length - 1;
                    return _StepTile(
                        step: e.value, isLast: isLast);
                  }),

                  const SizedBox(height: 24),

                  // ── Micro-FAQ toggle (tier C)
                  GestureDetector(
                    onTap: () => setState(() => _showFaq = !_showFaq),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Common Questions',
                          style: TextStyle(
                            color: Color(0xFF183954),
                            fontSize: 15,
                            fontFamily: 'Figtree-Bold',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AnimatedRotation(
                          turns: _showFaq ? 0.5 : 0,
                          duration: const Duration(milliseconds: 220),
                          child: const Icon(Icons.expand_more,
                              color: Color(0xFF49545C)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),

                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Column(
                      children: _faqItems
                          .map((faq) => _FaqTile(q: faq.q, a: faq.a))
                          .toList(),
                    ),
                    crossFadeState: _showFaq
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 280),
                  ),

                  const SizedBox(height: 24),

                  // ── Close CTA
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A202C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Got it',
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Figtree-Medium',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── STEP TILE ────────────────────────────────────────────────────────────────

class _StepTile extends StatelessWidget {
  final _EscrowStep step;
  final bool isLast;

  const _StepTile({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number column with connector line
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B517E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      step.number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontFamily: 'Figtree-Bold',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCEDBE8),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                if (!isLast) const SizedBox(height: 2),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(step.icon,
                          color: const Color(0xFF1B517E), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        step.title,
                        style: const TextStyle(
                          color: Color(0xFF183954),
                          fontSize: 14,
                          fontFamily: 'Figtree-Medium',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.body,
                    style: const TextStyle(
                      color: Color(0xFF49545C),
                      fontSize: 12,
                      fontFamily: 'Figtree-Regular',
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── FAQ TILE (tier C) ────────────────────────────────────────────────────────

class _FaqTile extends StatefulWidget {
  final String q;
  final String a;
  const _FaqTile({required this.q, required this.a});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9FC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFCEDBE8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.q,
                    style: const TextStyle(
                      color: Color(0xFF183954),
                      fontSize: 13,
                      fontFamily: 'Figtree-Medium',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down,
                      color: Color(0xFF49545C), size: 20),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  widget.a,
                  style: const TextStyle(
                    color: Color(0xFF49545C),
                    fontSize: 12,
                    fontFamily: 'Figtree-Regular',
                    height: 1.5,
                  ),
                ),
              ),
              crossFadeState:
              _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 220),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOW TO PLUG THIS INTO OrderConfirmationPaymentScreen
//
// 1. Remove the old GlobalKey<TooltipState> _escrowTooltipKey declaration.
//    Add a new one:
//
//      final GlobalKey<TooltipState> _escrowTooltipKey = GlobalKey<TooltipState>();
//
//    (same name, same type — nothing else needs to change in state)
//
// 2. In the Payment Summary column, replace the existing "Escrow Wallet" Row:
//
//    OLD CODE (inside Column → Row → children):
//    ┌──────────────────────────────────────────────────────────────
//    │  GestureDetector(
//    │    onTap: () {
//    │      final dynamic tooltip = _escrowTooltipKey.currentState;
//    │      tooltip?.ensureTooltipVisible();
//    │    },
//    │    child: Row(
//    │      children: [
//    │        Text('Escrow Wallet', ...),
//    │        SizedBox(width: 6),
//    │        Tooltip(key: _escrowTooltipKey, ...),
//    │      ],
//    │    ),
//    │  ),
//    └──────────────────────────────────────────────────────────────
//
//    NEW CODE — drop-in replacement (same indent level):
//    ┌──────────────────────────────────────────────────────────────
//    │  EscrowInlineTooltip(tooltipKey: _escrowTooltipKey),
//    └──────────────────────────────────────────────────────────────
//
//    The amount column on the right stays exactly the same:
//    ┌──────────────────────────────────────────────────────────────
//    │  Row(
//    │    mainAxisAlignment: MainAxisAlignment.spaceBetween,
//    │    children: [
//    │      EscrowInlineTooltip(tooltipKey: _escrowTooltipKey),
//    │      Text('₹${getDisplayValues()['orderAmount']}', ...),
//    │    ],
//    │  ),
//    └──────────────────────────────────────────────────────────────
//
// 3. That's it. No other changes required.
// ─────────────────────────────────────────────────────────────────────────────