import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
// ignore: implementation_imports
import 'package:pos_wappsi/bloc/data_bloc.dart';
// import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/config/bd_sync.dart';
import 'package:pos_wappsi/config/theme/colors.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/providers/sync_db_provider.dart';
// import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/screens/components/back_app_bar.dart';
import 'package:pos_wappsi/screens/components/column_with_padding.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';
import 'package:pos_wappsi/screens/db_sync/components/sync_element.dart';
import 'package:pos_wappsi/screens/db_sync/components/widgets.dart';
import 'package:pos_wappsi/screens/db_sync/state/syn_state.dart';
import 'package:pos_wappsi/screens/home/home.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/dialogs.dart';
import 'package:pos_wappsi/utils/global_locator.dart';
// import 'package:google_fonts/google_fonts.dart';

class DBSync extends ConsumerStatefulWidget {
  const DBSync({Key? key, this.syncElements}) : super(key: key);
  final List<String>? syncElements;
  @override
  ConsumerState<DBSync> createState() => _DBSyncState();
}

class _DBSyncState extends ConsumerState<DBSync> {
  late List _options;

  int index = 0;

  final Map<String, bool> _status = {};

  bool successAlertShown = false;

  // late Size _size;

  @override
  void initState() {
    _options = widget.syncElements ?? enabledOptions.keys.toList();
    _status.addAll(
      Map.fromIterable(
        _options,
        value: (value) {
          return false;
        },
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        context,
        'Sincronización',
        back: false,
        image: 'assets/images/sync.gif',
      ),
      body: _body(context),
    );
  }

  _body(BuildContext context) {
    return Column(
      children: [
        ref.watch(dbSyncProvider).when(
          data: (data) {
            String option = ref.read(currentSyncStateProvider);
            if (data) {
              if (option.isNotEmpty) {
                ref.read(syncStateProvider).add(option);
              }
              if (_options.length == ref.read(syncStateProvider).length) {
                _navigate();
              } else {
                Future.delayed(Duration.zero, () {
                  final value = _options[ref.read(syncStateProvider).length];
                  ref.read(currentSyncStateProvider.notifier).update(
                        (state) => value,
                      );
                  toast(
                    'Sincronizando $value',
                  );
                });
              }
            } else {
              if (ref.read(currentSyncStateProvider).isNotEmpty) {
                toast(
                  'Error al sincronizar ${ref.read(currentSyncStateProvider)}, reintentando',
                  bgColor: AppColors.cancelColor,
                );
                Future.delayed(const Duration(seconds: 1), () {
                  ref
                      .read(currentSyncStateProvider.notifier)
                      .update((state) => '');
                  ref
                      .read(currentSyncStateProvider.notifier)
                      .update((state) => option);
                });
              }
            }
            return const SizedBox();
          },
          error: (error, stackTrace) {
            GlobalLocator.appLogger.e(error);
            return const SizedBox();
          },
          loading: () {
            return const SizedBox();
          },
        ),
        LinearProgressIndicator(
          value: (ref.watch(syncStateProvider).length / _options.length),
        ),
        _elementsLoading().expand(),
      ],
    );
  }

  Widget _syncCSC() {
    return FutureBuilder(
      future: SyncDBProvider.loadCSC(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == true) {
            return elementSync(
              'Países, departamentos y ciudades',
              completed: true,
            );
          }
          AppDialogs.genericConfirmationDialog(
            title:
                'Error al escribir países, departamentos o ciudades en la base de datos local',
          );
          return elementSync('Países, departamentos y ciudades');
        } else {
          return elementSync('Países, departamentos y ciudades');
        }
      },
    );
  }

  Widget _elementsLoading() {
    // bool error = false;
    // to create db if not exists
    return FutureBuilder(
      future: DBProvider.db.database,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            physics: AppConstants.scrollPhysics,
            child: ColumnWithPadding(children: _syncElements(context)),
          );
        } else {
          return Center(
            child: elementSync('Base de datos no encontrada, creándola'),
          );
        }
      },
    );
  }

  List<Widget> _syncElements(BuildContext context) {
    // _size = MediaQuery.of(context).size;
    final List<Widget> elements = _options.map((option) {
      return Column(
        children: [
          ElementSync(
            optionInfo: enabledOptions[option]!,
            optionName: option,
            status: ref.watch(syncStateProvider).contains(option),
          ),
          const Divider(
            color: Colors.black38,
            height: 2,
          ),
        ],
      );
    }).toList();
    // elements.add(_syncCSC());
    return elements;
  }

  Widget elementSync(String option, {bool completed = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          'assets/images/' +
              (enabledOptions[option]?['image'] ?? 'countries.png'),
        ).paddingSymmetric(horizontal: 8, vertical: 3).withHeight(50),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            descText(option, context, fontSizeFactor: 1, maxLines: 2)
                .flexible(flex: 5),
            syncStatus(completed).flexible(),
          ],
        ).flexible(flex: 5),
      ],
    ).paddingSymmetric(horizontal: 7, vertical: 4);
  }

  _navigate() {
    // final _pc = pColor;

    // return ;
    // confirmDialog(context, 'Base de datos sincronizada con éxito',
    //     'assets/images/success.png');
    if (!successAlertShown) {
      final homeKey = GlobalKey<HomeState>();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        confirmDialog(
          context,
          'Base de datos sincronizada con éxito',
          'assets/images/success.png',
        );

        /// set last_logged user to current_user value, used to perform bd operations
        /// on user change
        await setValue('last_user', getStringAsync('current_user'));

        await Future.delayed(const Duration(seconds: 2));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              dataBloc.setHomeKey(homeKey);
              return Home(
                key: homeKey,
              );
            },
          ),
          (route) => false,
        );
      });
      successAlertShown = true;
    }

    // return
  }
}
