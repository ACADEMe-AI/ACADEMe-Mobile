import '../../domain/models/pro.dart';

ProPlan proPlanFromJson(Map<String, Object?> json) {
  final limits = json['limits'] as Map<String, Object?>? ?? const {};
  final used = json['usedToday'] as Map<String, Object?>? ?? const {};
  return ProPlan(
    isPro: json['plan'] == 'pro',
    expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? ''),
    autoRenew: json['autoRenew'] as bool? ?? false,
    period: switch (json['basePlanId']) {
      'monthly' => ProPeriod.monthly,
      'annual' => ProPeriod.annual,
      _ => null,
    },
    state: json['state'] as String?,
    limits: {
      for (final MapEntry(:key, :value) in limits.entries)
        ?ProFeature.fromCode(key): value as int?,
    },
    usedToday: {
      for (final MapEntry(:key, :value) in used.entries)
        ?ProFeature.fromCode(key): value as int? ?? 0,
    },
    resetsAt: DateTime.tryParse(json['resetsAt'] as String? ?? ''),
  );
}
