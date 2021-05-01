import 'dart:io';
import 'package:shelf_plus/shelf_plus.dart';
import 'env_example.dart';

void main() => shelfRun(init, envExample);

dynamic pdfService;

Handler init() {
  var app = Router().plus;
  //@start
  app.get('/wallpaper/download', () => File('image.jpg'), use: download());

  app.get('/invoice/<id>', (Request request, String id) {
    File document = pdfService.generateInvoice(id);
    return download(filename: 'invoid_$id') >> document;
  });
  //@end
  return app;
}
