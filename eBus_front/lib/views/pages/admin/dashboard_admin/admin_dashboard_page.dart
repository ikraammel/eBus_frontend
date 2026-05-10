import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/admin_stats/admin_stats_bloc.dart';
import '../../../../bloc/admin_stats/admin_stats_event.dart';
import '../../../../bloc/admin_stats/admin_stats_state.dart';
import '../../../../models/admin_stats.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────────────────────────────────────
const _kBg      = Color(0xFFF0F2F5);
const _kCard    = Colors.white;
const _kDark    = Color(0xFF111827);
const _kBlue    = Color(0xFF2563EB);
const _kGreen   = Color(0xFF16A34A);
const _kAmber   = Color(0xFFD97706);
const _kRed     = Color(0xFFDC2626);
const _kPurple  = Color(0xFF7C3AED);
const _kIndigo  = Color(0xFF4F46E5);
const _kSub     = Color(0xFF6B7280);
const _kDivider = Color(0xFFE5E7EB);

// ─────────────────────────────────────────────────────────────────────────────
// Page root
// ─────────────────────────────────────────────────────────────────────────────
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminStatsBloc()..add(LoadAdminStats()),
      child: Scaffold(
        backgroundColor: _kBg,
        appBar: _DashAppBar(),
        body: BlocBuilder<AdminStatsBloc, AdminStatsState>(
          builder: (context, state) {
            if (state is AdminStatsInitial || state is AdminStatsLoading) {
              return const Center(child: CircularProgressIndicator(color: _kBlue));
            }
            if (state is AdminStatsError) {
              return _ErrorView(
                message: state.message,
                onRetry: () => context.read<AdminStatsBloc>().add(LoadAdminStats()),
              );
            }
            if (state is AdminStatsLoaded) {
              return _Body(stats: state.stats);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppBar
// ─────────────────────────────────────────────────────────────────────────────
class _DashAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final now    = DateTime.now();
    final months = ['Jan','Fév','Mar','Avr','Mai','Juin','Juil','Août','Sep','Oct','Nov','Déc'];
    final label  = '${now.day} ${months[now.month - 1]} ${now.year}';

    return AppBar(
      backgroundColor: _kDark,
      foregroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 20,
      title: const Text(
        'Tableau de Bord',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, letterSpacing: -0.3),
      ),
      actions: [
        _DateBadge(label: label),
        const SizedBox(width: 4),
        BlocBuilder<AdminStatsBloc, AdminStatsState>(
          builder: (ctx, _) => IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Actualiser',
            onPressed: () => ctx.read<AdminStatsBloc>().add(LoadAdminStats()),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

class _DateBadge extends StatelessWidget {
  final String label;
  const _DateBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 11, color: Colors.white70),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────────────────────────────────────
class _Body extends StatelessWidget {
  final AdminStatsModel stats;
  const _Body({required this.stats});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: _kBlue,
      onRefresh: () async => context.read<AdminStatsBloc>().add(LoadAdminStats()),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 36),
        children: [
          _Section('Vue générale'),
          const SizedBox(height: 10),
          _KpiGrid(stats: stats),

          const SizedBox(height: 22),
          _Section('Revenus & Paiements'),
          const SizedBox(height: 10),
          _RevenueSection(stats: stats),

          const SizedBox(height: 22),
          _Section('Abonnements'),
          const SizedBox(height: 10),
          _TwoCol(
            left: _AbonStatusCard(stats: stats),
            right: _AbonTypesCard(stats: stats),
          ),

          const SizedBox(height: 22),
          _Section("Dossiers d'inscription"),
          const SizedBox(height: 10),
          _DossiersCard(stats: stats),

          const SizedBox(height: 22),
          _Section('Réclamations'),
          const SizedBox(height: 10),
          _ReclamationsCard(stats: stats),

          const SizedBox(height: 22),
          _Section('Nouveaux inscrits — 12 derniers mois'),
          const SizedBox(height: 10),
          _InscriptionsChart(data: stats.inscriptionsParMois),

          const SizedBox(height: 22),
          _Section('Flotte & Réseau'),
          const SizedBox(height: 10),
          _TwoCol(
            left: _FlotteBusCard(stats: stats),
            right: _ReseauCard(stats: stats),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String text;
  const _Section(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: _kSub,
      letterSpacing: 0.8,
    ),
  );
}

class _KpiGrid extends StatelessWidget {
  final AdminStatsModel stats;
  const _KpiGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      _KD('Utilisateurs',       '${stats.totalUtilisateurs}', '+${stats.nouveauxCeMois} ce mois',    Icons.people_outline_rounded,    _kBlue),
      _KD('Abonnements actifs', '${stats.abonnementsActifs}', '${stats.abonnementsEnAttente} en att.', Icons.card_membership_rounded,   _kGreen),
      _KD('Tickets vendus',     '${stats.totalTickets}',      '${stats.revenuTickets.toStringAsFixed(0)} DH', Icons.confirmation_num_outlined, _kAmber),
      _KD('Objets perdus',      '${stats.objetsPerdusTotal}', 'total signalés',                       Icons.inventory_2_outlined,      _kPurple),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _KpiCard(d: items[i]),
    );
  }
}

class _KD {
  final String label, value, sub;
  final IconData icon;
  final Color color;
  const _KD(this.label, this.value, this.sub, this.icon, this.color);
}

class _KpiCard extends StatelessWidget {
  final _KD d;
  const _KpiCard({required this.d});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: d.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(d.icon, color: d.color, size: 15),
          ),
          const Spacer(),
          Text(
            d.value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: d.color, height: 1),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(d.label,  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _kDark), overflow: TextOverflow.ellipsis),
          Text(d.sub,    style: const TextStyle(fontSize: 9, color: _kSub), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _RevenueSection extends StatelessWidget {
  final AdminStatsModel stats;
  const _RevenueSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RevCard(
          label: 'Revenu total',
          amount: stats.revenuTotal,
          sub: 'Abonnements + Tickets',
          color: _kIndigo,
          icon: Icons.account_balance_wallet_outlined,
          large: true,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _RevCard(
                label: 'Abonnements',
                amount: stats.revenuTotalAbonnements,
                sub: '${stats.abonnementsActifs} actifs',
                color: _kGreen,
                icon: Icons.card_membership_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _RevCard(
                label: 'Tickets',
                amount: stats.revenuTickets,
                sub: '${stats.totalTickets} vendus',
                color: _kAmber,
                icon: Icons.confirmation_num_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RevCard extends StatelessWidget {
  final String label, sub;
  final double amount;
  final Color color;
  final IconData icon;
  final bool large;

  const _RevCard({
    required this.label,
    required this.amount,
    required this.sub,
    required this.color,
    required this.icon,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(large ? 16 : 13),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: large ? 20 : 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: large ? 12 : 11, color: _kSub, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 1),
                Text(
                  '${amount.toStringAsFixed(2)} DH',
                  style: TextStyle(fontSize: large ? 18 : 14, fontWeight: FontWeight.w800, color: color, height: 1.15),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(sub, style: const TextStyle(fontSize: 10, color: _kSub), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AbonStatusCard extends StatelessWidget {
  final AdminStatsModel stats;
  const _AbonStatusCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats.abonnementsActifs + stats.abonnementsEnAttente + stats.abonnementsExpires;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHead(title: 'Statuts', icon: Icons.subscriptions_outlined, color: _kGreen),
          const SizedBox(height: 14),
          _Bar(label: 'Actifs',      count: stats.abonnementsActifs,    total: total, color: _kGreen),
          const SizedBox(height: 8),
          _Bar(label: 'En attente',  count: stats.abonnementsEnAttente, total: total, color: _kAmber),
          const SizedBox(height: 8),
          _Bar(label: 'Expirés',     count: stats.abonnementsExpires,   total: total, color: _kRed),
          const SizedBox(height: 12),
          const Divider(color: _kDivider, height: 1),
          const SizedBox(height: 10),
          _FootRow(left: 'Total', right: '$total'),
        ],
      ),
    );
  }
}

class _AbonTypesCard extends StatelessWidget {
  final AdminStatsModel stats;
  const _AbonTypesCard({required this.stats});

  static const _palette = [_kBlue, _kGreen, _kAmber, _kPurple, _kRed, _kIndigo];

  @override
  Widget build(BuildContext context) {
    final types = stats.abonnementsParType;
    final total = types.values.fold(0, (a, b) => a + b);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHead(title: 'Par type', icon: Icons.category_outlined, color: _kBlue),
          const SizedBox(height: 14),
          if (types.isEmpty)
            const _Empty('Aucun type')
          else
            ...types.entries.toList().asMap().entries.map((e) {
              final color = _palette[e.key % _palette.length];
              final name  = e.value.key;
              final count = e.value.value;
              final pct   = total > 0 ? count / total : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _kDark), overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 6),
                        Text('$count (${(pct * 100).toStringAsFixed(0)}%)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(value: pct, backgroundColor: color.withOpacity(0.1), valueColor: AlwaysStoppedAnimation(color), minHeight: 5),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _DossiersCard extends StatelessWidget {
  final AdminStatsModel stats;
  const _DossiersCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats.dossiersEnAttente + stats.dossiersValides + stats.dossiersRejetes;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHead(
            title: "Dossiers d'inscription",
            icon: Icons.folder_outlined,
            color: _kIndigo,
            badge: _Badge('Total: $total', _kIndigo),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _StatTile('En attente', stats.dossiersEnAttente, _kAmber, Icons.hourglass_top_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _StatTile('Validés',    stats.dossiersValides,   _kGreen, Icons.check_circle_outline_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _StatTile('Rejetés',    stats.dossiersRejetes,   _kRed,   Icons.cancel_outlined)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  const _StatTile(this.label, this.count, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 6),
          Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color, height: 1)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.85)), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _ReclamationsCard extends StatelessWidget {
  final AdminStatsModel stats;
  const _ReclamationsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total    = stats.reclamationsTotal;
    final ouvertes = stats.reclamationsOuvertes;
    final resolues = stats.reclamationsResolues;
    final num autresNum = (total - ouvertes - resolues).clamp(0, total);
    final int autres = autresNum.toInt();
    final taux     = total > 0 ? (resolues / total * 100) : 0.0;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHead(
            title: 'Réclamations',
            icon: Icons.report_problem_outlined,
            color: _kRed,
            badge: _Badge('Total: $total', _kRed),
          ),
          const SizedBox(height: 14),
          Row(
              crossAxisAlignment: CrossAxisAlignment.center, // CORRECTION ICI
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Bar(label: 'En attente', count: ouvertes, total: total, color: _kAmber),
                      const SizedBox(height: 8),
                      _Bar(label: 'Traitées',   count: resolues, total: total, color: _kGreen),
                      const SizedBox(height: 8),
                      _Bar(label: 'Autres',     count: autres,   total: total, color: _kSub),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 54,
                      height: 54,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: taux / 100,
                            strokeWidth: 6,
                            backgroundColor: _kDivider,
                            valueColor: const AlwaysStoppedAnimation(_kGreen),
                          ),
                          Center(
                            child: Text(
                              '${taux.toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _kDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text('Résolution', style: TextStyle(fontSize: 9, color: _kSub)),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _InscriptionsChart extends StatelessWidget {
  final List<MonthlyCountModel> data;
  const _InscriptionsChart({required this.data});

  static const double _colW = 32;
  static const double _maxH = 80;
  static const double _labelH = 16;
  static const double _countH = 14;
  static const double _totalH = _maxH + _labelH + _countH + 8;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _Card(child: const _Empty('Aucune donnée'));
    }

    final maxVal = data.map((e) => e.count).fold(0, (a, b) => a > b ? a : b);
    final totalInscrits = data.fold(0, (s, e) => s + e.count);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHead(
            title: 'Nouveaux inscrits',
            icon: Icons.person_add_outlined,
            color: _kBlue,
            badge: _Badge('Total: $totalInscrits', _kBlue),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              height: _totalH,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.map((item) {
                  final frac   = maxVal > 0 ? item.count / maxVal : 0.0;
                  final barH   = (_maxH * frac).clamp(3.0, _maxH);
                  final isMax  = item.count == maxVal && maxVal > 0;
                  final color  = isMax ? _kBlue : _kBlue.withOpacity(0.32);

                  return SizedBox(
                    width: _colW,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: _countH,
                          child: item.count > 0
                              ? Text(
                            '${item.count}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: isMax ? _kBlue : _kSub,
                            ),
                          )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          height: barH,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ),
                        const SizedBox(height: 3),
                        SizedBox(
                          height: _labelH,
                          child: Text(
                            item.mois,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 9, color: _kSub),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlotteBusCard extends StatelessWidget {
  final AdminStatsModel stats;
  const _FlotteBusCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHead(title: 'Flotte de bus', icon: Icons.directions_bus_outlined, color: _kDark),
          const SizedBox(height: 14),
          _Bar(label: 'Actifs',      count: stats.busActifs,                    total: stats.totalBus, color: _kGreen),
          const SizedBox(height: 8),
          _Bar(label: 'Hors service', count: stats.totalBus - stats.busActifs,  total: stats.totalBus, color: _kRed),
          const SizedBox(height: 12),
          const Divider(color: _kDivider, height: 1),
          const SizedBox(height: 10),
          _FootRow(left: 'Total bus', right: '${stats.totalBus}'),
        ],
      ),
    );
  }
}

class _ReseauCard extends StatelessWidget {
  final AdminStatsModel stats;
  const _ReseauCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final dispo = stats.totalBus > 0
        ? '${(stats.busActifs / stats.totalBus * 100).toStringAsFixed(0)}%'
        : '—';

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHead(title: 'Réseau', icon: Icons.route_outlined, color: _kPurple),
          const SizedBox(height: 14),
          _InfoRow('Lignes actives',   '${stats.totalLignes}', _kPurple),
          const SizedBox(height: 10),
          _InfoRow('Bus disponibles',  '${stats.busActifs}',   _kGreen),
          const SizedBox(height: 10),
          _InfoRow('Disponibilité',    dispo,                  _kBlue),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const _InfoRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: _kSub), overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 8),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: _kCard,
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2))],
    ),
    child: child,
  );
}

class _CardHead extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget? badge;

  const _CardHead({required this.title, required this.icon, required this.color, this.badge});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kDark), overflow: TextOverflow.ellipsis),
        ),
        if (badge != null) ...[const SizedBox(width: 6), badge!],
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final int count, total;
  final Color color;
  const _Bar({required this.label, required this.count, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 11, color: _kSub), overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 6),
            Text('$count (${(pct * 100).toStringAsFixed(0)}%)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}

class _FootRow extends StatelessWidget {
  final String left, right;
  const _FootRow({required this.left, required this.right});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(left, style: const TextStyle(fontSize: 11, color: _kSub), overflow: TextOverflow.ellipsis)),
      Text(right, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _kDark)),
    ],
  );
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
    child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
  );
}

class _Empty extends StatelessWidget {
  final String msg;
  const _Empty(this.msg);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Center(child: Text(msg, style: const TextStyle(fontSize: 12, color: _kSub))),
  );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: _kSub),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: _kSub)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(backgroundColor: _kBlue, foregroundColor: Colors.white),
          ),
        ],
      ),
    ),
  );
}

class _TwoCol extends StatelessWidget {
  final Widget left, right;
  const _TwoCol({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 600) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [left, const SizedBox(height: 10), right],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 10),
        Expanded(child: right),
      ],
    );
  }
}
