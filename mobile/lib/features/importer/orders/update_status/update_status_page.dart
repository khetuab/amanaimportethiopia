import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/constants/auth_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/pro/pro.dart';
import '../../../../core/widgets/pro/pro_kit.dart';
import '../../../../core/widgets/pro/pro_states.dart';
import '../../../auth/widgets/premium_button.dart';
import '../../../auth/widgets/premium_field.dart';
import 'update_status_controller.dart';

/// Maps a raw status value to its localized display label, falling back to
/// the plain humanized value when no translation exists for the status.
String _statusLabel(String s) {
  if (s.isEmpty) return '—';
  final k = 'status.${s.toLowerCase()}';
  final v = k.tr;
  return v == k ? Formatters.humanize(s) : v;
}

class _ActionInfo {
  const _ActionInfo({
    required this.title,
    required this.description,
    required this.toStatus,
    required this.icon,
    this.destructive = false,
  });
  final String title;
  final String description;
  final String toStatus;
  final IconData icon;
  final bool destructive;
}

const _stages = [
  ('payment_condition_satisfied', 'importer.order.stage.paymentCleared',
      Icons.verified_outlined),
  ('processing', 'status.processing', Icons.settings_outlined),
  ('import_shipment_in_progress', 'importer.orderUpdate.stage.shipped',
      Icons.directions_boat_outlined),
  ('customs_clearance', 'importer.orderUpdate.stage.customs',
      Icons.assignment_turned_in_outlined),
  ('in_transit', 'importer.orderUpdate.stage.onTheWay',
      Icons.local_shipping_outlined),
  ('ready_for_delivery', 'importer.orderUpdate.stage.ready',
      Icons.inventory_2_outlined),
  ('delivered', 'status.delivered', Icons.home_outlined),
];

class UpdateStatusPage extends GetView<UpdateStatusController> {
  const UpdateStatusPage({super.key});

  static const _actionInfo = <String, _ActionInfo>{
    'importer_start_processing': _ActionInfo(
      title: 'importer.orderUpdate.action.startProcessing.title',
      description:
      'importer.orderUpdate.action.startProcessing.desc',
      toStatus: 'processing',
      icon: Icons.play_circle_outline_rounded,
    ),
    'importer_mark_shipped': _ActionInfo(
      title: 'importer.orderUpdate.action.shipped.title',
      description: 'importer.orderUpdate.action.shipped.desc',
      toStatus: 'import_shipment_in_progress',
      icon: Icons.directions_boat_outlined,
    ),
    'importer_cancel': _ActionInfo(
      title: 'importer.orderUpdate.cancelOrder',
      description: 'importer.orderUpdate.action.cancel.desc',
      toStatus: 'cancelled',
      icon: Icons.cancel_outlined,
      destructive: true,
    ),
    'importer_mark_customs': _ActionInfo(
      title: 'importer.orderUpdate.action.customs.title',
      description: 'importer.orderUpdate.action.customs.desc',
      toStatus: 'customs_clearance',
      icon: Icons.assignment_turned_in_outlined,
    ),
    'importer_mark_in_transit': _ActionInfo(
      title: 'importer.orderUpdate.action.inTransit.title',
      description: 'importer.orderUpdate.action.inTransit.desc',
      toStatus: 'in_transit',
      icon: Icons.local_shipping_outlined,
    ),
    'importer_mark_ready': _ActionInfo(
      title: 'importer.order.stage.readyForDelivery',
      description: 'importer.orderUpdate.action.ready.desc',
      toStatus: 'ready_for_delivery',
      icon: Icons.inventory_2_outlined,
    ),
    'importer_mark_delivered': _ActionInfo(
      title: 'importer.orderUpdate.action.delivered.title',
      description: 'importer.orderUpdate.action.delivered.desc',
      toStatus: 'delivered',
      icon: Icons.home_outlined,
    ),
  };

  static const _meaning = <String, String>{
    'awaiting_payment_confirmation':
    'importer.orderUpdate.meaning.awaiting_payment_confirmation',
    'payment_condition_satisfied':
    'importer.orderUpdate.meaning.payment_condition_satisfied',
    'processing': 'importer.orderUpdate.meaning.processing',
    'import_shipment_in_progress':
    'importer.orderUpdate.meaning.import_shipment_in_progress',
    'customs_clearance': 'importer.orderUpdate.meaning.customs_clearance',
    'in_transit': 'importer.orderUpdate.meaning.in_transit',
    'ready_for_delivery': 'importer.orderUpdate.meaning.ready_for_delivery',
    'delivered': 'importer.orderUpdate.meaning.delivered',
    'completed': 'importer.orderUpdate.meaning.completed',
    'cancelled': 'importer.orderUpdate.meaning.cancelled',
    'disputed': 'importer.orderUpdate.meaning.disputed',
  };

