import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/zone_model.dart';

import '../../providers/zone_provider.dart';

class ZoneFutureDropDown extends StatefulWidget {
  const ZoneFutureDropDown({
    Key? key,
    required this.selectedCityCode,
    this.dropDownKey,
    required this.required,
    required this.onChange,
    required this.selectedZone,
  }) : super(key: key);

  final String? selectedCityCode;
  final int? selectedZone;
  final bool required;

  final Function(ZoneModel?) onChange;

  final GlobalKey<DropdownSearchState<ZoneModel?>>? dropDownKey;

  @override
  State<ZoneFutureDropDown> createState() => _ZoneFutureDropDownState();
}

class _ZoneFutureDropDownState extends State<ZoneFutureDropDown> {
  final TextEditingController _subzoneController = TextEditingController();
  @override
  void dispose() {
    _subzoneController.dispose();
    super.dispose();
  }

  bool alreadyLoaded = false;

  ZoneModel? _selectedZone;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ZoneModel>?>(
      future: (widget.selectedCityCode != null)
          ? ZonesProvider.loadCityZones(widget.selectedCityCode ?? '')
          : null,
      builder: (context, AsyncSnapshot snapshot) {
        if (_selectedZone == null) {
          try {
            _selectedZone = snapshot.data
                ?.where((element) => element.id == widget.selectedZone)
                .first;
          } catch (e) {
            log(e);
          }
        }
        return DropdownSearch<ZoneModel>(
          key: widget.dropDownKey,
          searchFieldProps: TextFieldProps(
            controller: _subzoneController,
            // autofocus: true,
            decoration: InputDecoration(
              labelText: 'Zona',
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _subzoneController.clear();
                  if (_subzoneController.text.isEmpty) {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ),
          mode: Mode.BOTTOM_SHEET,
          validator: (item) {
            if (item == null && widget.required) {
              // if ((snapshot.data?.isEmpty ?? false)) {
              return 'Campo requerido';
              // }
            }
            return null;
          },
          showClearButton: true,
          showSelectedItems: true,
          clearButton: const Icon(Icons.clear_rounded),
          compareFn: (item, selectedItem) =>
              item?.zoneCode == selectedItem?.zoneCode,
          showSearchBox: true,
          selectedItem: _selectedZone,
          items: snapshot.data,
          dropdownSearchDecoration: InputDecoration(
            labelText: 'Zona :',
            labelStyle: const TextStyle(color: pColor),
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
          ),
          autoValidateMode: AutovalidateMode.onUserInteraction,
          onFind: (String? filter) async {
            try {
              final data = (snapshot.data)?.where((element) {
                final result = element.zoneName
                    .toUpperCase()
                    .contains(filter?.toUpperCase() ?? '');
                return result;
              }).toList();
              return data ?? (<ZoneModel>[]);
            } catch (e) {
              log(e);
              return [];
            }
          },
          onChanged: widget.onChange,
          popupSafeArea: const PopupSafeAreaProps(top: true, bottom: true),
          scrollbarProps: ScrollbarProps(
            isAlwaysShown: true,
            thickness: 7,
          ),
        );
      },
    );
  }
}
