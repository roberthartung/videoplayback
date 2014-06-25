import 'dart:html';
import 'dart:async';
import 'dart:typed_data';

void main() {
  int chunkSize = 1000000;
  
  MediaSource ms = new MediaSource();
  VideoElement video = new Element.tag('video');
  
  print(video.canPlayType('video/mp4; codecs="mp4v.20.8"'));
  print(video.canPlayType('video/mp4; codecs="avc1.42E01E"'));
  print(video.canPlayType('video/mp4; codecs="avc1.42E01E, mp4a.40.2"'));
  print(video.canPlayType('video/ogg; codecs="theora"'));
  print(video.canPlayType('video/webm; codecs="vp8, vorbis"'));
  
  ms.addEventListener('sourceclosed', (Event e) {
    print('sourceclosed');
  });

  ms.addEventListener('sourceended', (Event e) {
    print('sourceended');
  });
  
  ms.addEventListener('sourceopen', (Event e) {
    print('sourceopen ' + video.currentSrc);
    SourceBuffer sourceBuffer = ms.addSourceBuffer('video/mp4; codecs="avc1.64001f,mp4a.40.2"'); // video/webm; codecs="vorbis,vp8"
    sourceBuffer.addEventListener("update", (Event e) {
      print('update on sourceBuffer');
    }, false);
    
    request(int offset) {
      // &type=webm
      String requestUrl = 'http://streaming.mecaso.ch/vp.php?range=${offset}-'+(offset+chunkSize-1).toString()+'';
      //print('request $offset .. $requestUrl');
      HttpRequest.request(requestUrl, responseType: 'arraybuffer').then((HttpRequest r) {
        ByteBuffer bb = r.response;
        
        print('append... $offset');
        sourceBuffer.appendBuffer(bb);
        // print(sourceBuffer.buffered.length);
        
        // print('startWindow: ' + sourceBuffer.appendWindowStart.toString());
         if(video.paused) {
           print('paused');
           video.play();
         }
         
         // print('readystate: ' + video.readyState.toString());
         
         if(bb.lengthInBytes == chunkSize) {
           //video.onWaiting.listen((e) => request(offset+chunkSize));
           //video.onStalled.listen((e) => request(offset+chunkSize));
           // new Timer.periodic(new Duration(milliseconds: 500), (Timer t) {
           new Timer(new Duration(milliseconds: 500), () {
             // print('readyState: ' + video.readyState.toString());
             request(offset+chunkSize);
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