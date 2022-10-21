import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/zone_model.dart';

class ZoneDropDown extends StatefulWidget {
  const ZoneDropDown({
    Key? key,
    required this.stream,
    required this.dropDownKey,
    required this.required,
    required this.onChange,
    required this.selectedZone,
  }) : super(key: key);

  final Stream<List<ZoneModel>> stream;
  final int? selectedZone;
  final bool required;

  final Function(ZoneModel?) onChange;

  final GlobalKey<DropdownSearchState<ZoneModel?>>? dropDownKey;

  @override
  State<ZoneDropDown> createState() => _ZoneDropDownState();
}

class _ZoneDropDownState extends State<ZoneDropDown> {
  final TextEditingController _subzoneController = TextEditingController();
  @override
  void dispose() {
    _subzoneController.dispose();
    super.dispose();
  }

  bool alreadyLoaded = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ZoneModel>>(
      //load city if already defined in customer data, if not load default city
      stream: widget.stream,
      initialData: const [],
      builder: (BuildContext context, AsyncSnapshot<List<ZoneModel>> snapshot) {
        ZoneModel? _selectedZone;
        try {
          _selectedZone = snapshot.data
              ?.where((element) => element.id == widget.selectedZone)
              .first;
        } catch (e) {
          log(e);
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
            if (widget.selectedZone == null && widget.required) {
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
