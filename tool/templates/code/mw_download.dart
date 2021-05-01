import 'dart:io';

import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

dynamic pdfService;

Handler init() {
  var app = Router().plus;
  //@start
  app.get('/wallpaper/download', () => File('image.jpg'), use: download());

  app.get('/invoice/<id>', (Request request, String id) {
    File document = pdfService.generateInvoice(id);
    return download(filename: 'invoice_$id.pdf') >> document;
  });
  //@end
  return app;
}
