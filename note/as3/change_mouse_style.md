---
title: 修改鼠标样式 
grammar_cjkRuby: true
---


```actionscript
var cursorData:MouseCursorData = new MouseCursorData();
cursorData.data = new Vector.<BitmapData>(1, true);
cursorData.data[0] = ...bitmapdata;
cursorData.frameRate = 1;

// register
Mouse.registerCursor(MouseCursor.ARROW, cursorData);
Mouse.registerCursor(MouseCursor.BUTTON, cursorData);
// unregister
Mouse.unregisterCursor(MouseCursor.ARROW);
```
