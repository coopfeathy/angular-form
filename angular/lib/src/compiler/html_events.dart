const _nativeEventSet = <String>{
  'abort',
  'afterprint',
  'animationend',
  'animationiteration',
  'animationstart',
  'appinstalled',
  'audioend',
  'audiostart',
  'beforeprint',
  'beforeunload',
  'blur',
  'change',
  'click',
  'compositionend',
  'compositionstart',
  'compositionupdate',
  'contextmenu',
  'copy',
  'cut',
  'dblclick',
  'drag',
  'dragend',
  'dragenter',
  'dragleave',
  'dragover',
  'dragstart',
  'drop',
  'error',
  'focus',
  'fullscreenchange',
  'fullscreenerror',
  'gotpointercapture',
  'lostpointercapture',
  'input',
  'invalid',
  'keydown',
  'keypress',
  'keyup',
  'languagechange',
  'load',
  'mousedown',
  'mouseenter',
  'mouseleave',
  'mousemove',
  'mouseout',
  'mouseover',
  'mouseup',
  'notificationclick',
  'orientationchange',
  'paste',
  'pause',
  'pointercancel',
  'pointerdown',
  'pointerenter',
  'pointerleave',
  'pointerlockchange',
  'pointerlockerror',
  'pointermove',
  'pointerout',
  'pointerover',
  'pointerup',
  'reset',
  'resize',
  'scroll',
  'select',
  'show',
  'touchcancel',
  'touchend',
  'touchmove',
  'touchstart',
  'transitionend',
  'unload',
  'wheel',
};

/// Returns true if event is an html event that is handled by DOM apis
/// directly and doesn't need to go through plugin system.
bool isNativeHtmlEvent(String eventName) => _nativeEventSet.contains(eventName);
