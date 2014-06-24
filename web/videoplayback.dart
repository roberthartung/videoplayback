import 'dart:html';
import 'dart:async';
import 'dart:typed_data';

void main() {
  // int offset = 0;
  int chunkSize = 500000;
  
  // 0..n
  // n+1 .. 2*n
  
  MediaSource ms = new MediaSource();
  VideoElement video = new Element.tag('video');
  
  ms.addEventListener('sourceopen', (Event e) {
    print('sourceopen ' + video.currentSrc);
    SourceBuffer sourceBuffer = ms.addSourceBuffer('video/webm; codecs="vorbis,vp8"');
    request(int offset) {
      String requestUrl = 'http://media.streaming.mecaso.ch/vp.php?range=${offset}-'+(offset+chunkSize-1).toString()+'&type=webm';
      // print('request $offset .. $requestUrl');
      HttpRequest.request(requestUrl, responseType: 'arraybuffer').then((HttpRequest r) {
        ByteBuffer bb = r.response;
        
        print('append... $offset');
        sourceBuffer.appendBuffer(bb);
        print(sourceBuffer.buffered.length);
        // print('startWindow: ' + sourceBuffer.appendWindowStart.toString());
         if(video.paused) {
           print('paused');
           video.play();
         }
         
         // print('readystate: ' + video.readyState.toString());
         
         if(bb.lengthInBytes == chunkSize) {
           //video.onWaiting.listen((e) => request(offset+chunkSize));
           //video.onStalled.listen((e) => request(offset+chunkSize));
           new Timer.periodic(new Duration(milliseconds: 500), (Timer t) {
             
             print('readyState: ' + video.readyState.toString());
             // request(offset+chunkSize);
           });
         } else {
           print('end');
           ms.endOfStream();
         }
       });
    }
    request(0);
  }, false);
  
  String url = Url.createObjectUrl(ms);
  print(url);
  /*
  video.addEventListener('readystatechange', (Event e) {
    print('readystatechange: $e');
  }, false);
  */ 
  video.onLoadStart.listen((Event e) {
    print("loadstart $e");
  });
  video.onLoadedData.listen((Event e) {
    print('loadeddata $e');
  });
  video.onError.listen((Event e) {
    print('error: ' + video.error.code.toString());
  });
  video.onEmptied.listen((Event e) {
    print("emptied $e");
  });
  video.onStalled.listen((Event e) {
    print("stalled $e");
  });
  video.onSuspend.listen((Event e) {
    print("suspended $e");
  });
  video.onWaiting.listen((Event e) {
    print("waiting $e");
  });
  video.onCanPlay.listen((Event e) {
    print("canplay $e");
  });
  video.onCanPlayThrough.listen((Event e) {
    print("canplythrough $e");
  });
  video.src = url;
  video.controls = true;
  video.autoplay = true;
  // video.preload = "metadata";
  document.body.append(video);
  
  
  
  /*
  // MediaStream stream = new MediaStream();
  // &type=webm
  // responseType: 'blob',
  HttpRequest.request('http://streaming.mecaso.ch/vp/?range=0-100000&type=webm', onProgress: (ProgressEvent e) {
    // print((e.loaded / e.total) * 100);
  }).then((HttpRequest r) {
    // Blob blob = new Blob([r.response], 'video/mp4');
    // String url = Url.createObjectUrl(blob);
    
    SourceBuffer buffer = ms.addSourceBuffer('');
    
    print("buffer: $buffer");
    
    return;
    
    ms.addSourceBuffer(r.responseText);
    
    
    // document.body.append(new Text(url));
  });
  * */
}