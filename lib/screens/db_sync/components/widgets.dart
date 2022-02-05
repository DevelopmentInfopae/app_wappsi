import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

// Widget syncronizeText(BuildContext context) {
//   return StreamBuilder<Object>(
//       stream: syncBloc.progressMessageStream,
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           return Text(
//             snapshot.data.toString(),
//             textAlign: TextAlign.center,
//             style: Theme.of(context).textTheme.headline6,
//           );
//         } else {
//           return Center(
//             child: Text(
//               'Sincronizando base de datos',
//               textAlign: TextAlign.center,
//               style: Theme.of(context).textTheme.headline6,
//             ),
//           );
//         }
//       });
// }

// Widget progressIndicator() {
//   return StreamBuilder<double>(
//       stream: syncBloc.progressStream,
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           return LinearProgressIndicator(
//             value: snapshot.data,
//           );
//         } else {
//           // syncBloc.setProgress(0);
//           return LinearProgressIndicator(
//             value: 0,
//           );
//         }
//       });
// }

// Widget mobileView(BuildContext context) {
//   final _size = MediaQuery.of(context).size;
//   return SafeArea(
//       child: Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 20),
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         image(_size).flexible(flex: 2),
//         syncronizeText(context).withHeight(_size.height * 0.1),
//         // Loader(),
//         progressIndicator().flexible()
//       ],
//     ),
//   ));
// }

Widget image(Size _size) {
  return SizedBox(
    width: _size.width,
    height: _size.height * 0.4,
    child: const Image(
      image: AssetImage('assets/images/sync.gif'),
    ),
  );
}

Widget syncStatus(bool completed) {
    if (completed) {
      return const CircleAvatar(
        backgroundColor: Colors.white,
        
        child: Icon(Icons.check_rounded,color: Colors.greenAccent,),
      ).paddingRight(10);
    } else {
      return Loader();
    }
  }