  static const _events = [
    (Icons.inventory_2_outlined, 'importer.orderUpdate.event.pickedUp',
    'picked_up', 'importer.orderUpdate.eventDesc.pickedUp'),
    (Icons.flight_takeoff_outlined, 'importer.orderUpdate.event.departedOrigin',
    'departed_origin', 'importer.orderUpdate.eventDesc.departedOrigin'),
    (Icons.public_outlined, 'status.in_transit', 'in_transit',
    'importer.orderUpdate.eventDesc.inTransit'),
    (Icons.assignment_turned_in_outlined,
    'importer.orderUpdate.event.customsCleared', 'customs',
    'importer.orderUpdate.event.customsCleared'),
    (Icons.local_shipping_outlined,
    'importer.orderUpdate.event.arrivedDestination',
    'arrived_destination',
    'importer.orderUpdate.eventDesc.arrivedDestination'),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = controller.loading.value;
      final error = controller.error.value;
      final status = controller.order.value?.status ?? '';
      final ref = controller.order.value?.referenceNumber;
      final actions = controller.availableActions;
      final selected = controller.selectedAction.value;
      final submitting = controller.submitting.value;
      final change = controller.lastChange.value;
      final posting = controller.postingStage.value;
      final posted = Map<String, DateTime>.of(controller.postedStages);
      final info = _actionInfo[selected];

      return ProPage(
        showBack: true,
        eyebrow: ref ?? 'importer.order.defaultTitle'.tr,
        title: 'importer.orderUpdate.title'.tr,
        subtitle:
        'importer.orderUpdate.subtitle'.tr,
        heroExtra: status.isEmpty
            ? null
            : HeroPill(
          label: 'importer.orderUpdate.now'
              .trParams({'status': _statusLabel(status)}),
          icon: Icons.radio_button_checked_rounded,
        ),
        art: const HeroArt(
          icon: Icons.published_with_changes_rounded,
          satellites: [
            Icons.local_shipping_outlined,
            Icons.flight_takeoff_rounded,
            Icons.assignment_turned_in_outlined,
          ],
        ),
        onRefresh: controller.load,
        bottomBar: (!loading && error == null && actions.isNotEmpty && info != null)
            ? ProBottomBar(children: [
          PremiumButton(
            label: info.destructive
                ? 'importer.orderUpdate.cancelOrder'.tr
                : 'importer.orderUpdate.markAs'
                    .trParams({'status': _statusLabel(info.toStatus)}),
            icon: info.destructive
                ? Icons.cancel_outlined
                : Icons.check_rounded,
            loading: submitting,
            onPressed: () => _confirm(context, status, info),
          ),
        ])
            : null,
        body: ProStateSwitcher(
          child: loading
              ? const ProSkeletonList(
              key: ValueKey('loading'), count: 3, itemHeight: 90)
              : error != null
              ? ProErrorState(
            key: const ValueKey('error'),
            message: error,
            onRetry: controller.load,
          )
              : _content(
            context,
            status: status,
            actions: actions,
            selected: selected,
            info: info,
            change: change,
            posting: posting,
            posted: posted,
          ),
        ),
      );
    });
  }

  // ---------------------------------------------------------------- confirm

  Future<void> _confirm(
      BuildContext context,
      String fromStatus,
      _ActionInfo info,
      ) async {
    final scheme = Theme.of(context).colorScheme;
    final ok = await Get.dialog<bool>(
      AlertDialog(
        icon: Icon(
          info.destructive ? Icons.warning_amber_rounded : info.icon,
          color: info.destructive ? scheme.error : scheme.primary,
          size: 32,
        ),
        title: Text(
          info.destructive
              ? 'importer.orderUpdate.cancelConfirmTitle'.tr
              : 'importer.orderUpdate.confirmTitle'.tr,
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ChangePreview(from: fromStatus, to: info.toStatus),
            const SizedBox(height: 14),
            Text(
              info.destructive
                  ? 'importer.orderUpdate.cancelBody'.tr
                  : 'importer.orderUpdate.confirmBody'.tr,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('importer.orderUpdate.notYet'.tr),
          ),
          FilledButton(
            style: info.destructive
                ? FilledButton.styleFrom(backgroundColor: scheme.error)
                : null,
            onPressed: () => Get.back(result: true),
            child: Text(info.destructive
                ? 'importer.orderUpdate.yesCancel'.tr
                : 'importer.orderUpdate.yesUpdate'.tr),
          ),
        ],
      ),
    );
    if (ok == true) {
      HapticFeedback.mediumImpact();
      await controller.submit();
    }
  }

  // ---------------------------------------------------------------- content

  Widget _content(
      BuildContext context, {
        required String status,
        required List<String> actions,
        required String selected,
        required _ActionInfo? info,
        required StatusChange? change,
        required String? posting,
        required Map<String, DateTime> posted,
      }) {
    final theme = Theme.of(context);

    return ProStagger(
      key: const ValueKey('data'),
      gap: 22,
      children: [
        if (change != null) _SuccessBanner(change: change),

        // 1) Where is the order now?
        ProCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProSectionTitle('importer.orderUpdate.whereNow'.tr,
                  icon: Icons.my_location_rounded),
              const SizedBox(height: 14),
              Text(
                _statusLabel(status),
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                _meaning[status]?.tr ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: .7),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              _StatusTrack(status: status),
            ],
          ),
        ),

        // 2) What is the next step?
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProSectionTitle('importer.orderUpdate.whatsNext'.tr,
                icon: Icons.alt_route_rounded),
            const SizedBox(height: 4),
            Text(
              actions.length > 1
                  ? 'importer.orderUpdate.chooseAction'.tr
                  : 'importer.orderUpdate.confirmStep'.tr,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            if (actions.isEmpty)
              ProCallout(
                icon: Icons.hourglass_top_rounded,
                child: Text(
                  'importer.orderUpdate.nothingToDo'.trParams(
                      {'message': _meaning[status]?.tr ??
                          'importer.orderUpdate.noActions'.tr}),
                ),
              )
            else ...[
              for (final a in actions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ActionCard(
                    info: _actionInfo[a] ??
                        _ActionInfo(
                          title: controller.humanize(a),
                          description: '',
                          toStatus: '',
                          icon: Icons.arrow_forward_rounded,
                        ),
                    selected: selected == a,
                    onTap: () => controller.selectAction(a),
                  ),
                ),
              if (info != null && info.toStatus.isNotEmpty) ...[
                const SizedBox(height: 6),
                _PreviewStrip(from: status, to: info.toStatus),
              ],
              const SizedBox(height: 14),
              PremiumField(
                controller: controller.noteCtrl,
                label: 'importer.orderUpdate.noteLabel'.tr,
                hint: 'importer.orderUpdate.noteHint'.tr,
                icon: Icons.sticky_note_2_outlined,
                maxLines: 2,
                keyboardType: TextInputType.multiline,
              ),
            ],
          ],
        ),

        // 3) Tracking updates (separate from status)
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProSectionTitle('importer.orderUpdate.trackingUpdates'.tr,
                icon: Icons.local_shipping_outlined),
            const SizedBox(height: 10),
            ProCallout(
              icon: Icons.info_outline_rounded,
              child: Text(
                'importer.orderUpdate.trackingHint'.tr,
              ),
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < _events.length; i++)
              _ShipStep(
                icon: _events[i].$1,
                title: _events[i].$2.tr,
                hint: _events[i].$4.tr,
                last: i == _events.length - 1,
                posting: posting == _events[i].$3,
                postedAt: posted[_events[i].$3],
                onTap: () async {
                  final stage = _events[i].$3;
                  if (posted[stage] != null) {
                    final again = await Get.dialog<bool>(
                      AlertDialog(
                        title: Text('importer.orderUpdate.sendAgainTitle'.tr),
                        content: Text(
                          'importer.orderUpdate.alreadySent'.trParams(
                              {'event': _events[i].$2.tr}),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(result: false),
                            child: Text('importer.orderUpdate.no'.tr),
                          ),
                          FilledButton(
                            onPressed: () => Get.back(result: true),
                            child: Text('importer.orderUpdate.sendAgain'.tr),
                          ),
                        ],
                      ),
                    );
                    if (again != true) return;
                  }
                  await controller.postShipmentEvent(
                    stage: stage,
                    description: _events[i].$4.tr,
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}

// =========================================================== small widgets

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.change});
  final StatusChange change;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .9, end: 1),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutBack,
      builder: (_, v, child) => Transform.scale(
        scale: v,
        child: Opacity(opacity: v.clamp(0.0, 1.0).toDouble(), child: child),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AuthPalette.emeraldMid, AuthPalette.emeraldDeep],
          ),
          boxShadow: [
            BoxShadow(
              color: AuthPalette.emerald.withValues(alpha: .35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AuthPalette.mint,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: AuthPalette.emeraldDeep, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'importer.orderUpdate.statusUpdated'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${_statusLabel(change.from)}  →  ${_statusLabel(change.to)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'importer.orderUpdate.buyerCanSee'.tr,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .75),
                      fontSize: 12.5,
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

class _ChangePreview extends StatelessWidget {
  const _ChangePreview({required this.from, required this.to});
  final String from;
  final String to;

  Widget _chip(BuildContext context, String s, {bool strong = false}) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: strong
            ? scheme.primary
            : scheme.onSurface.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        _statusLabel(s),
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: strong ? scheme.onPrimary : scheme.onSurface,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _chip(context, from),
        Icon(Icons.arrow_forward_rounded,
            size: 18, color: scheme.onSurface.withValues(alpha: .5)),
        _chip(context, to, strong: true),
      ],
    );
  }
}

