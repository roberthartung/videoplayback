import 'dart:html';
import 'dart:async';

void main() {
  HttpRequest.request('http://streaming.mecaso.ch/vp/?range=0-1000000').then((HttpRequest r) {
    Blob blob = new Blob([r.responseText], 'video/mp4');
    VideoElement video = new Element.tag('video');
    String url = Url.createObjectUrl(blob);
    print(url);
    video.onError.listen((Event e) {
      print(video.error.code);
    });
    video.src = url;
    video.controls = true;
    document.body.append(video);
    
    // new Stream.fromIterable(data);
  });
}