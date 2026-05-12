import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/models/bank_card.dart';
import 'package:smart_bus/services/bank_card_service.dart';

class MoyensPaiementPage extends StatefulWidget {
  const MoyensPaiementPage({super.key});

  @override
  State<MoyensPaiementPage> createState() => _MoyensPaiementPageState();
}

class _MoyensPaiementPageState extends State<MoyensPaiementPage>
    with TickerProviderStateMixin {
  late AnimationController _listController;
  final BankCardService _service = BankCardService();

  List<BankCard> _cards = [];
  bool _isLoading = true;
  int? _userId;

  final List<List<Color>> _cardGradients = [
    [const Color(0xFF1A367C), const Color(0xFF2A50B0)],  // bleu
    [const Color(0xFF1B8A5A), const Color(0xFF8DC63F)],  // vert
    [const Color(0xFF6A0DAD), const Color(0xFFAA60D9)],  // violet
    [const Color(0xFFB5451B), const Color(0xFFE07040)],  // orange
  ];

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCards());
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final userId = authState.user.id;
    _userId = userId;

    try {
      final cards = await _service.getCards(userId);
      if (mounted) {
        setState(() {
          _cards = cards;
          _isLoading = false;
        });
        _listController
          ..reset()
          ..forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Erreur de chargement des cartes');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red[700]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _setMain(int index) async {
    final card = _cards[index];
    if (card.id == null) return;
    try {
      await _service.setMain(card.id!);
      setState(() {
        _cards = _cards
            .map((c) => c.copyWith(isMain: c.id == card.id))
            .toList();
      });
    } catch (_) {
      _showError('Impossible de définir la carte principale');
    }
  }

  Future<void> _deleteCard(int index) async {
    final card = _cards[index];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Supprimer la carte"),
        content: Text(
            "Voulez-vous supprimer la carte se terminant par ${card.last4} ?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Supprimer",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _service.deleteCard(card.id!);
      await _loadCards(); // recharger pour récupérer la nouvelle principale
    } catch (_) {
      _showError('Impossible de supprimer la carte');
    }
  }

  void _openCardForm({BankCard? existing}) {
    if (_userId == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CardFormSheet(
        card: existing,
        gradients: _cardGradients,
        userId: _userId!,
        onSave: (card) async {
          try {
            if (existing?.id != null) {
              await _service.updateCard(existing!.id!, card);
            } else {
              await _service.addCard(card);
            }
            await _loadCards();
          } catch (e) {
            _showError(e.toString().replaceFirst('Exception: ', ''));
          }
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Mes cartes bancaires",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () => _openCardForm(),
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: Colors.white, size: 28),
            tooltip: "Ajouter une carte",
          ),
        ],
      ),
      body: Column(
        children: [
          // Bandeau header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.darkBlue,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Text(
              _isLoading
                  ? "Chargement..."
                  : "${_cards.length} carte${_cards.length > 1 ? 's' : ''} enregistrée${_cards.length > 1 ? 's' : ''}",
              style:
                  TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _cards.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        onRefresh: _loadCards,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _cards.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _cards.length) {
                              return _buildAddButton();
                            }
                            return _buildCardTile(index);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardTile(int index) {
    final card = _cards[index];
    final colors = _cardGradients[card.colorIndex % _cardGradients.length];

    return AnimatedBuilder(
      animation: _listController,
      builder: (_, child) => SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 0.2 * (index + 1)),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _listController,
          curve:
              Interval(index * 0.15, 1.0, curve: Curves.easeOut),
        )),
        child: FadeTransition(opacity: _listController, child: child),
      ),
      child: GestureDetector(
        onTap: () => _openCardForm(existing: card),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 190,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colors[0].withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Pattern décoratif
              Positioned(
                top: -30, right: -30,
                child: Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: -20, left: 30,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.04),
                  ),
                ),
              ),
              // Contenu
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildChipIcon(),
                        const Spacer(),
                        if (card.isMain)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded,
                                    color: Colors.amber, size: 14),
                                SizedBox(width: 4),
                                Text("Principale",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 11)),
                              ],
                            ),
                          ),
                        const SizedBox(width: 8),
                        _buildCardMenu(index),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      "•••• •••• •••• ${card.last4}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCardLabel("TITULAIRE", card.holder),
                        _buildCardLabel("EXPIRE", card.expiry),
                        _buildCardLabel("", "VISA", isVisa: true),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardMenu(int index) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded,
          color: Colors.white, size: 20),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'edit') _openCardForm(existing: _cards[index]);
        if (value == 'main') _setMain(index);
        if (value == 'delete') _deleteCard(index);
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
            value: 'edit',
            child: _MenuItem(
                icon: Icons.edit_outlined, label: "Modifier")),
        if (!_cards[index].isMain)
          const PopupMenuItem(
              value: 'main',
              child: _MenuItem(
                  icon: Icons.star_outline_rounded,
                  label: "Définir principale")),
        const PopupMenuItem(
            value: 'delete',
            child: _MenuItem(
                icon: Icons.delete_outline_rounded,
                label: "Supprimer",
                isRed: true)),
      ],
    );
  }

  Widget _buildChipIcon() {
    return Container(
      width: 40, height: 28,
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.8),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.credit_card, size: 18, color: Colors.white),
    );
  }

  Widget _buildCardLabel(String label, String value,
      {bool isVisa = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6), fontSize: 10)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isVisa ? 16 : 13,
            fontWeight: isVisa ? FontWeight.bold : FontWeight.w500,
            letterSpacing: isVisa ? 1.5 : 0,
            fontStyle: isVisa ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => _openCardForm(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.darkBlue.withOpacity(0.2),
              style: BorderStyle.solid),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.darkBlue.withOpacity(0.08),
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.darkBlue, size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              "Ajouter une nouvelle carte",
              style: TextStyle(
                  color: AppColors.darkBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.darkBlue.withOpacity(0.06),
            ),
            child: Icon(Icons.credit_card_off_outlined,
                size: 56, color: AppColors.darkBlue.withOpacity(0.4)),
          ),
          const SizedBox(height: 20),
          const Text("Aucune carte enregistrée",
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Ajoutez une carte pour faciliter vos paiements",
              style:
                  TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _openCardForm(),
            icon: const Icon(Icons.add_rounded),
            label: const Text("Ajouter une carte"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Formulaire (BottomSheet)
// ─────────────────────────────────────────────────────────────────────────────

class _CardFormSheet extends StatefulWidget {
  final BankCard? card;
  final List<List<Color>> gradients;
  final int userId;
  final Future<void> Function(BankCard card) onSave;

  const _CardFormSheet({
    this.card,
    required this.gradients,
    required this.userId,
    required this.onSave,
  });

  @override
  State<_CardFormSheet> createState() => _CardFormSheetState();
}

class _CardFormSheetState extends State<_CardFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _numberCtrl;
  late TextEditingController _holderCtrl;
  late TextEditingController _expiryCtrl;
  late TextEditingController _cvvCtrl;
  late int _colorIndex;
  late bool _isMain;
  bool _showCvv = false;
  bool _saving = false;

  bool get _isEditing => widget.card != null;

  @override
  void initState() {
    super.initState();
    _numberCtrl = TextEditingController();
    _holderCtrl =
        TextEditingController(text: widget.card?.holder ?? '');
    _expiryCtrl =
        TextEditingController(text: widget.card?.expiry ?? '');
    _cvvCtrl = TextEditingController();
    _colorIndex = widget.card?.colorIndex ?? 0;
    _isMain = widget.card?.isMain ?? false;
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _holderCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  String _extractLast4(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 4
        ? digits.substring(digits.length - 4)
        : digits;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final card = BankCard(
      id: widget.card?.id,
      last4: _isEditing
          ? widget.card!.last4
          : _extractLast4(_numberCtrl.text),
      holder: _holderCtrl.text.trim().toUpperCase(),
      expiry: _expiryCtrl.text.trim(),
      isMain: _isMain,
      colorIndex: _colorIndex,
      userId: widget.userId,
    );

    await widget.onSave(card);
    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradColors =
        widget.gradients[_colorIndex % widget.gradients.length];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 8,
        left: 24,
        right: 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _isEditing
                    ? "Modifier la carte"
                    : "Nouvelle carte bancaire",
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "Vos données sont protégées par chiffrement.",
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              const SizedBox(height: 24),

              // Aperçu
              _buildCardPreview(gradColors),
              const SizedBox(height: 24),

              // Couleur
              const Text("Couleur de la carte",
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 10),
              _buildColorPicker(),
              const SizedBox(height: 20),

              // Numéro (ajout uniquement)
              if (!_isEditing) ...[
                _buildLabel("Numéro de carte"),
                _buildField(
                  controller: _numberCtrl,
                  hint: "1234 5678 9012 3456",
                  icon: Icons.credit_card_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _CardNumberFormatter(),
                  ],
                  validator: (v) {
                    final digits = v?.replaceAll(' ', '') ?? '';
                    if (digits.length < 16) {
                      return "Numéro invalide (16 chiffres requis)";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Titulaire
              _buildLabel("Nom du titulaire"),
              _buildField(
                controller: _holderCtrl,
                hint: "JEAN DUPONT",
                icon: Icons.person_outline_rounded,
                textCapitalization: TextCapitalization.characters,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Champ requis" : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Date d'expiration"),
                        _buildField(
                          controller: _expiryCtrl,
                          hint: "MM/YY",
                          icon: Icons.date_range_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _ExpiryFormatter(),
                          ],
                          validator: (v) =>
                              (v == null || v.length < 5)
                                  ? "Format MM/YY"
                                  : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("CVV"),
                        _buildField(
                          controller: _cvvCtrl,
                          hint: "•••",
                          icon: Icons.lock_outline_rounded,
                          obscureText: !_showCvv,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showCvv
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                              color: Colors.grey,
                            ),
                            onPressed: () =>
                                setState(() => _showCvv = !_showCvv),
                          ),
                          validator: (v) {
                            if (!_isEditing &&
                                (v == null || v.length < 3)) {
                              return "3-4 chiffres";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Carte principale
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  value: _isMain,
                  onChanged: (v) => setState(() => _isMain = v),
                  title: const Text("Définir comme carte principale",
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  activeColor: AppColors.darkBlue,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                ),
              ),
              const SizedBox(height: 24),

              // Bouton sauvegarder
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Icon(_isEditing
                          ? Icons.save_outlined
                          : Icons.add_card_rounded),
                  label: Text(_isEditing
                      ? "Enregistrer les modifications"
                      : "Ajouter la carte"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardPreview(List<Color> colors) {
    final number = _isEditing
        ? "•••• •••• •••• ${widget.card!.last4}"
        : (_numberCtrl.text.isEmpty
            ? "•••• •••• •••• ••••"
            : _numberCtrl.text.padRight(19, '•'));
    final holder =
        _holderCtrl.text.isEmpty ? "TITULAIRE" : _holderCtrl.text.toUpperCase();
    final expiry =
        _expiryCtrl.text.isEmpty ? "MM/YY" : _expiryCtrl.text;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: colors[0].withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34, height: 24,
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              const Text("VISA",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1.5)),
            ],
          ),
          const Spacer(),
          Text(number,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("TITULAIRE",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6), fontSize: 9)),
                Text(holder,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("EXPIRE",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6), fontSize: 9)),
                Text(expiry,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    return Row(
      children: List.generate(widget.gradients.length, (i) {
        final selected = i == _colorIndex;
        return GestureDetector(
          onTap: () => setState(() => _colorIndex = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 10),
            width: selected ? 36 : 30,
            height: selected ? 36 : 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient:
                  LinearGradient(colors: widget.gradients[i]),
              border: selected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: selected
                  ? [
                      BoxShadow(
                          color: widget.gradients[i][0].withOpacity(0.5),
                          blurRadius: 8)
                    ]
                  : null,
            ),
            child: selected
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 16)
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      validator: validator,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF5F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.darkBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
            vertical: 14, horizontal: 14),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets helpers
// ─────────────────────────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isRed;
  const _MenuItem(
      {required this.icon, required this.label, this.isRed = false});

  @override
  Widget build(BuildContext context) {
    final color = isRed ? Colors.red : Colors.grey[800]!;
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Formatters
// ─────────────────────────────────────────────────────────────────────────────

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    final limited =
        digits.length > 16 ? digits.substring(0, 16) : digits;
    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(limited[i]);
    }
    final out = buffer.toString();
    return newValue.copyWith(
      text: out,
      selection: TextSelection.collapsed(offset: out.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll('/', '');
    final limited =
        digits.length > 4 ? digits.substring(0, 4) : digits;
    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(limited[i]);
    }
    final out = buffer.toString();
    return newValue.copyWith(
      text: out,
      selection: TextSelection.collapsed(offset: out.length),
    );
  }
}