class _PreviewStrip extends StatelessWidget {
  const _PreviewStrip({required this.from, required this.to});
  final String from;
  final String to;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.primary.withValues(alpha: .25)),
      ),
      child: Column(
        children: [
          Text(
            'importer.orderUpdate.afterSave'.tr,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _ChangePreview(from: from, to: to),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.info,
    required this.selected,
    required this.onTap,
  });
  final _ActionInfo info;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = info.destructive ? scheme.error : scheme.primary;

    return ProCard(
      highlight: selected,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(info.icon, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                    color: info.destructive ? scheme.error : null,
                  ),
                ),
                if (info.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    info.description,
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                ],
                if (info.toStatus.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'importer.orderUpdate.orderBecomes'
                        .trParams({'status': _statusLabel(info.toStatus)}),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 10),

          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? accent
                    : scheme.onSurface.withValues(alpha: .3),
                width: 2,
              ),
            ),
            child: AnimatedScale(
              scale: selected ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal progress track; scrolls so the current step is visible.
class _StatusTrack extends StatefulWidget {
  const _StatusTrack({required this.status});
  final String status;

  @override
  State<_StatusTrack> createState() => _StatusTrackState();
}

class _StatusTrackState extends State<_StatusTrack> {
  static const _w = 84.0;
  final _sc = ScrollController();

  int get _idx {
    if (widget.status == 'completed') return _stages.length;
    return _stages.indexWhere((s) => s.$1 == widget.status);
  }

  void _focusCurrent() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_sc.hasClients) return;
      final target = (_idx * _w - _w).clamp(0.0, _sc.position.maxScrollExtent);
      _sc.animateTo(
        target.toDouble(),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _focusCurrent();
  }

  @override
  void didUpdateWidget(covariant _StatusTrack old) {
    super.didUpdateWidget(old);
    if (old.status != widget.status) _focusCurrent();
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final idx = _idx;
    final faint = scheme.onSurface.withValues(alpha: .12);

    return SizedBox(
      height: 86,
      child: ListView.builder(
        controller: _sc,
        scrollDirection: Axis.horizontal,
        itemCount: _stages.length,
        itemBuilder: (_, i) {
          final done = i < idx;
          final current = i == idx;
          final stage = _stages[i];
          return SizedBox(
            width: _w,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 3,
                        color: i == 0
                            ? Colors.transparent
                            : (i <= idx ? scheme.primary : faint),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done
                            ? scheme.primary
                            : current
                            ? scheme.surface
                            : scheme.onSurface.withValues(alpha: .06),
                        border: Border.all(
                          color: (done || current) ? scheme.primary : faint,
                          width: 2,
                        ),
                        boxShadow: [
                          if (current)
                            BoxShadow(
                              color: scheme.primary.withValues(alpha: .3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: Icon(
                        done ? Icons.check_rounded : stage.$3,
                        size: 17,
                        color: done
                            ? scheme.onPrimary
                            : current
                            ? scheme.primary
                            : scheme.onSurface.withValues(alpha: .35),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 3,
                        color: i == _stages.length - 1
                            ? Colors.transparent
                            : (i < idx ? scheme.primary : faint),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  stage.$2.tr,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.2,
                    fontWeight: current ? FontWeight.w800 : FontWeight.w500,
                    color: scheme.onSurface
                        .withValues(alpha: (done || current) ? .9 : .45),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ShipStep extends StatelessWidget {
  const _ShipStep({
    required this.icon,
    required this.title,
    required this.hint,
    required this.last,
    required this.posting,
    required this.postedAt,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String hint;
  final bool last;
  final bool posting;
  final DateTime? postedAt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sent = postedAt != null;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: sent
                        ? scheme.primary
                        : scheme.primary.withValues(alpha: .12),
                    border: Border.all(
                        color: scheme.primary.withValues(alpha: .4)),
                  ),
                  child: Icon(
                    sent ? Icons.check_rounded : icon,
                    size: 19,
                    color: sent ? scheme.onPrimary : scheme.primary,
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: scheme.primary.withValues(alpha: .2),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 12),
              child: ProCard(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                onTap: posting ? null : onTap,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(
                            sent
                                ? 'importer.orderUpdate.sent'
                                    .trParams({'time': Formatters.relative(postedAt!)})
                                : 'importer.orderUpdate.buyerSees'
                                    .trParams({'hint': hint}),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: sent ? scheme.primary : null,
                              fontWeight:
                              sent ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (posting)
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    else
                      Icon(
                        sent
                            ? Icons.check_circle_rounded
                            : Icons.add_circle_outline_rounded,
                        color: scheme.primary,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}