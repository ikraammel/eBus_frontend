import 'package:flutter/material.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/models/ticket.dart';
import 'package:smart_bus/models/type_abonnement.dart';
import 'package:smart_bus/services/ticket_service.dart';

class GestionTicketsPage extends StatefulWidget {
  const GestionTicketsPage({super.key});

  @override
  State<GestionTicketsPage> createState() => _GestionTicketsPageState();
}

class _GestionTicketsPageState extends State<GestionTicketsPage> {
  final TicketService _service = TicketService();

  List<TypeAbonnement> _abonnements = [];
  List<Ticket> _tickets = [];
  bool _loading = true;

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      _abonnements = await _service.getTypeAbonnements();
      _tickets = await _service.getTickets();
    } catch (e) {
      _show("Erreur lors du chargement des données", Colors.red);
    }
    setState(() => _loading = false);
  }

  String format(String t) {
    if (t.isEmpty) return t;
    String formatted = t.replaceAll('_', ' ').toLowerCase();
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  void _show(String msg, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: c),
    );
  }

  List<dynamic> _filterItems(List<dynamic> items, bool isAbonnement) {
    if (_searchQuery.isEmpty) return items;
    final query = _searchQuery.toLowerCase();
    return items.where((item) {
      final text = isAbonnement 
          ? (item as TypeAbonnement).nom.toLowerCase() 
          : (item as Ticket).typeTicket.toLowerCase();
      return text.contains(query);
    }).toList();
  }

  // --- FORMULAIRES ---

  void _formAbonnement({TypeAbonnement? item}) {
    final isEdit = item != null;
    final nom = TextEditingController(text: item?.nom ?? "");
    final prix = TextEditingController(text: item?.prix.toString() ?? "");
    final duree = TextEditingController(text: item?.dureeMois.toString() ?? "");
    bool actif = item?.actif ?? true;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(isEdit ? "Modifier l'Abonnement" : "Nouvel Abonnement", 
              style: const TextStyle(color: AppColors.darkBlue, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField(nom, "Nom (ex: MENSUEL_SCOLAIRE)", Icons.label),
                _buildField(prix, "Prix (MAD)", Icons.money, isNumber: true),
                _buildField(duree, "Durée (Mois)", Icons.calendar_today, isNumber: true),
                const SizedBox(height: 10),
                SwitchListTile(
                  title: const Text("Actif", style: TextStyle(fontWeight: FontWeight.w500)),
                  value: actif,
                  activeColor: AppColors.green,
                  onChanged: (v) => setStateDialog(() => actif = v),
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final obj = TypeAbonnement(
                  id: item?.id,
                  nom: nom.text.toUpperCase(),
                  prix: double.tryParse(prix.text) ?? 0,
                  dureeMois: int.tryParse(duree.text) ?? 1,
                  actif: actif
                );
                try {
                  if (isEdit) await _service.updateAbonnement(obj.id!, obj);
                  else await _service.createAbonnement(obj);
                  Navigator.pop(context);
                  _loadAll();
                  _show(isEdit ? "Abonnement modifié" : "Abonnement créé", Colors.green);
                } catch (e) { _show("Erreur", Colors.red); }
              },
              child: const Text("Valider", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  void _formTicket({Ticket? item}) {
    final isEdit = item != null;
    final type = TextEditingController(text: item?.typeTicket ?? "");
    final prix = TextEditingController(text: item?.prix.toString() ?? "");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEdit ? "Modifier le Ticket" : "Nouveau Ticket", 
            style: const TextStyle(color: AppColors.darkBlue, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildField(type, "Type de Ticket", Icons.confirmation_number),
            _buildField(prix, "Prix (MAD)", Icons.money, isNumber: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final obj = Ticket(
                id: item?.id ?? 0,
                typeTicket: type.text.toUpperCase(),
                prix: double.tryParse(prix.text) ?? 0
              );
              try {
                if (isEdit) await _service.updateTicket(obj.id, obj);
                else await _service.createTicket(obj);
                Navigator.pop(context);
                _loadAll();
                _show(isEdit ? "Ticket modifié" : "Ticket créé", Colors.green);
              } catch (e) { _show("Erreur", Colors.red); }
            },
            child: const Text("Valider", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.darkBlue, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.darkBlue, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: AppBar(
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: "Rechercher une offre...",
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                )
              : const Text("Gestion des Offres", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.darkBlue,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    _isSearching = false;
                    _searchController.clear();
                    _searchQuery = "";
                  } else {
                    _isSearching = true;
                  }
                });
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            indicatorColor: AppColors.green,
            unselectedLabelColor: Colors.white70,
            indicatorWeight: 3,
            tabs: [Tab(text: "ABONNEMENTS"), Tab(text: "TICKETS")],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.darkBlue))
            : TabBarView(
                children: [
                  _buildList(_filterItems(_abonnements, true), true),
                  _buildList(_filterItems(_tickets, false), false),
                ],
              ),
        floatingActionButton: Builder(
          builder: (context) {
            final tabController = DefaultTabController.of(context);

            return AnimatedBuilder(
              animation: tabController,
              builder: (context, _) {
                final isTicketTab = tabController.index == 1;

                return FloatingActionButton(
                  backgroundColor: AppColors.darkBlue,
                  onPressed: () {
                    if (isTicketTab) {
                      _formTicket();
                    } else {
                      _formAbonnement();
                    }
                  },
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(List<dynamic> items, bool isAbonnement) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_searchQuery.isEmpty ? Icons.inventory_2_outlined : Icons.search_off, size: 60, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              _searchQuery.isEmpty 
                  ? "Aucune offre disponible" 
                  : "Aucun résultat pour \"$_searchQuery\"",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          final title = isAbonnement ? format(item.nom) : format(item.typeTicket);
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isAbonnement ? AppColors.darkBlue : AppColors.green).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAbonnement ? Icons.card_membership : Icons.confirmation_number, 
                  color: isAbonnement ? AppColors.darkBlue : AppColors.green
                ),
              ),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.darkBlue)),
              subtitle: Text(
                isAbonnement ? "${item.dureeMois} mois • ${item.actif ? 'Actif' : 'Inactif'}" : "Ticket unitaire",
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("${item.prix} DH", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBlue, fontSize: 15)),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 22), 
                    onPressed: () => isAbonnement ? _formAbonnement(item: item) : _formTicket(item: item)
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 22), 
                    onPressed: () => _confirmDelete(item, isAbonnement)
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(dynamic item, bool isAbonnement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirmation"),
        content: const Text("Voulez-vous vraiment supprimer cette offre ? Cette action est irréversible."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                if (isAbonnement) await _service.deleteAbonnement(item.id);
                else await _service.deleteTicket(item.id);
                _loadAll();
                _show("Supprimé avec succès", Colors.green);
              } catch (e) { _show("Erreur de suppression", Colors.red); }
            }, 
            child: const Text("Supprimer", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }
}
