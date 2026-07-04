import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/entities/PriceSettings.dart';
import 'package:pos_wappsi/entities/price_groups.dart';
import 'package:pos_wappsi/providers/errors_provider.dart';
import 'package:pos_wappsi/providers/local_settings_provider.dart';
import 'package:pos_wappsi/screens/components/back_app_bar.dart';
import 'package:pos_wappsi/screens/components/go_back_bottom.dart';

class PriceSettingsScreen extends StatefulWidget {
  const PriceSettingsScreen({Key? key}) : super(key: key);
  @override
  _PriceSettingsScreenState createState() => _PriceSettingsScreenState();
}

class _PriceSettingsScreenState extends State<PriceSettingsScreen> {
  String? _politicaPrecios;
  String? _tipoLista;
  int? _deafultPriceList;
  bool _loading = true;

  final List<String> _politicaPrecioOptions = [
    'Politica de precios del ERP',
    'Politica de precios de la APP',
  ];

  final List<String> _tipoListaOptions = [
    'Lista de precios por producto',
  ];

  List<PriceGroupOption> _priceGroups = [];

  @override
  void initState() {
    _loadSettings();
    super.initState();
  }

  Future<void> _loadSettings() async {
    List<String> allowedIds = [];
    if (dataBloc.userData?.priceGroups != null) {
      final String raw = dataBloc.userData!.priceGroups!;
      if (raw.isNotEmpty) {
        allowedIds = List<String>.from(json.decode(raw));
      }
    }

    final settings = await LocalSettingsProvider.getPriceSettings();
    final priceGroups =
        await LocalSettingsProvider.loadAllPriceGroupsForDropdown();
    final groups = priceGroups.map((e) => PriceGroupOption.fromMap(e)).toList();

    final savedId = settings.defaultPriceList.toInt();
    final validId = groups.any((g) => g.id == savedId) ? savedId : null;

    final Set<int> allowedIdsInt = allowedIds.map(int.parse).toSet();

    setState(() {
      _politicaPrecios = settings.politica == PoliticaPrecios.app
          ? 'Politica de precios de la APP'
          : 'Politica de precios del ERP';
      _tipoLista = settings.tipoLista == TipoLista.porProducto
          ? 'Lista de precios por producto'
          : null;
      _priceGroups =
          groups.where((group) => allowedIdsInt.contains(group.id)).toList();
      _deafultPriceList = validId;
      _loading = false;
    });
  }

  Future<void> _onPoliticaChanged(String? newValue) async {
    setState(() {
      _politicaPrecios = newValue;
      if (_politicaPrecios == 'Politica de precios del ERP') {
        _tipoLista = null;
        _deafultPriceList = null;
      }
    });

    final politica = _politicaPrecios == 'Politica de precios de la APP'
        ? PoliticaPrecios.app
        : PoliticaPrecios.erp;

    await LocalSettingsProvider.setPoliticaPrecios(politica);

    // Si volvió a ERP, limpiamos también el tipo_lista guardado
    if (politica == PoliticaPrecios.erp) {
      await LocalSettingsProvider.setTipoLista(null);
    }
  }

  Future<void> _onTipoListaChanged(String? newValue) async {
    setState(() {
      _tipoLista = newValue;
    });

    final tipo = newValue == 'Lista de precios por producto'
        ? TipoLista.porProducto
        : null;

    await LocalSettingsProvider.setTipoLista(tipo);
  }

  Future<void> _onDefaultListChanged(int? newValue) async {
    setState(() {
      _deafultPriceList = newValue;
    });
    await LocalSettingsProvider.setDefaultPriceList(newValue.toString());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        context,
        'Configuración de precios',
        image: 'assets/images/clipboard.png',
      ),
      body:
          _loading ? const Center(child: CircularProgressIndicator()) : _body(),
    );
  }

  Widget _body() {
    return Center(
      child: Column(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Política de precios',
                      border: OutlineInputBorder(),
                    ),
                    value: _politicaPrecios,
                    items: _politicaPrecioOptions.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: _onPoliticaChanged,
                  ),
                ),
                if (_politicaPrecios == 'Politica de precios de la APP')
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Tipo de lista',
                        border: OutlineInputBorder(),
                      ),
                      value: _tipoLista,
                      items: _tipoListaOptions.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: _onTipoListaChanged,
                    ),
                  ),
                if (_politicaPrecios == 'Politica de precios de la APP')
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Lista de precios por defecto',
                        border: OutlineInputBorder(),
                      ),
                      value: _deafultPriceList,
                      items: _priceGroups.map((group) {
                        return DropdownMenuItem<int>(
                          value: group.id,
                          child: Text(group.name),
                        );
                      }).toList(),
                      onChanged: _onDefaultListChanged,
                    ),
                  )
              ],
            ),
          ).expand(),
          // bottom(_buttons(), _pc, _size), // tu bottom original si aplica
        ],
      ),
    );
  }

  Widget _buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [const GoBackBottom(), _send()],
    );
  }

  AppButton _send() {
    return AppButton(
      padding: kButtonPadding,
      onTap: () async {
        final errorsP = ErrorsProvider();
        // final res = await errorsP.sendErrorLog(context, _messageText);

        // if (res) Navigator.pop(context);
      },
      child: Row(
        children: [
          const Icon(
            Icons.send,
            size: kIconSize,
            color: pColor,
          ),
          Text(
            ' Enviar',
            style: buttonsSmallTextStyle(context, color: pColor),
          ),
        ],
      ),
    );
  }
}
