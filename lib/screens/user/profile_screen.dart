import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/providers/document_types_provider.dart';

import '../../constant.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        dataBloc.homeKey?.currentState?.changeBottomIndex(1);
        // printConsole('here i am');
        return true;
      },
      child: Scaffold(
        // backgroundColor: Colors.white,
        appBar: appBar(
          context,
          'Perfil',
          image: 'assets/images/user.png',
          onPop: () {
            dataBloc.homeKey?.currentState?.changeBottomIndex(1);
            Navigator.pop(context);
          },
        ),
        body: _body(context).paddingOnly(bottom: 5),
      ),
    );
  }

  Widget _body(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ListView(
      children: [
        _image(size).paddingOnly(top: 15, bottom: 10),
        Text(
          (dataBloc.userData?.firstName ?? '') +
              ' ' +
              (dataBloc.userData?.lastName ?? ''),
          textAlign: TextAlign.center,
          style: buttonsSmallTextStyle(context, fontSizeFactor: 1.3),
        ).paddingSymmetric(horizontal: 10, vertical: 5),
        Text(
          dataBloc.userData!.email,
          textAlign: TextAlign.center,
          style: buttonsSmallTextStyle(context).apply(color: Colors.grey[700]),
        ).paddingSymmetric(horizontal: 10, vertical: 5).paddingBottom(15),

        DecoratedLabeledContent(
          label: 'Nombre de usuario',
          content: dataBloc.userData!.userName,
        ).paddingSymmetric(horizontal: 10, vertical: 5),
        // DecoratedLabeledContent(
        //   label: 'Email',
        //   content: dataBloc.userData!.email,
        // ).paddingSymmetric(horizontal: 10, vertical: 5),
        DecoratedLabeledContent(
          label: 'Sucursal',
          content: dataBloc.userData!.billerName,
        ).paddingSymmetric(horizontal: 10, vertical: 5),
        // DecoratedLabeledContent(
        //   label: 'Tipo de documento',
        //   content: dataBloc.userData!.documentTypeId.toString(),
        // ).paddingSymmetric(horizontal: 10, vertical: 5),
        FutureDecoratedLabeledContent(
          label: 'Tipo de documento',
          mapKey: 'nombre',
          function: DocumentsTypesProvider.findDocumentsTypesById(
            dataBloc.userData!.documentTypeId.toString(),
          ),
        ).paddingSymmetric(horizontal: 10, vertical: 5),
        DecoratedLabeledContent(
          label: 'Bodega',
          content: dataBloc.userData!.warehouseName,
        ).paddingSymmetric(horizontal: 10, vertical: 5),
        DecoratedLabeledContent(
          label: 'Vendedor',
          content: dataBloc.userData!.sellerName,
        ).paddingSymmetric(horizontal: 10, vertical: 5),
      ],
    );
  }

  Widget _image(Size size) {
    return CircleAvatar(
      child: ClipOval(child: Image.asset('assets/images/wappsi_old.png')),
      radius: size.width * 0.16 > 65 ? 65 : size.width * 0.16,
      backgroundColor: Colors.transparent,
    );
  }
}
