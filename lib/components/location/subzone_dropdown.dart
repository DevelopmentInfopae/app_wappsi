import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/constant.dart';

import '../../models/subzone_model.dart';

class SubZoneDropDown extends StatefulWidget {
  const SubZoneDropDown(
      {Key? key,
      required this.stream,
      required this.dropDownKey,
      required this.required,
      required this.onChange,
      required this.selectedSZoneCode})
      : super(key: key);

  final Stream<List<SubzoneModel>> stream;
  final int? selectedSZoneCode;
  final bool required;

  final Function(SubzoneModel?) onChange;

  final GlobalKey<DropdownSearchState<SubzoneModel?>>? dropDownKey;

  @override
  State<SubZoneDropDown> createState() => _SubZoneDropDownState();
}

class _SubZoneDropDownState extends State<SubZoneDropDown> {
  final TextEditingController _subzoneController = TextEditingController();
  @override
  void dispose() {
    _subzoneController.dispose();
    super.dispose();
  }

  bool alreadyLoaded = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SubzoneModel>>(
      //load city if already defined in customer data, if not load default city
      stream: widget.stream,
      initialData: const [],
      builder:
          (BuildContext context, AsyncSnapshot<List<SubzoneModel>> snapshot) {
        SubzoneModel? _selectedSZone;
        try {
          _selectedSZone = snapshot.data
              ?.where((element) => element.id == widget.selectedSZoneCode)
              .first;
        } catch (e) {
          log(e);
        }

        return DropdownSearch<SubzoneModel>(
          key: widget.dropDownKey,
          searchFieldProps: TextFieldProps(
            controller: _subzoneController,
            // autofocus: true,
            decoration: InputDecoration(
              labelText: 'Barrio',
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
                return "Campo requerido";
              // }
            }
            return null;
          },
          showClearButton: true,
          showSelectedItems: true,
          clearButton: const Icon(Icons.clear_rounded),
          compareFn: (item, selectedItem) =>
              item?.subzoneCode == selectedItem?.subzoneCode,
          showSearchBox: true,
          selectedItem: _selectedSZone,
          items: snapshot.data,
          dropdownSearchDecoration: InputDecoration(
            labelText: 'Barrio :',
            labelStyle: const TextStyle(color: pColor),
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
          ),
          autoValidateMode: AutovalidateMode.onUserInteraction,
          onFind: (String? filter) async {
            try {
              final data = (snapshot.data)?.where((element) {
                final result = element.subzoneName
                    .toUpperCase()
                    .contains(filter?.toUpperCase() ?? "");
                return result;
              }).toList();
              return data ?? (<SubzoneModel>[]);
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
