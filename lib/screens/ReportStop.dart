import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gpspro/arguments/ReportArguments.dart';
import 'package:gpspro/services/APIService.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ReportStopPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ReportStopPageState();
}

class _ReportStopPageState extends State<ReportStopPage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  static ReportArguments? args;
  StreamController<int>? _postsController;
  Timer? _timer;
  bool isLoading = true;
  static var httpClient = new HttpClient();
  File? file;
  var bytes;

  Color _mapTypeBackgroundColor = CustomColor.primaryColor;
  Color _mapTypeForegroundColor = CustomColor.secondaryColor;

  @override
  void initState() {
    _postsController = new StreamController();
    getReport();
    super.initState();
  }

  Future<File?> _downloadFile(String url, String filename) async {
    Random random = new Random();
    int randomNumber = random.nextInt(100);
    print(url);
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File pdffile = new File('$dir/$filename-$randomNumber.pdf');
    file = pdffile;
    _postsController!.add(1);
    setState(() {
      isLoading = false;
    });
    await file!.writeAsBytes(bytes);
    return file;
  }

  getReport() {
    _timer = new Timer.periodic(Duration(seconds: 1), (timer) {
      if (args != null) {
        timer.cancel();
        APIService.getReportStop(
            args!.id.toString(), args!.fromDate, args!.toDate, args!.type)
            .then((value) => {
          _downloadFile(value!.url!, "stop"),
        });
      }
    });
  }

  Future<File?> writeFile() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory == null) {
      Fluttertoast.showToast(
          msg: "No se pudo acceder al directorio de descargas",
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return null;
    }

    Random random = new Random();
    int randomNumber = random.nextInt(100);
    String filePath = '${directory.path}/stop-$randomNumber.pdf';
    File pdfFile = File(filePath);
    await pdfFile.writeAsBytes(bytes);

    Fluttertoast.showToast(
        msg: "Archivo exportado a ${pdfFile.path}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );

    return pdfFile;
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as ReportArguments;

    return Scaffold(
        appBar: AppBar(
          title: Text(args!.name,
              style: TextStyle(color: CustomColor.secondaryColor)),
          iconTheme: IconThemeData(
            color: CustomColor.secondaryColor,
          ),
        ),
        floatingActionButton: !isLoading
            ? FloatingActionButton(
          heroTag: "mapType",
          mini: true,
          onPressed: writeFile,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          backgroundColor: _mapTypeBackgroundColor,
          foregroundColor: _mapTypeForegroundColor,
          child: const Icon(Icons.download_rounded, size: 30.0),
        )
            : Container(),
        body: StreamBuilder<int>(
            stream: _postsController!.stream,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              if (snapshot.data == 1) {
                return SfPdfViewer.file(
                  file!,
                  key: _pdfViewerKey,
                );
              } else if (isLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.data == 0) {
                return Center(
                  child: Text(('noData')),
                );
              } else {
                return Center(
                  child: Text(('noData')),
                );
              }
            }
        )
    );
  }
}
