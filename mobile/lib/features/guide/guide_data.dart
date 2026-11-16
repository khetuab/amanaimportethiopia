import 'package:flutter/material.dart';
import 'guide_scenes.dart';

/// One walkthrough step of the role guide.
class GuideStep {
  const GuideStep({
    required this.icon,
    required this.title,
    required this.body,
    required this.points,
    required this.scene,
  });

  final IconData icon;
  final String title;
  final String body;
  final List<String> points;
  final Widget scene;
}

/// Closing copy for the final (completion + contact) slide.
class GuideFinale {
  const GuideFinale({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
}

// ───────────────────────── Buyer walkthrough ─────────────────────────

const List<GuideStep> buyerGuideSteps = [
  GuideStep(
    icon: Icons.request_quote_rounded,
    title: 'guide.buyer.step1.title',
    body: 'guide.buyer.step1.body',
    points: [
      'guide.buyer.step1.p1',
      'guide.buyer.step1.p2',
      'guide.buyer.step1.p3',
    ],
    scene: PostRequestScene(),
  ),
  GuideStep(
    icon: Icons.inbox_rounded,
    title: 'guide.buyer.step2.title',
    body: 'guide.buyer.step2.body',
    points: [
      'guide.buyer.step2.p1',
      'guide.buyer.step2.p2',
      'guide.buyer.step2.p3',
    ],
    scene: QuotesArriveScene(),
  ),
  GuideStep(
    icon: Icons.compare_arrows_rounded,
    title: 'guide.buyer.step3.title',
    body: 'guide.buyer.step3.body',
    points: [
      'guide.buyer.step3.p1',
      'guide.buyer.step3.p2',
      'guide.buyer.step3.p3',
    ],
    scene: CompareScene(),
  ),
  GuideStep(
    icon: Icons.verified_user_rounded,
    title: 'guide.buyer.step4.title',
    body: 'guide.buyer.step4.body',
    points: [
      'guide.buyer.step4.p1',
      'guide.buyer.step4.p2',
      'guide.buyer.step4.p3',
    ],
    scene: SecurePayScene(),
  ),
  GuideStep(
    icon: Icons.local_shipping_rounded,
    title: 'guide.buyer.step5.title',
    body: 'guide.buyer.step5.body',
    points: [
      'guide.buyer.step5.p1',
      'guide.buyer.step5.p2',
      'guide.buyer.step5.p3',
    ],
    scene: TrackDeliveryScene(),
  ),
];

const GuideFinale buyerFinale = GuideFinale(
  title: 'guide.buyer.finale.title',
  subtitle: 'guide.buyer.finale.subtitle',
);

// ───────────────────────── Importer walkthrough ─────────────────────────

const List<GuideStep> importerGuideSteps = [
  GuideStep(
    icon: Icons.workspace_premium_rounded,
    title: 'guide.importer.step1.title',
    body: 'guide.importer.step1.body',
    points: [
      'guide.importer.step1.p1',
      'guide.importer.step1.p2',
      'guide.importer.step1.p3',
    ],
    scene: VerificationScene(),
  ),
  GuideStep(
    icon: Icons.storefront_rounded,
    title: 'guide.importer.step2.title',
    body: 'guide.importer.step2.body',
    points: [
      'guide.importer.step2.p1',
      'guide.importer.step2.p2',
      'guide.importer.step2.p3',
    ],
    scene: BusinessProfileScene(),
  ),
  GuideStep(
    icon: Icons.travel_explore_rounded,
    title: 'guide.importer.step3.title',
    body: 'guide.importer.step3.body',
    points: [
      'guide.importer.step3.p1',
      'guide.importer.step3.p2',
      'guide.importer.step3.p3',
    ],
    scene: BrowseRequestsScene(),
  ),
  GuideStep(
    icon: Icons.send_rounded,
    title: 'guide.importer.step4.title',
    body: 'guide.importer.step4.body',
    points: [
      'guide.importer.step4.p1',
      'guide.importer.step4.p2',
      'guide.importer.step4.p3',
    ],
    scene: SubmitQuoteScene(),
  ),
  GuideStep(
    icon: Icons.rocket_launch_rounded,
    title: 'guide.importer.step5.title',
    body: 'guide.importer.step5.body',
    points: [
      'guide.importer.step5.p1',
      'guide.importer.step5.p2',
      'guide.importer.step5.p3',
    ],
    scene: FulfilScene(),
  ),
];

const GuideFinale importerFinale = GuideFinale(
  title: 'guide.importer.finale.title',
  subtitle: 'guide.importer.finale.subtitle',
);
