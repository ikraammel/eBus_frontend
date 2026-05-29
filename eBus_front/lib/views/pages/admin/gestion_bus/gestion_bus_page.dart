import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/bus/bus_bloc.dart';
import 'package:smart_bus/bloc/bus/bus_state.dart';
import 'package:smart_bus/models/bus.dart';
import 'package:smart_bus/models/ligne.dart';
import 'package:smart_bus/services/bus_service.dart';
import 'package:smart_bus/services/ligne_service.dart';
import 'package:smart_bus/views/UI/app_bar_gestion.dart';
import 'package:smart_bus/views/pages/admin/gestion_bus/bus_form_page.dart';
import 'package:smart_bus/views/pages/admin/gestion_bus/bus_list.dart';

import '../../../../bloc/bus/bus_event.dart';
import '../../../../constants/app_colors.dart';
import '../../../../utils/app_snack_bar.dart';
import '../../../UI/splash_screen.dart';

class GestionBusPage extends StatefulWidget {
  const GestionBusPage({super.key});

  @override
  State<GestionBusPage> createState() => _GestionBusPageState();
}

class _GestionBusPageState extends State<GestionBusPage> {
  final TextEditingController _searchController = TextEditingController();
  late final Future<List<Ligne>> _lignesFuture;
  Timer? _searchDebounce;
  String _searchText = '';
  int? _selectedLigneId;

  @override
  void initState() {
    super.initState();
    _lignesFuture = LigneService().getLignes();
    context.read<BusBloc>().add(LoadBuses());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _openForm([Bus? bus]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BusFormPage(bus: bus)),
    );
    if (mounted) context.read<BusBloc>().add(LoadBuses());
  }

  void _searchByImmatriculation() {
    FocusScope.of(context).unfocus();
    _selectedLigneId = null;
    context
        .read<BusBloc>()
        .add(SearchBusByImmatriculation(_searchController.text));
    setState(() {});
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() => _searchText = value.trim().toLowerCase());
    });
  }

  List<Bus> _filterBuses(List<Bus> buses) {
    if (_searchText.isEmpty) return buses;
    return buses.where((bus) {
      return bus.numero.toLowerCase().contains(_searchText) ||
          bus.immatriculation.toLowerCase().contains(_searchText) ||
          (bus.marque ?? '').toLowerCase().contains(_searchText) ||
          (bus.modele ?? '').toLowerCase().contains(_searchText);
    }).toList();
  }

  void _filterByLigne(int? ligneId) {
    setState(() => _selectedLigneId = ligneId);
    _searchController.clear();
    if (ligneId == null) {
      context.read<BusBloc>().add(LoadBuses());
    } else {
      context.read<BusBloc>().add(FilterBusByLigne(ligneId));
    }
  }

  Future<void> _showDetails(Bus bus) async {
    Bus details = bus;
    if (bus.id != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      try {
        details = await BusService().getBusById(bus.id!);
      } catch (_) {
        if (mounted) {
          AppSnackBar.showError(context, "Impossible de charger le detail du bus");
        }
      } finally {
        if (mounted) Navigator.pop(context);
      }
    }

    if (!mounted) return;
    _showDetailsDialog(details);
  }

  void _showDetailsDialog(Bus bus) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Bus ${bus.numero.isEmpty ? bus.immatriculation : bus.numero}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailLine("Immatriculation", bus.immatriculation),
            _detailLine("Etat", bus.etat.isEmpty ? "Non renseigne" : bus.etat),
            if (bus.capacite != null) _detailLine("Capacite", "${bus.capacite}"),
            if (bus.marque != null && bus.marque!.isNotEmpty)
              _detailLine("Marque", bus.marque!),
            if (bus.modele != null && bus.modele!.isNotEmpty)
              _detailLine("Modele", bus.modele!),
            _detailLine(
              "Ligne",
              bus.ligneNumero != null && bus.ligneNumero!.isNotEmpty
                  ? bus.ligneNumero!
                  : "ID ${bus.ligneId}",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  Widget _detailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text("$label : $value"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarGestion(
        title: "Gestion des bus",
        bgColor: AppColors.green,
        onPressed: () => _openForm(),
      ),
      body: BlocConsumer<BusBloc, BusState>(
        listener: (context, state) {
          if (state is BusDeleted) {
            AppSnackBar.showSuccess(context, "Bus supprime avec succes");
          } else if (state is BusCreated) {
            AppSnackBar.showSuccess(context, "Bus cree avec succes");
          } else if (state is BusUpdated) {
            AppSnackBar.showSuccess(context, "Bus modifie avec succes");
          } else if (state is BusError) {
            AppSnackBar.showError(context, state.error);
          }
        },
        builder: (context, state) {
          final buses = context.read<BusBloc>().buses;
          final displayedBuses = _filterBuses(buses);
          return Column(
            children: [
              _buildFilters(),
              Expanded(
                child: state is BusLoading
                    ? const SplashScreen()
                    : displayedBuses.isEmpty
                        ? const Center(child: Text("Aucun bus disponible"))
                        : BusList(
                            buses: displayedBuses,
                            onEdit: (bus) => _openForm(bus),
                            onDetails: (bus) {
                              _showDetails(bus);
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: const Color(0xFFF8F9FB),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Rechercher par immatriculation",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: _onSearchChanged,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _searchByImmatriculation(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.darkBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed: _searchByImmatriculation,
                  icon: const Icon(Icons.search, color: Colors.white),
                  tooltip: "Rechercher",
                ),
              ),
              IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchText = '');
                  _filterByLigne(null);
                },
                icon: const Icon(Icons.refresh),
                tooltip: "Recharger",
              ),
            ],
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<Ligne>>(
            future: _lignesFuture,
            builder: (context, snapshot) {
              final lignes = snapshot.data ?? const <Ligne>[];
              return DropdownButtonFormField<int?>(
                value: _selectedLigneId,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: "Filtrer par ligne",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text("Toutes les lignes"),
                  ),
                  ...lignes.where((ligne) => ligne.id != null).map(
                        (ligne) => DropdownMenuItem<int?>(
                          value: ligne.id,
                          child: Text("Ligne ${ligne.numero}"),
                        ),
                      ),
                ],
                onChanged: snapshot.connectionState == ConnectionState.waiting
                    ? null
                    : _filterByLigne,
              );
            },
          ),
        ],
      ),
    );
  }
}
